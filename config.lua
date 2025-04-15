
Config = {}

Config.Locations = {
    {
        label = 'Polizei Fahrzeughändler',
        menu_position = 'top-left',
        blip = {
            id = 1,
            color = 1,
            scale = 0.6,
        },
        marker = {
            id = 21,
            size = 1.0,
            color = {r = 255, g = 255, b = 255, a = 120},
        },
        positions = {
            menu = vector3(-57.0939, -1096.8757, 26.4223),
            inside = vector4(-46.4101, -1096.7626, 26.4223, 202.9519),
            outside = vector4(-32.2083, -1091.3365, 26.4223, 333.2748),
        },
        buy = {
            customizeColor = true,
            customizePlate = true,
            plate = {
                minLength = 7, -- only when customizePlate
                maxLength = 7, -- only when customizePlate
                format = 'PD ---', -- - = random letter . == random number
            }
        },
        allowedJobs = {'police', 'sheriff'}, -- or nil 
        dbjob = 'police',
        categories = {
            {
                label = 'Highspeed',
                vehicles = {
                    {vehicle = 'adder', price = 12000, grade = nil}, -- grade could be nil or a number
                    {vehicle = 'zentorno', price = 12000, grade = nil},
                    {vehicle = 't20', price = 12000, grade = 3},
                },
            },
            {
                label = 'Straßenwagen',
                vehicles = {
                    {vehicle = 'jugular', price = 12000, grade = 3},
                    {vehicle = 'omnisegt', price = 12000, grade = 3},
                },
            },
        },
    },
}

Config.Language = 'DE'
Config.Locales = {
    ['DE'] = {
        ['interact'] = {'[E] - Mit %s interagieren', nil},
        ['no_money'] = {'Du hast nicht genügend Geld dabei!', 'error'},
        ['no_access'] = {'Du hast auf diesen Shop keinen Zugriff!', 'error'},
        ['plate_exists'] = {'Ein Fahrzeug mit diesem Kennzeichen existiert bereits!', 'error'},
        ['bought'] = {'Du hast das Fahrrzeug erfolgreich gekauft!', 'success'},

        ['buy_menu'] = {'Bist du sicher das du dieses Fahrzeug für %s$ kaufen möchtest?', nil},
        ['confirm'] = {'Kaufen', nil},
        ['cancel'] = {'Abbrechen', nil},

        ['configure'] = {'Fahrzeug Konfigurieren', nil},
        ['admin_player'] = {'Spieler', 'Wähle den Spieler der das Fahrzeug bekommt'},
        ['admin_vehicle'] = {'Fahrzeug', 'Wähle das Fahrzeug was der Spieler bekommt'},
        ['admin_plate'] = {'Kennzeichen', 'Wähle das Kennzeichen des Fahrzeugs'},
        ['admin_color'] = {'Spieler', 'Wähle die Farbe des Kennzeichens'},
        ['admin_dbjob'] = {'Job', 'Wähle den Datenbank Job des Fahrzeugs'},
        ['admin_spawn'] = {'Spawnen', 'Spawne das Fahrzeug beim Spieler'},

    },
    ['EN'] = {
    },
}

Config.DefaultPlate = 'DEALER'

Config.Notifcation = function(notify)
    local message = notify[1]
    local notify_type = notify[2]
    lib.notify({
        position = 'top-right',
        description = message,
        type = notify_type,
    })
end 

Config.InfoBar = function(info, toggle)
    local message = info[1]
    local notify_type = info[2]
    if toggle then 
        lib.showTextUI(message, {position = 'left-center'})
    else 
        lib.hideTextUI()
    end
end 
