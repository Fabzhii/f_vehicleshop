
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
        if shop.allowedJobs == nil then 
            openShop(shop, xGrade)
        end 

        if type(shop.allowedJobs) == 'string' then 
            if shop.allowedJobs == xJob then 
                openShop(shop, xGrade)
            end 
        end 

        if type(shop.allowedJobs) == 'table' then 
            for k,v in pairs(shop.allowedJobs) do 
                if v == xJob then 
                    openShop(shop, xGrade)
                end 
            end 
        end 
    end)
end 

function openShop(shop, xGrade)
    local categories = {}
    for k,v in pairs(shop.categories) do 

        local values = {}
        local args = {}

        getValues(v.vehicles, xGrade)
        getArgs(v.vehicles, xGrade)

        table.insert(categories, {
            label = v.label, 
            values = values, 
        })
    end 
end 

function getValues(vehicles, xGrade)
    local returnValues = {}



    return(returnValues)
end 

function getArgs(vehicles, xGrade)

end 