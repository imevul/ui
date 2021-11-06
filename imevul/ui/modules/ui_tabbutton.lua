local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

--[[
Class TabButton
Builds on top of the Button class
]]--
local TabButton = ui.lib.class(ui.modules.Button, function(this, data)
	ui.modules.Button.init(this, data)

	data = data or {}
	this.originalBackground = data.background or nil
	this.index = data.index or 1
	this.type = 'TabButton'
end)

return TabButton
