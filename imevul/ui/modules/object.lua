local args = { ... }
local ui = args[1]

local Object = ui.lib.class(function(this, data)
	data = data or {}
	this.width = data.width or 1
	this.height = data.height or 1
	this.callbacks = data.callbacks or {}
	this.canvas = ui.lib.cobalt.graphics.newCanvas(this.width, this.height)
	this.parent = nil
	this.topParent = nil
end)

function Object:_getTopParent()
	if self.topParent == nil then
		local p = self.parent
		local t

		while p ~= nil do
			t = p
			p = p.parent
		end

		self.topParent = t
	end

	return self.topParent
end

function Object:_setParent(parent)
	self.parent = parent
	self:_getTopParent()
end

function Object:_draw()
end

function Object:_mouseReleased(x, y, button)
	if self.callbacks.mouseReleased then
		self.callbacks.mouseReleased(self)
	end
end

return Object
