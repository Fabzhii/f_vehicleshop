
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

author 'fabzhii'
description 'F-Vehicleshop by fabzhii'
version '1.0.0'

client_scripts {
    "config.lua",
    "client/*.lua",
}

server_scripts {
    "config.lua",
    "@oxmysql/lib/MySQL.lua",
    "server/*.lua" ,
}