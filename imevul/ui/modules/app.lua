local args = { ... }
local ui = args[1]

local App = ui.lib.class(ui.modules.Container, function(this, data)
	data = data or {}
	ui.modules.Container.init(this, data)

	this.width = data.width or 51
	this.height = data.height or 19

	this.theme = data.theme or {
		text = colors.black,
		primary = colors.cyan,
		secondary = colors.orange,
		background = colors.gray
	}
end)

function App:_draw()
	ui.lib.cobalt.graphics.clear()
end

function App:initialize()
	-- Cobalt hooks
	function ui.lib.cobalt.draw()
		self:_draw()
	end

	function ui.lib.cobalt.update(dt)
		self:_update(dt)
	end

	function ui.lib.cobalt.mousereleased(x, y, button)
		self:_mouseReleased(x, y, button)
	end

	ui.lib.cobalt.init()
end

function App:_update(dt)
	if self.callbacks.update ~= nil then
		self.callbacks.update(dt)
	end
end

return App