local args = { ... }
local ui = args[1]

local App = ui.lib.class(ui.modules.Container, function(this, data)
	this.width = data.width or 51
	this.height = data.height or 19
	this.theme = data.theme or {
		primary = colors.cyan,
		secondary = colors.orange,
		background = colors.gray
	}
end)

function App:_draw()
	ui.lib.cobalt.graphics.clear()
end

function App:init()
	-- Cobalt hooks
	function ui.lib.cobalt.draw()
		this:_draw()
	end

	function ui.lib.cobalt.update(dt)
		this:_update(dt)
	end

	function ui.lib.cobalt.mousereleased(x, y, button)
		this:_mouseReleased(x, y, button)
	end

	ui.lib.cobalt.init()
end

function App:_update(dt)
	if this.callbacks.update ~= nil then
		this.callbacks.update(dt)
	end
end

return App