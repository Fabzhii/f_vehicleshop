
ESX.RegisterServerCallback("fvehicleshop:getJob", function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getJob().name, xPlayer.getJob().grade)
end) 

RegisterServerEvent('fvehicleshop:setBucket')
AddEventHandler('fvehicleshop:setBucket', function(bucket)
    SetPlayerRoutingBucket(source, bucket)
end)

RegisterServerEvent('fvehicleshop:setEntityBucket')
AddEventHandler('fvehicleshop:setEntityBucket', function(entity, bucket)
    SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(entity), bucket)
end)

ESX.RegisterServerCallback('fvehicleshop:isPlateTaken', function(source, cb, plate)
	MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
	function(result)
		cb(result ~= nil)
	end)
end)

RegisterServerEvent('fvehicleshop:writesqlcar')
AddEventHandler('fvehicleshop:writesqlcar', function(id, props, plate, job, price)
    exports.ox_inventory:RemoveItem(source, 'money', price)
    local xPlayer = ESX.GetPlayerFromId(id)
    MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)', {xPlayer.identifier, plate, json.encode(props), 'car', job, 0},
    function() end)
end)

RegisterCommand('getBucket',function(source, args, rawCommand)
    print(GetPlayerRoutingBucket(source))
end)
