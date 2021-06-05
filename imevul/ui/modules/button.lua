local args = { ... }
local ui = args[1]

--[[
Class Button
Builds on top of the Text class, but also draws an outline
]]--
local Button = ui.lib.class(ui.modules.Text,function(this, data)
	data = data or {}
	this.color = data.color or nil
	ui.modules.Text.init(this, data)
end)

function Button:_draw()
	self.canvas:renderTo(function()
		ui.lib.cobalt.graphics.setColor(self.color or self.topParent.theme.primary)
		ui.lib.cobalt.graphics.rect('fill', 0, 0, self.width, self.height)
	end)

	ui.modules.Text:_draw()
end

return Button
