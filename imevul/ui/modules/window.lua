local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Window
Container with a border and a title
]]--
local Window = ui.lib.class(ui.modules.Container, function(this, data)
	ui.modules.Container.init(this, data)

	data = data or {}
	data.color = data.color or nil
	this.title = data.title or ''
	this.color = data.color
	this.background = data.background or nil
	this.type = 'Window'
end)

function Window:_draw()
	gfx.setBackgroundColor(self.background or self.config.theme.background)
	gfx.clear()

	gfx.setColor(self.color or self.config.theme.primary)
	gfx.rect('line', 0, 0, self.width, self.height)
	gfx.setColor(colors.white)
	gfx.setBackgroundColor(self.color or self.config.theme.primary)
	gfx.print(self.title, math.floor((self.width - string.len(self.title)) / 2), 0)
	gfx.setBackgroundColor(self.config.theme.background)

	ui.modules.Container._draw(self)
end

return Window
