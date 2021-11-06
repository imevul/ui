local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

--[[
Class Direction
]]--
local Direction = ui.lib.class(function()

end)

Direction.VERTICAL = 1
Direction.HORIZONTAL = 2

return Direction
