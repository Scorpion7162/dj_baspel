local QBCore = exports['qb-core']:GetCoreObject()
local currentZone = nil
local PlayerData = {}
local lib = nil
print('ox_lib loaded:', lib ~= nil)

-- Handlers

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    PlayerData = QBCore.Functions.GetPlayerData()
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- Main Menu

function createMusicMenu()
    return {
        {
            title = '💿 | DJ Booth',
            isHeader = true
        },
        {
            title = '🎶 | Play a song',
            description = 'Enter a YouTube URL',
            onSelect = function()
                local input = lib.inputDialog('Song Selection', {
                    {type = 'input', label = 'YouTube URL', required = true}
                })
                if input then
                    TriggerServerEvent('qb-djbooth:server:playMusic', input[1], currentZone)
                end
            end
        },
        {
            title = '⏸️ | Pause Music',
            description = 'Pause currently playing music',
            serverEvent = 'qb-djbooth:server:pauseMusic',
            args = {zoneName = currentZone}
        },
        {
            title = '▶️ | Resume Music',
            description = 'Resume playing paused music',
            serverEvent = 'qb-djbooth:server:resumeMusic',
            args = {zoneName = currentZone}
        },
        {
            title = '🔈 | Change Volume',
            description = 'Set music volume',
            onSelect = function()
                local input = lib.inputDialog('Music Volume', {
                    {type = 'input', label = 'Min: 0.01 - Max: 1', required = true}
                })
                if input then
                    TriggerServerEvent('qb-djbooth:server:changeVolume', tonumber(input[1]), currentZone)
                end
            end
        },
        {
            title = '❌ | Turn off music',
            description = 'Stop the music & choose a new song',
            serverEvent = 'qb-djbooth:server:stopMusic',
            args = {zoneName = currentZone}
        }
    }
end

-- DJ Booths

local vanilla = BoxZone:Create(Config.Locations['bahama'].coords, 1, 1, {
    name = "Bahama",
    heading = 0
})

vanilla:onPlayerInOut(function(isPointInside)
    if isPointInside and PlayerData.job.name == Config.Locations['bahama'].job then
        currentZone = 'bahama'
        lib.showContext('musicHeader')
    else
        currentZone = nil
        lib.hideContext()
    end
end)

-- Events

RegisterNetEvent('qb-djbooth:client:playMusic', function()
    local musicMenu = createMusicMenu()
    lib.registerContext({
        id = 'musicMenu',
        title = 'DJ Booth',
        options = musicMenu
    })
    lib.showContext('musicMenu')
end)

RegisterNetEvent('qb-djbooth:client:musicMenu', function()
    local input = lib.inputDialog('Song Selection', {
        {type = 'input', label = 'YouTube URL', required = true}
    })
    if input then
        TriggerServerEvent('qb-djbooth:server:playMusic', input[1], currentZone)
    end
end)

RegisterNetEvent('qb-djbooth:client:changeVolume', function()
    local input = lib.inputDialog('Music Volume', {
        {type = 'input', label = 'Min: 0.01 - Max: 1', required = true}
    })
    if input then
        TriggerServerEvent('qb-djbooth:server:changeVolume', tonumber(input[1]), currentZone)
    end
end)
