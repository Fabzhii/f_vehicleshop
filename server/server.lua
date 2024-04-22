
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

ESX.RegisterCommand({Config.AdminCommand.command}, Config.AdminCommand.groups, function(xPlayer, args, showError)

    local playerData = {}
    for k,v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        table.insert(playerData, {
            label = xPlayer.getName(),
            value = xPlayer.source,
        })
    end

    TriggerClientEvent('fvehicleshop:openAdminUi', xPlayer.source, playerData)
    end, false, {help = _U('command_cardel')
})