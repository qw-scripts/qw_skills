local QBCore = exports['qb-core']:GetCoreObject()

local function fetchSkills()
    lib.callback('qw_skills:server:getSkills', false, function(skills)
        if skills then
            local skills = json.decode(skills)
            SendNUIMessage({ action = 'updateSkills', data = skills })
        end
    end)
end

function UpdateSkill(skill, progress)
    lib.callback('qw_skills:server:updateSkill', false, function(skills)
        if skills then
            lib.notify({
                title = 'Skills',
                description = 'You have earned ' .. progress .. ' XP for ' .. skill .. '!',
                type = 'success'
            })
            local skills = json.decode(skills)
            SendNUIMessage({ action = 'updateSkills', data = skills })
        end
    end, skill, progress)
end

exports('UpdateSkill', UpdateSkill)

function GetCurrentSkill(skillToCheck)
    local data = lib.callback.await('qw_skills:server:checkSkill', false, skillToCheck)

    if data then
        return json.decode(data)
    end
end

exports('GetCurrentSkill', GetCurrentSkill)


if Config.UsingCommand then
    RegisterCommand('skills', function()
        SendNUIMessage({ action = 'viewSkills', data = nil })
        SetNuiFocus(true, true)
    end, false)
end


RegisterNetEvent('qw_skills:client:openMenu', function()
    SendNUIMessage({ action = 'viewSkills', data = nil })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('hideUI', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerServerEvent('qw_skills:server:removePlayerFromCache')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    fetchSkills()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        fetchSkills()
    end
end)
