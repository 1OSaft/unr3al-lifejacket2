RegisterNetEvent('unr3al:lifejacket:puton')
AddEventHandler('unr3al:lifejacket:puton', function()
    DisableControlAction(0, 55, true)
end)


RegisterNetEvent('unr3al:lifejacket:putoff')
AddEventHandler('unr3al:lifejacket:putoff', function()
    EnableControlAction(0, 55, true)

end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        ESX.TriggerServerCallback('unr3al:lifejacket:hasjacket', function(data)
            print(data)
            hasjacket = data

            if not #hasjacket == 'null' then
                ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(data2)
                print(data2)
                isdead = data2
                if isdead then
                    local pos = GetEntityCoords(PlayerPedId())
                    local waterpos = GetWaterHeight(pos.x, pos.y, pos.z)
                    SetEntityCoords(PlayerPedId(), pos.x, pos.y, waterpos.z)
                end
                end)
            end
        end)
        Citizen.Wait(1000)
    end
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    Wait(1000) -- Please Do Not Touch!
    logging('debug', 'Player loaded on Event esx:playerLoaded')

    local hasjacket = hasjacket({source = GetPlayerServerId(PlayerId())})
    if not hasjacket then return end

    if not skin then return end

    if skin.sex == 0 then -- Male
        if skin.bproof_1 == Config.Lifejackets[hasjacket].skin.male.skin1 then
            logging('debug', skin.bproof_1, Config.Lifejackets[hasjacket].skin.male.skin1)
            setJoinJacket(hasjacket)
        else
            TriggerEvent('skinchanger:change', "bproof_1", Config.Lifejackets[hasjacket].skin.male.skin1)
            TriggerEvent('skinchanger:change', "bproof_2", Config.Lifejackets[hasjacket].skin.male.skin2)
            saveSkin()
            setJoinJacket(hasjacket)
        end
    else
        if skin.bproof_1 == Config.Lifejackets[hasjacket].skin.female.skin1 then
            logging('debug', skin.bproof_1, Config.Lifejackets[hasjacket].skin.female.skin1)
            setJoinJacket(hasjacket)
        else
            TriggerEvent('skinchanger:change', "bproof_1", Config.Lifejackets[hasjacket].skin.female.skin1)
            TriggerEvent('skinchanger:change', "bproof_2", Config.Lifejackets[hasjacket].skin.female.skin2)
            saveSkin()
            setJoinJacket(hasjacket)
        end
    end
end)

RegisterNetEvent('unr3al:lifejacket:setLifejacket')
AddEventHandler('unr3al:lifejacket:setLifejacket', function(itemname, item)
    logging('debug', 'itemname:', itemname)
    local playerPed = PlayerPedId()

    doAnimation(playerPed)

    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then -- Male
            TriggerEvent('skinchanger:change', "bproof_1", item.skin.male.skin1)
            TriggerEvent('skinchanger:change', "bproof_2", item.skin.male.skin2)
            saveSkin()
        else -- Female
            TriggerEvent('skinchanger:change', "bproof_1", item.skin.female.skin1)
            TriggerEvent('skinchanger:change', "bproof_2", item.skin.female.skin2)
            saveSkin()
        end
    end)

    ESX.ShowNotification(_U('used_bag'))
end)

RegisterNetEvent('unr3al:lifejacket:delJacket')
AddEventHandler('unr3al:lifejacket:delJacket', function()
    logging('debug', 'Trigger Event delJacket')
    local playerPed = PlayerPedId()
    EnableControlAction(0, 55, true)

    doAnimation(playerPed)

    TriggerEvent('skinchanger:change', "bproof_1", 0)
    TriggerEvent('skinchanger:change', "bproof_2", 0)
    saveSkin()
    logging('debug', 'Set Jacket to 0')


    ESX.ShowNotification(_U('used_nojacket'))
end)


doAnimation = function(playerPed)
    ESX.Streaming.RequestAnimDict(Config.Animations.dict, function()
		TaskPlayAnim(playerPed, Config.Animations.dict, Config.Animations.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		RemoveAnimDict(Config.Animations.dict)
	end)
	Wait(Config.Animations.time * 1000)
	ClearPedTasks(playerPed)
end

setJoinJacket = function(item, weight)
    if Config.restoreLifejacket then
        TriggerEvent('unr3al:lifejacket:setLifejacket')
        DisableControlAction(0, 55, true)
    end
end

hasjacket = function(player)
    if not player then return end
    return ESX.TriggerCallback('unr3al:lifejacket:hasjacket', player)
end
exports('hasjacket', hasjacket)

saveSkin = function()
    if not Config.saveSkin then return end
    Wait(100)

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('unr3al:lifejacket:save', skin)
    end)
end

logging = function(code, ...)
    if not Config.Debug then return end
    
    local script = "[^2"..GetCurrentResourceName().."^0]"
    MSK.logging(script, code, ...)
end