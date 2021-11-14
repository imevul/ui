local args = { ... }
local version = args[1] or 'master'
loadstring(http.get(('https://raw.githubusercontent.com/imevul/imevul-ui/%s/install.lua'):format(version)).readAll())()
