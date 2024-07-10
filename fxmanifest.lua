fx_version 'cerulean'
game 'gta5'

author 'Mad Development'
version '1.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
}

client_scripts {
  'client/cl_*.lua',
}

server_scripts {
  'server/sv_*.lua'
}

files {
  'config/*.lua',
}
