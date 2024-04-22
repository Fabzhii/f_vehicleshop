
ESX.RegisterServerCallback("fvehicleshop:getJob", function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getJob().name, xPlayer.getJob().grade)
end) 

RegisterServerEvent('fvehicleshop:setBucket')
AddEventHandler('fvehicleshop:setBucket', function(bucket)
    SetPlayerRoutingBucket(source, bucket)
end)