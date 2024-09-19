fx_version  'cerulean'
game        'gta5'
lua54       'yes'

author      'xJoww'
description 'Simple handmade Billing System with ESX and Ox Lib, learn more at https://github.com/xJoww/'
version     '1.0'

shared_scripts {

    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "shared/config.lua"
}

server_scripts {

	"@oxmysql/lib/MySQL.lua",
    "server/*.lua"
}

client_script   'client/*.lua'