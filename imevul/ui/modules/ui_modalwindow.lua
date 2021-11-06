local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

--[[
Class ModalWindow
Container with a border and a title that prevents all mouse events to surrounding components
]]--
local ModalWindow = ui.lib.class(ui.modules.Window, function(this, data)
	ui.modules.Window.init(this, data)

	this.type = 'ModalWindow'
	this.drawOrder = 1/0 -- +Inf
	this.absolute = true
end)

function ModalWindow:setVisible(visibility)
	ui.modules.Object.setVisible(self, visibility)

	if self.visible then
		local tlc = self:_findTopLevelComponent()
		tlc:_blur()
	end
end

return ModalWindow
