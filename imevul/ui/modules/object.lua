local args = { ... }
local ui = args[1]

local Object = ui.lib.class(function(this, data)
	data = data or {}
	this.width = data.width or 1
	this.height = data.height or 1
	this.callbacks = data.callbacks or {}
	this.canvas = ui.lib.cobalt.graphics.newCanvas(this.width, this.height)
	this.config = data.config or {}
end)

function Object:_inheritConfig(config)
	this.config = config or {}
end

function Object:_draw()
end

function Object:_mouseReleased(x, y, button)
	if self.callbacks.mouseReleased then
		self.callbacks.mouseReleased(self)
	end
end

return Object
