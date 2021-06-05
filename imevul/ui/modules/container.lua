local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Container
Can hold other objects. Handles drawing any children, and passing them relevant events.
]]--
local Container = ui.lib.class(ui.modules.Object, function(this, data)
	ui.modules.Object.init(this, data)

	data = data or {}
	this.objects = {}
	this.type = 'Container'
end)

function Container:_draw()
	ui.modules.Object._draw(self)

	self:_drawObjects()
end

--[[
Draw any child objects to their own canvas, then this canvas.
MUST be within own canvas renderTo context!
]]--
function Container:_drawObjects()
	for _, obj in pairs(self.objects) do
		obj.ref:_render()
		gfx.draw(obj.ref.canvas, obj.x, obj.y)
	end
end

function Container:_keyPressed(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objects) do
		if obj.ref.focused then
			obj.ref:_keyPressed(key, keyCode)
		end
	end
end

function Container:_keyReleased(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objects) do
		if obj.ref.focused then
			obj.ref:_keyReleased(key, keyCode)
		end
	end
end

function Container:_mousePressed(x, y, button)
	ui.modules.Object._mousePressed(self, x, y, button)

	for _, obj in pairs(self.objects) do
		local rx = x - obj.x
		local ry = y - obj.y

		if rx >= 0 and ry >= 0 and rx < obj.ref.width and ry < obj.ref.height then
			obj.ref:_focus()
			obj.ref:_mousePressed(rx, ry, button)
		else
			obj.ref:_blur()
		end
	end
end

function Container:_mouseReleased(x, y, button)
	ui.modules.Object._mouseReleased(self, x, y, button)

	for _, obj in pairs(self.objects) do
		local rx = x - obj.x
		local ry = y - obj.y

		if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height then
			obj.ref:_focus()
			obj.ref:_mouseReleased(rx, ry, button)
		else
			obj.ref:_blur()
		end
	end
end

function Container:_textInput(char)
	ui.modules.Object._textInput(self, char)

	for _, obj in pairs(self.objects) do
		if obj.ref.focused then
			obj.ref:_textInput(char)
		end
	end
end

function Container:add(object, x, y)
	x = x or 0
	y = y or 0

	local obj = {
		ref = object,
		x = x,
		y = y
	}

	for _, value in pairs(self.objects) do
		if value == obj then
			error('Object already added')
			return
		end
	end

	object:_inheritConfig(self.config)
	table.insert(self.objects, obj)
end

function Container:remove(object)
	for i, obj in ipairs(self.objects) do
		if obj.ref == object then
			table.remove(self.objects, i)
		end
	end
end

return Container
