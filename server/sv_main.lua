if Config.Framework == 'qb' then 
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

local SkillsCache = {}

local queries = {
    ['qb'] = {
        UPDATE_SKILLS = 'UPDATE players SET skills = ? WHERE citizenid = ?',
        SELECT_SKILLS = 'SELECT skills FROM players WHERE citizenid = ?'
    },
    ['esx'] = {
        UPDATE_SKILLS = 'UPDATE users SET skills = ? WHERE identifier = ?',
        SELECT_SKILLS = 'SELECT skills FROM users WHERE identifier = ?'
    }
}

function GetPlayerData(src)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' then 
        return ESX.GetPlayerFromId(src)
    end
end

function GetPlayerUID(Player)
    if Config.Framework == 'qb' then
        return Player.PlayerData.citizenid
    elseif Config.Framework == 'esx' then 
        return Player.identifier
    end
end

local function checkConfigForUpdates(result, UID)
    local playerSkills = json.decode(result[1].skills)

    for i = 1, #Config.Skills do
        local skill = Config.Skills[i]
        local found = false

        for j = 1, #playerSkills do
            if playerSkills[j].name == skill then
                found = true
            end
        end

        if not found then
            table.insert(playerSkills, {
                name = skill,
                level = 0,
                progress = 0
            })
        end
    end

    MySQL.update.await(queries[Config.Framework].UPDATE_SKILLS, { json.encode(playerSkills), UID })

    return json.encode(playerSkills)
end

lib.callback.register('qw_skills:server:getSkills', function(source)
    local src = source
    local Player = GetPlayerData(src)

    if not Player then return false end
    local UID = GetPlayerUID(Player)

    if SkillsCache[UID] then
        return SkillsCache[UID]
    end

    local result = MySQL.query.await(queries[Config.Framework].SELECT_SKILLS, { UID })

    if result and result[1].skills ~= '[]' then
        SkillsCache[UID] = checkConfigForUpdates(result, UID)
        return SkillsCache[UID]
    end

    local tempTable = {}

    for i = 1, #Config.Skills do
        local skill = Config.Skills[i]
        tempTable[i] = {
            name = skill,
            level = 0,
            progress = 0
        }
    end

    MySQL.update.await(queries[Config.Framework].UPDATE_SKILLS, { json.encode(tempTable), UID })

    SkillsCache[UID] = json.encode(tempTable)

    return SkillsCache[UID]
end)

lib.callback.register('qw_skills:server:updateSkill', function(source, skill, progress)
    local src = source
    local Player = GetPlayerData(src)

    if not Player then return false end

    if not skill or not progress then return false end

    local UID = GetPlayerUID(Player)

    local playerSkills = json.decode(SkillsCache[UID])

    for i = 1, #playerSkills do
        if playerSkills[i].name == skill then
            playerSkills[i].progress = playerSkills[i].progress + progress

            if playerSkills[i].progress >= 100 then
                playerSkills[i].level = playerSkills[i].level + 1
                playerSkills[i].progress = 0
            end
        end
    end

    SkillsCache[UID] = json.encode(playerSkills)

    return SkillsCache[UID]
end)

lib.callback.register('qw_skills:server:checkSkill', function(source, skill)
    local src = source
    local Player = GetPlayerData(src)

    if not Player then return false end

    if not skill then
        print('no skill')
        return false
    end

    local UID = GetPlayerUID(Player)

    local playerSkills = json.decode(SkillsCache[UID])

    for i = 1, #playerSkills do
        if playerSkills[i].name == skill then
            return json.encode(playerSkills[i])
        end
    end

    return false
end)

local function savePlayerSkills(UID)
    local playerSkills = json.decode(SkillsCache[UID])

    MySQL.update.await(queries[Config.Framework].UPDATE_SKILLS, { json.encode(playerSkills), UID })
end

RegisterNetEvent('qw_skills:server:removePlayerFromCache', function()
    local src = source
    local Player = GetPlayerData(src)

    if not Player then return end
    local UID = GetPlayerUID(Player)

    if not SkillsCache[UID] then return end

    savePlayerSkills(UID)
    SkillsCache[UID] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    local Player = GetPlayerData(src)

    if not Player then return end
    local UID = GetPlayerUID(Player)

    if not SkillsCache[UID] then return end

    savePlayerSkills(UID)
    SkillsCache[UID] = nil

    print('saved skills for ' .. UID)
end)
