local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class ModalWindow : Window Container with a border and a title that prevents all mouse events to surrounding components
local ModalWindow = ui.lib.class(ui.modules.Window, function(this, data)
	ui.modules.Window.init(this, data)

	this.type = 'ModalWindow'
	this.drawOrder = 1000000
	this.absolute = true
end)

---@see Object#setVisible
function ModalWindow:setVisible(visibility)
	ui.modules.Object.setVisible(self, visibility)

	if self.visible then
		local tlc = self:_findTopLevelComponent()
		tlc:_blur()
		local first = self:firstFocusable()
		if first and tlc.setFocus then
			tlc:setFocus(first)
		end
	end
end

return ModalWindow
