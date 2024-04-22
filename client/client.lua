
local ox_inventory = exports.ox_inventory
local locales = Config.Locales[Config.Language]

local large = {}
local small = {}

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do 
        createBlip(v.positions.menu, v.blip, v.label)
    end 
end)

function createBlip(position, blip, label)
    blip = AddBlipForCoord()position
    SetBlipSprite(blip, blip.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip,  blip.scale)
    SetBlipColour(blip, blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do 
        large[k] = lib.zones.sphere({
            coords = v.positions.menu,
            radius = 25,
            debug = false,
            inside = function()
                DrawMarker(v.marker.id, v.positions.menu, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.marker.size, v.marker.size, v.marker.size, v.marker.color.r, v.marker.color.g, v.marker.color.b, v.marker.color.a, false, true, false, false) 
            end,
        })
    end 
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do 
        small[k] = lib.zones.sphere({
            coords = v.positions.menu,
            radius = 1.0,
            debug = false,
            inside = function()
                if IsControlJustReleased(0, 38) then 
                    canOpenShop(v)
                end
            end,
            onEnter = function()
                Config.InfoBar({(locales['interact'][1]):format(v.label), locales['interact'][2]}, true)
            end,
            onExit = function()
                Config.InfoBar({(locales['interact'][1]):format(v.label), locales['interact'][2]}, false)
            end,
        })
    end
end)

function canOpenShop(shop)
    ESX.TriggerServerCallback('fvehicleshop:getJob', function(xJob, xGrade)
        local access = false
        if shop.allowedJobs == nil then
            access = true  
            openShop(shop, xGrade)
        end 

        if type(shop.allowedJobs) == 'string' then 
            if shop.allowedJobs == xJob then 
                access = true
                openShop(shop, xGrade)
            end 
        end 

        if type(shop.allowedJobs) == 'table' then 
            for k,v in pairs(shop.allowedJobs) do 
                if v == xJob then 
                    access = true
                    openShop(shop, xGrade)
                end 
            end 
        end 

        if not access then 
            Config.Notifcation(locales['no_access'])
        end 
    end)
end 

local canExit = true 
function openShop(shop, xGrade)
    local categories = {}
    for k,v in pairs(shop.categories) do 
        table.insert(categories, {
            label = v.label, 
            values, args = getArguments(v.vehicles, xGrade), 
        })
    end 

    TriggerServerEvent('fvehicleshop:setBucket', GetPlayerServerId(PlayerId()))
    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
    SetEntityCoords(PlayerPedId(), shop.positions.inside)
    canExit = false
    Citizen.CreateThread(function()
        while not canExit do 
            DisableControlAction(0, 75, true)
            Citizen.Wait(1)
        end 
    end) 


    lib.registerMenu({
        id = 'f_vehicleshop',
        title = shop.label,
        position = shop.menu_position,
        onSideScroll = function(selected, scrollIndex, args)
            
        end,
        onSelected = function(selected, secondary, args)

        end,

        onClose = function(keyPressed)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            TriggerServerEvent('fvehicleshop:setBucket', 0)
            SetEntityCoords(PlayerPedId(), shop.positions.menu)
            canExit = true 
        end,
        options = categories,
    }, function(selected, scrollIndex, args)
        print(selected, scrollIndex, args)
    end)
    lib.showMenu('f_vehicleshop')

end 

function getArguments(vehicles, xGrade)
    local returnValues = {}
    local returnArgs = {}
    for k,v in pairs(vehicles) do 
        if v.grade == nil then 
            table.insert(returnValues, (GetLabelText(v.vehicle) .. ' - ' .. v.price .. '$'))
            table.insert(returnArgs, {v.vehicle, v.price})
        end 
        if type(v.grade) == 'number' then 
            if xGrade >= v.grade then 
                table.insert(returnValues, (GetLabelText(v.vehicle) .. ' - ' .. v.price .. '$'))
                table.insert(returnArgs, {v.vehicle, v.price})
            end 
        end 
        if type(v.grade) == 'table' then 
            for o, i in pairs(v.grade) do 
                if i == xGrade then 
                    table.insert(returnValues, (GetLabelText(v.vehicle) .. ' - ' .. v.price .. '$'))
                    table.insert(returnArgs, {v.vehicle, v.price})
                end 
            end 
        end 
    end 
    return(returnValues, returnArgs)
end 

RegisterNetEvent('fvehicleshop:openAdminUi')
AddEventHandler('fvehicleshop:openAdminUi', function(playerData)


    local input = lib.inputDialog('Dialog title', {
        {type = 'select', label = locales['admin_player'][1], description = locales['admin_player'][2], options = playerData, required = true},
        {type = 'input', label = locales['admin_vehicle'][1], description = locales['admin_vehicle'][2], required = true},
        {type = 'input', label = locales['admin_plate'][1], description = locales['admin_plate'][2], required = true},
        {type = 'color', label = locales['admin_color'][1], description = locales['admin_color'][2], required = true, format = 'rgb'},
        {type = 'checkbox', label = locales['admin_spawn'][1], description = locales['admin_spawn'][2]},
    })
    if input ~= nil then 
        
    end 
end)