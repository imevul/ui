local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics

---@class Container : Object Can hold other objects. Handles drawing any children, and passing them relevant events.
---@field public layout Layout|nil
---@field public objects table
---@field public objectsReverse table
---@field public overwrite boolean True to completely clear its own draw region
---@field public padding number
local Container = ui.lib.class(ui.modules.Object, function(this, data)
	ui.modules.Object.init(this, data)

	data = data or {}
	this.layout = data.layout or nil
	this.objects = {}
	this.objectsReverse = {}
	this.type = 'Container'
	this.overwrite = data.overwrite or true
	this.padding = data.padding or 1

	if data.items then
		for i, item in ipairs(data.items) do
			if not item.absolute then
				if item.drawOrder == 0 or item.drawOrder then
					item.drawOrder = i
				end
			end

			this:add(item)
		end
	end
end)

---@see Object#_draw
function Container:_draw()
	ui.modules.Object._draw(self)

	self:_drawObjects()
end

---Draw any child objects to their own canvas, then this canvas. MUST be within own canvas renderTo context!
---@protected
function Container:_drawObjects()
	gfx.currentCanvas.surface.overwrite = self.overwrite
	for _, obj in pairs(self.objects) do
		if obj.ref.visible and obj.ref.canvas then
			obj.ref:_render()
			gfx.draw(obj.ref.canvas, obj.x, obj.y)
		end
	end
end

---@see Object#_keyPressed
function Container:_keyPressed(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_keyPressed(key, keyCode)
			break
		end
	end
end

---@see Object#_keyReleased
function Container:_keyReleased(key, keyCode)
	ui.modules.Object._keyReleased(self, key, keyCode)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_keyReleased(key, keyCode)
			break
		end
	end
end

---@see Object#_mousePressed
function Container:_mousePressed(x, y, button)
	ui.modules.Object._mousePressed(self, x, y, button)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
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

---@see Object#_mouseReleased
function Container:_mouseReleased(x, y, button)
	ui.modules.Object._mouseReleased(self, x, y, button)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
				if obj.ref.focused then
					obj.ref:_mouseReleased(rx, ry, button)
				end

				if obj.ref.opaque then
					consumed = true
				end
			end

			-- Handle modal components
			if obj.ref.drawOrder == 1/0 then
				consumed = true
			end
		end
	end
end

---@see Object#_mouseDrag
function Container:_mouseDrag(x, y, button)
	ui.modules.Object._mouseDrag(self, x, y, button)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
				if obj.ref.focused then
					obj.ref:_mouseDrag(rx, ry, button)
				end

				if obj.ref.opaque then
					consumed = true
				end
			end

			-- Handle modal components
			if obj.ref.drawOrder == 1/0 then
				consumed = true
			end
		end
	end
end

---@see Object#_mouseScroll
function Container:_mouseScroll(x, y, direction)
	ui.modules.Object._mouseScroll(self, x, y, direction)
	local consumed = false

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.visible then
			local rx = x - obj.x
			local ry = y - obj.y

			if rx > 0 and ry > 0 and rx <= obj.ref.width and ry <= obj.ref.height and not consumed then
				obj.ref:_mouseScroll(rx, ry, direction)

				if obj.ref.opaque then
					consumed = true
				end
			end

			-- Handle modal components
			if obj.ref.drawOrder == 1/0 then
				consumed = true
			end
		end
	end
end

---@see Object#_textInput
function Container:_textInput(char)
	ui.modules.Object._textInput(self, char)

	for _, obj in pairs(self.objectsReverse) do
		if obj.ref.focused then
			obj.ref:_textInput(char)
			break
		end
	end
end

---@see Object#_blur
function Container:_blur()
	ui.modules.Object._blur(self)

	for _, obj in pairs(self.objectsReverse) do
		obj.ref:_blur()
	end
end

---Add an object as a child to this container
---@public
---@param object Object The object to add
---@param x number X coordinate of the child object, relative to the parent
---@param y number Y coordinate of the child object, relative to the parent
---@return self
function Container:add(object, x, y)
	x = x or 0
	y = y or 0

	if x < 0 then
		x = (self.width or 0) + x
	end

	if y < 0 then
		y = (self.height or 0) + y
	end

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
	self:update()
	object:_add()

	return self
end

---Remove a child object from this container
---@public
---@param object Object Object to remove
function Container:remove(object)
	local index = 1
	for _, obj in pairs(self.objects) do
		if obj.ref == object then
			object.parent = nil
			table.remove(self.objects, index)
			self:update()
			object:_remove()
			break
		end
		index = index + 1
	end
end

---@see Object#update
function Container:update(skipLayout)
	ui.modules.Object.update(self)

	for _, obj in pairs(self.objects) do
		obj.ref:update()
	end

	self:_sortComponents(self.objects)
	self:_copyReverse()

	if self.layout and not skipLayout then
		self.layout:update(self.objects, self)
	end
end

---Caches a local copy of all child objects in reverse draw order
---@protected
function Container:_copyReverse()
	self.objectsReverse = {}
	for k,v in pairs(self.objects) do
		self.objectsReverse[k] = v
	end

	self:_sortComponents(self.objectsReverse, true)
end

---Sorts child objects based on their drawOrder
---@protected
---@param array table List of objects to sort
---@param reverse boolean True to reverse the sort order
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

---@see Object#_inheritConfig
function Container:_inheritConfig(config)
	ui.modules.Object._inheritConfig(self, config)

	for _, obj in pairs(self.objects) do
		obj.ref:_inheritConfig(config)
	end
end

---@see Object#indexOf
function Container:indexOf(child)
	for i, obj in ipairs(self.objects) do
		if obj.ref == child then
			return i
		end
	end

	return nil
end

---@see Object#child
function Container:child(index)
	for i, obj in ipairs(self.objects) do
		if i == index then
			return obj.ref
		end
	end
end

---@see Object#childByName
function Container:childByName(name, recursive)
	for _, obj in pairs(self.objects) do
		if obj.ref.name == name then
			return obj.ref
		end
	end

	if recursive then
		local result
		for _, obj in pairs(self.objects) do
			result = obj.ref:childByName(name, recursive)
			if result then
				return result
			end
		end
	end
end

---@see Object#getPositionOf
function Container:getPositionOf(child)
	for _, obj in pairs(self.objects) do
		if obj.ref == child then
			return obj.x, obj.y
		end
	end

	return ui.modules.Object.gePositionOf(child)
end

return Container
