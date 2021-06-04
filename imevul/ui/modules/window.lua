local args = { ... }
local ui = args[1]

local Window = ui.lib.class(ui.modules.Container, function(this)
	this.colors = {
		primary = colors.cyan,
		secondary = colors.orange,
		background = colors.gray
	}

	local topParent = this:_getTopParent()
	if topParent ~= nil then
		this.theme = topParent.theme
	end
end)

function Window:_draw()
	this.canvas:renderTo(function()
		ui.lib.cobalt.graphics.setColor(this.theme.background)
		ui.lib.cobalt.graphics.rect('fill', this.x, this.y, this.width, this.height)
		ui.lib.cobalt.graphics.setColor(this.theme.primary)
		ui.lib.cobalt.graphics.rect('line', this.x, this.y, this.width, this.height)
	end)

	this:_drawObjects()
end

return Window
