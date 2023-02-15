local QBCore = exports['qb-core']:GetCoreObject()
local SkillsCache = {}

local function checkConfigForUpdates(result, CID)
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

    MySQL.update.await('UPDATE players SET skills = ? WHERE citizenid = ?', { json.encode(playerSkills), CID })

    return json.encode(playerSkills)
end

lib.callback.register('qw_skills:server:getSkills', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return false end
    local CID = Player.PlayerData.citizenid

    if SkillsCache[CID] then
        return SkillsCache[CID]
    end

    local result = MySQL.query.await('SELECT skills FROM players WHERE citizenid = ?', { CID })

    if result and result[1].skills ~= '[]' then
        SkillsCache[CID] = checkConfigForUpdates(result, CID)
        return SkillsCache[CID]
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

    MySQL.update.await('UPDATE players SET skills = ? WHERE citizenid = ?', { json.encode(tempTable), CID })

    SkillsCache[CID] = json.encode(tempTable)

    return SkillsCache[CID]
end)

lib.callback.register('qw_skills:server:updateSkill', function(source, skill, progress)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return false end

    if not skill or not progress then return false end

    local CID = Player.PlayerData.citizenid

    local playerSkills = json.decode(SkillsCache[CID])

    for i = 1, #playerSkills do
        if playerSkills[i].name == skill then
            playerSkills[i].progress = playerSkills[i].progress + progress

            if playerSkills[i].progress >= 100 then
                playerSkills[i].level = playerSkills[i].level + 1
                playerSkills[i].progress = 0
            end
        end
    end

    SkillsCache[CID] = json.encode(playerSkills)

    return SkillsCache[CID]
end)

lib.callback.register('qw_skills:server:checkSkill', function(source, skill)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return false end

    if not skill then
        print('no skill')
        return false
    end

    local CID = Player.PlayerData.citizenid

    local playerSkills = json.decode(SkillsCache[CID])

    for i = 1, #playerSkills do
        if playerSkills[i].name == skill then
            return json.encode(playerSkills[i])
        end
    end

    return false
end)

local function savePlayerSkills(CID)
    local playerSkills = json.decode(SkillsCache[CID])

    MySQL.update.await('UPDATE players SET skills = ? WHERE citizenid = ?', { json.encode(playerSkills), CID })
end

RegisterNetEvent('qw_skills:server:removePlayerFromCache', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    local CID = Player.PlayerData.citizenid

    if not SkillsCache[CID] then return end

    savePlayerSkills(CID)
    SkillsCache[CID] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    local CID = Player.PlayerData.citizenid

    if not SkillsCache[CID] then return end

    savePlayerSkills(CID)
    SkillsCache[CID] = nil

    print('saved skills for ' .. CID)
end)
