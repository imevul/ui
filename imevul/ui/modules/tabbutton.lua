local args = { ... }
local ui = args[1]

--[[
Class TabButton
Builds on top of the Button class
]]--
local TabButton = ui.lib.class(ui.modules.Button, function(this, data)
	ui.modules.Button.init(this, data)

	data = data or {}
	this.originalColor = data.color or nil
	this.index = data.index or 1
	this.type = 'TabButton'
end)

return TabButton
