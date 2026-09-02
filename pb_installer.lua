local args = { ... }
local version = args[1] or 'master'
local req = http.get(('https://raw.githubusercontent.com/imevul/ui/%s/install.lua'):format(version))
assert(req, 'Failed to download install.lua')
local src = req.readAll()
req.close()
local chunk = loadstring(src, 'install.lua')
assert(chunk, 'install.lua failed to compile')
chunk(version)
