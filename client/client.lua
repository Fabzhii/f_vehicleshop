
local ox_inventory = exports.ox_inventory
local locales = Config.Locales[Config.Language]

local large = {}
local small = {}

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do 
        createBlip(v.positions.menu, v.blip, v.label)
    end 
end)

function createBlip(position, blipsetting, label)
    local blip = AddBlipForCoord(position)
    SetBlipSprite(blip, blipsetting.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip,  blipsetting.scale)
    SetBlipColour(blip, blipsetting.color)
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
            values = getArguments(v.vehicles, xGrade)[1],
            args = getArguments(v.vehicles, xGrade)[2],
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
            Citizen.Wait(5)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            Citizen.Wait(5)
            local model = args[scrollIndex][1]
            local vehicle = spawncar(model, shop.positions.inside, GetPlayerServerId(PlayerId()), shop.buy)
            Citizen.Wait(5)
            SetPedIntoVehicle(PlayerPedId(), vehicle, -1) 
            
        end,
        onSelected = function(selected, secondary, args)
            Citizen.Wait(5)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            Citizen.Wait(5)
            local model = categories[selected].args[secondary][1]
            local vehicle = spawncar(model, shop.positions.inside, GetPlayerServerId(PlayerId()), shop.buy)
            Citizen.Wait(5)
            SetPedIntoVehicle(PlayerPedId(), vehicle, -1) 
        end,

        onClose = function(keyPressed)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            TriggerServerEvent('fvehicleshop:setBucket', 0)
            SetEntityCoords(PlayerPedId(), shop.positions.menu)
            canExit = true 
        end,
        options = categories,
    }, function(selected, scrollIndex, args)
        if ox_inventory:GetItemCount('money') >= args[scrollIndex][2] then 
            local alert = lib.alertDialog({
                header = GetLabelText(args[scrollIndex][1]),
                content = (locales['buy_menu'][1]):format(args[scrollIndex][2]),
                centered = true,
                cancel = true,
                labels = {
                    cancel = locales['cancel'],
                    confirm = locales['confirm'],
                }
            })
            if alert == 'confirm' then 

                local settings = GetSettings(shop)

		if settings ~= {} then 
	            local hex = settings[1]
	            local hex = hex:gsub("#","")
	            local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))

		    SetVehicleCustomPrimaryColour(GetVehiclePedIsIn(PlayerPedId(), false), r,g,b)
                    SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), settings[2])
		end 

                local vehicleProps = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false))
                local platetext = vehicleProps.plate
                TriggerServerEvent('fvehicleshop:writesqlcar', GetPlayerServerId(PlayerId()), vehicleProps, platetext, shop.dbjob, args[scrollIndex][2])
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
                SetEntityCoords(PlayerPedId(), shop.positions.outside)
                TriggerServerEvent('fvehicleshop:setBucket', 0)
                canExit = true 
                ESX.Game.SpawnVehicle(vehicleProps.model, shop.positions.outside, shop.positions.outside.w, function(vehicle)
                    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, -1) 
                    Config.Notifcation(locales['bought'])
                end)
            else 
                lib.hideMenu(false)
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
                openShop(shop, xGrade)
            end 
        else 
            lib.hideMenu(false)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            openShop(shop, xGrade)
            Config.Notifcation(locales['no_money'])
        end 
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


    return({returnValues, returnArgs})
end 

RegisterNetEvent('fvehicleshop:openAdminUi')
AddEventHandler('fvehicleshop:openAdminUi', function(playerData)

    local input = lib.inputDialog(locales['configure'][1], {
        {type = 'select', label = locales['admin_player'][1], description = locales['admin_player'][2], options = playerData, required = true},
        {type = 'input', label = locales['admin_vehicle'][1], description = locales['admin_vehicle'][2], required = true},
        {type = 'input', label = locales['admin_plate'][1], description = locales['admin_plate'][2], required = true},
        {type = 'color', label = locales['admin_color'][1], description = locales['admin_color'][2], required = true, format = 'hex'},
        {type = 'input', label = locales['admin_dbjob'][1], description = locales['admin_dbjob'][2], required = true},
        {type = 'checkbox', label = locales['admin_spawn'][1], description = locales['admin_spawn'][2]},
    })
    if input ~= nil then 

        local hex = input[4]
        local hex = hex:gsub("#","")
        local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))

        if input[6] then 
            ESX.Game.SpawnVehicle(input[2], GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(vehicle)
                Citizen.Wait(5)
                SetVehicleCustomPrimaryColour(vehicle, r,g,b)
                SetVehicleNumberPlateText(vehicle, input[3])
                Citizen.Wait(5)
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                local platetext = vehicleProps.plate
                TriggerServerEvent('fvehicleshop:writesqlcar', tonumber(input[1]), vehicleProps, platetext, input[5], 0)
            end)
        else 
            local pedCoords = GetEntityCoords(PlayerPedId())
            local coords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 10)
            ESX.Game.SpawnVehicle(input[2], coords, GetEntityHeading(PlayerPedId()), function(vehicle)
                Citizen.Wait(5)
                SetVehicleCustomPrimaryColour(vehicle, r,g,b)
                SetVehicleNumberPlateText(vehicle, input[3])
                Citizen.Wait(5)
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                local platetext = vehicleProps.plate
                TriggerServerEvent('fvehicleshop:writesqlcar', tonumber(input[1]), vehicleProps, platetext, input[5], 0)
                Citizen.Wait(5)
                DeleteVehicle(vehicle)
            end)
        end

    end 
end)

function spawncar(car, pos, bucket, buySettings)
    local ModelHash = car
	if not IsModelInCdimage(ModelHash) then return end
	RequestModel(ModelHash)
	while not HasModelLoaded(ModelHash) do Wait(0) end
	vehicle = CreateVehicle(ModelHash, pos, pos.w, true, false)
    
	SetModelAsNoLongerNeeded(ModelHash)
    FreezeEntityPosition(vehicle, true)
    SetVehicleNumberPlateText(vehicle, GenPlate(buySettings))
	Citizen.Wait(30)
    Entity(vehicle).state.fuel = 100
	TriggerServerEvent('fvehicleshop:setEntityBucket', NetworkGetNetworkIdFromEntity(vehicle), bucket)
	return(vehicle)
end 

function GenPlate(buySettings)
    local plate = Config.DefaultPlate

    if not buySettings.customizePlate then 
        local split = split(buySettings.plate.format)
        plate = ''
        for k,v in pairs(split) do 
            if v == '-' then 
                plate = plate .. randomBuchstabe()
            elseif v == '.' then
                plate = plate .. randomZiffer()
            else 
                plate = plate .. v
            end 
        end 
    end 
    if IsPlateTaken(plate) and not (plate == Config.DefaultPlate)then 
        return(GenPlate(buySettings))
    end
    return(plate)
end 

function split(str)
    local buchstaben = {}

    for i = 1, #str do
        table.insert(buchstaben, str:sub(i, i))
    end
    return(buchstaben)
end

function randomBuchstabe()
    local buchstaben = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local randomIndex = math.random(1, #buchstaben)
    return buchstaben:sub(randomIndex, randomIndex)
end

function randomZiffer()
    local ziffern = "0123456789"
    local randomIndex = math.random(1, #ziffern)
    return ziffern:sub(randomIndex, randomIndex)
end

function IsPlateTaken(plate)
	local p = promise.new()
	ESX.TriggerServerCallback('fvehicleshop:isPlateTaken', function(isPlateTaken)
        print(isPlateTaken)
		p:resolve(isPlateTaken)
	end, plate)
	return Citizen.Await(p)
end

function GetSettings(shop)
    local returnSettings = {}
    if shop.buy.customizeColor or shop.buy.customizePlate then 
        local settings = {}
        if shop.buy.customizeColor then 
            table.insert(settings, {type = 'color', label = locales['admin_color'][1], description = locales['admin_color'][2], required = true, format = 'hex'})
        end 
        if shop.buy.customizePlate then 
            table.insert(settings, {type = 'input', label = locales['admin_plate'][1], description = locales['admin_plate'][2], required = true})
        end 

        local input = lib.inputDialog(locales['configure'][1], settings, {allowCancel = false})
        returnSettings = input
    end 

    if IsPlateTaken(returnSettings[2]) then 
	Config.Notifcation(locales['plate_exists'])
        return(GetSettings(shop))
    end
    return(returnSettings)
end 
