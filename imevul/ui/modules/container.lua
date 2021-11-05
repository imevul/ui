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
	this.objectsReverse = {}
	this.type = 'Container'
	this.overwrite = data.overwrite or true
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
	gfx.currentCanvas.surface.overwrite = self.overwrite
	for _, obj in pairs(self.objects) do
		if obj.ref.visible then
			obj.ref:_render()
			gfx.draw(obj.ref.canvas, obj.x, obj.y)
		end
	end
end

function Container:_keyPressed(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_keyPressed(key, keyCode)
			break
		end
	end
end

function Container:_keyReleased(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_keyReleased(key, keyCode)
			break
		end
	end
end

function Container:_mousePressed(x, y, button)
	ui.modules.Object._mousePressed(self, x, y, button)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx >= 0 and ry >= 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
				obj.ref:_focus()
				obj.ref:_mousePressed(rx, ry, button)

				if obj.ref.opaque then
					consumed = true
				end
			else
				obj.ref:_blur()
			end

			-- Handle modal components
			if obj.ref.drawOrder == 1/0 then
				consumed = true
			end
		end
	end
end

function Container:_mouseReleased(x, y, button)
	ui.modules.Object._mouseReleased(self, x, y, button)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
				obj.ref:_focus()
				obj.ref:_mouseReleased(rx, ry, button)

				if obj.ref.opaque then
					consumed = true
				end
			else
				obj.ref:_blur()
			end

			-- Handle modal components
			if obj.ref.drawOrder == 1/0 then
				consumed = true
			end
		end
	end
end

function Container:_textInput(char)
	ui.modules.Object._textInput(self, char)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_textInput(char)
			break
		end
	end
end

function Container:_blur()
	ui.modules.Object._blur(self)

	for _, obj in pairs(self.objectsReverse) do
		obj.ref:_blur()
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

	object.parent = self
	object:_inheritConfig(self.config)
	table.insert(self.objects, obj)

	self:_sortComponents(self.objects)
	self:_copyReverse()
end

function Container:remove(object)
	for i, obj in ipairs(self.objects) do
		if obj.ref == object then
			object.parent = nil
			table.remove(self.objects, i)
			self:_copyReverse()
			break
		end
	end
end

function Container:_copyReverse()
	self.objectsReverse = {}
	for k,v in pairs(self.objects) do
		self.objectsReverse[k] = v
	end

	self:_sortComponents(self.objectsReverse, true)
end

function Container:_sortComponents(array, reverse)
	reverse = reverse or false

	-- Sort objects for drawing
	table.sort(array, function (left, right)
		if left.ref.drawOrder and right.ref.drawOrder then
			if reverse then
				return left.ref.drawOrder > right.ref.drawOrder
			else
				return left.ref.drawOrder < right.ref.drawOrder
			end
		end

		if left.ref.id and right.ref.id then
			if reverse then
				return left.ref.id > right.ref.id
			else
				return left.ref.id < right.ref.id
			end
		end
	end)
end

return Container
