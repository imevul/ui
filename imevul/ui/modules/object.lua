local args = { ... }
local ui = args[1]

local Object = ui.lib.class(function(this, data)
	this.width = data.width
	this.height = data.height
	this.callbacks = data.callbacks or {}
	this.canvas = cobalt.graphics.newCanvas(width, height)
	this.parent = nil
end)

function Object:_getTopParent()
	local p = this.parent
	local t

	while p ~= nil do
		t = p
		p = p.parent
	end

	return t
end

function Object:_setParent(parent)
	this.parent = parent
end

function Object:_draw()
end

function Object:_mouseReleased(x, y, button)
	if this.callbacks.mouseReleased ~= nil then
		this.callbacks.mouseReleased(this)
	end
end

return Object
