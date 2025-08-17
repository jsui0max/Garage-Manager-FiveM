fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jsui0Max'
description ''
version '1.0'

ui_page 'html/index.html'

shared_script ({
	'@es_extended/imports.lua',
	'shared/*.lua',
	'@ox_lib/init.lua',
});

client_scripts {
	"client/**/**/*.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/**/**/*.lua'
}



files {
  'html/**'
}
