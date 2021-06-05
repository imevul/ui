local args = { ... }
local ui = args[1]

local Window = ui.lib.class(ui.modules.Container, function(this, data)
	ui.modules.Container.init(this, data)
end)

function Window:_draw()
	self.canvas:renderTo(function()
		ui.lib.cobalt.graphics.setColor(self.config.theme.background)
		ui.lib.cobalt.graphics.rect('fill', self.x, self.y, self.width, self.height)
		ui.lib.cobalt.graphics.setColor(self.config.theme.primary)
		ui.lib.cobalt.graphics.rect('line', self.x, self.y, self.width, self.height)
	end)

	ui.modules.Container:_draw()
end

return Window
