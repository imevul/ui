local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Button
Builds on top of the Text class, but also draws an outline
]]--
local Button = ui.lib.class(ui.modules.Text,function(this, data)
	ui.modules.Text.init(this, data)

	data = data or {}
	this.color = data.color or nil
	this.type = 'Button'
end)

function Button:_draw()
	gfx.setBackgroundColor(self.color or self.config.theme.primary)
	gfx.clear()
	gfx.setColor(self.color or self.config.theme.primary)
	gfx.rect('fill', 0, 0, self.width, self.height)
	ui.modules.Text._draw(self)
	gfx.setColor(self.config.theme.text)
	gfx.setBackgroundColor(self.config.theme.background)
end

return Button
