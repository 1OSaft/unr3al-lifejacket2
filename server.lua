AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS unr3al_lifejacket (`identifier` varchar(80) NOT NULL, `bag` longtext DEFAULT NULL, PRIMARY KEY (`identifier`));")

		if createTable.warningStatus == 0 then
			print('^2 Successfully ^3 created ^2 table ^3 unr3al_lifejacket ^0')
		end
    end
end)

RegisterServerEvent('unr3al:lifejacket:save')
AddEventHandler('unr3al:lifejacket:save', function(skin)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.update('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(skin),
		['@identifier'] = xPlayer.identifier
	})
end)

for kjacket, vjacket in pairs(Config.Lifejackets) do
    ESX.RegisterUsableItem(kjacket, function(source)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        TriggerClientEvent('unr3al:lifejacket:puton', xPlayer)

        MySQL.query('SELECT bag FROM unr3al_lifejacket WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        }, function(result)
            if result[1] and result[1].bag then
                xPlayer.showNotification(_U('has_bag'))
                return
            elseif not result[1] then
                logging('debug', 'Add lifejacket into Database', xPlayer.identifier, kjacket)
                MySQL.query('INSERT INTO unr3al_lifejacket (identifier, bag) VALUES (@identifier, @bag)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@bag'] = kjacket,
                })
            elseif result[1] and not result[1].bag then
                logging('debug', 'Add lifejacket into Database', xPlayer.identifier, kjacket)
                MySQL.update("UPDATE unr3al_lifejacket SET bag = @bag WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier,
                    ["@bag"] = kjacket
                })
            end

            xPlayer.removeInventoryItem(kjacket, 1)
            xPlayer.addInventoryItem('nojacket', 1)
            TriggerClientEvent('unr3al:lifejacket:setLifejacket', src, kjacket, vjacket)
        end)
    end)
end

-- No Bag
ESX.RegisterUsableItem('nojacket', function(source)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local currentJacket = MySQL.query.await('SELECT * FROM unr3al_lifejacket WHERE identifier = @identifier', { 
        ["@identifier"] = xPlayer.identifier
    })

    if not xPlayer.canCarryItem(currentJacket[1].bag, 1) then 
        xPlayer.showNotification(_U('too_heavy'))
        return 
    end


        TriggerClientEvent('unr3al:lifejacket:delJacket', src)
        xPlayer.removeInventoryItem('nojacket', 1)
        xPlayer.addInventoryItem(currentJacket[1].bag, 1)
    
        
        MySQL.update("UPDATE unr3al_lifejacket SET bag = @bag WHERE identifier = @identifier", {
            ["@identifier"] = xPlayer.identifier,
            ["@bag"] = NULL
        })

end)

ESX.RegisterCallback('unr3al:lifejacket:getPlayerSkin', function(source, cb, playerId)
    local src = source
	local xPlayer
    
    if playerId then
        xPlayer = ESX.GetPlayerFromId(playerId)
    else
        xPlayer = ESX.GetPlayerFromId(src)
    end

    if not xPlayer then return end

    local skin = false
	local data = MySQL.query('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})

    if data and data[1] and data[1].skin then
        skin = json.decode(data[1].skin)
    end

    cb(skin)
end)


ESX.RegisterCallback('unr3al:lifejacket:hasjacket', function(source, cb, player)
    cb(hasjacket(player))
end)

hasjacket = function(player)
    if not player then return end
    local xPlayer 

    if player.source then
        xPlayer = ESX.GetPlayerFromId(player.source)
    elseif player.identifier then
        xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
    elseif player.player then 
        xPlayer = player.player
    end

    if not xPlayer then return false end
    local data = MySQL.query.await("SELECT * FROM unr3al_lifejacket WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier})

    if data and data[1] and data[1].bag then return data[1].bag end
    return false
end
exports('hasjacket', hasjacket)