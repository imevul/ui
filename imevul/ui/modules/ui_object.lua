local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics
local objectId = 0

---@class Object Base object that all other UI elements inherit from.
---@field public id number Automatically generated ID for each object
---@field public name string The name of the object. Searchable later
---@field public parent Object Parent object, if any
---@field public type string Type of the object
---@field public width number Object width
---@field public height number Object height
---@field public visible boolean If the object should be drawn or not
---@field public drawOrder number Order in which to draw this object. Higher number means drawn later
---@field public absolute boolean True to skip layout rules
---@field public opaque boolean True to block events from passing to objects below
---@field public config table
---@field public callbacks table Any callbacks to register
---@field public focused boolean True when the object currently has focus
local Object = ui.lib.class(function(this, data)
	data = data or {}
	data.width = data.width or nil
	data.height = data.height or nil
	data.callbacks = data.callbacks or {}
	data.config = data.config or {}
	if data.visible == nil then
		data.visible = true
	end
	if data.opaque == nil then
		data.opaque = true
	end

	objectId = objectId + 1
	this.id = objectId
	this.name = data.name or nil
	this.parent = nil
	this.type = 'Object'
	this.width = data.width
	this.height = data.height
	this.visible = data.visible
	this.drawOrder = data.drawOrder or 0
	this.absolute = data.absolute or false
	this.opaque = data.opaque
	this.config = data.config
	this.callbacks = data.callbacks
	this.focused = false
	this.canvas = nil
	this:createCanvas()
end)

---Create the objects internal canvas
---@protected
function Object:createCanvas()
	local width = self.width or 0
	local height = self.height or 0

	if width > 0 and height > 0 then
		self.canvas = gfx.newCanvas(width, height)
	else
		self.canvas = nil
	end
end

---Resize object
---@public
---@param width number
---@param height number
function Object:resize(width, height)
	self.width = width
	self.height = height
	self:createCanvas()

	if self.callbacks.onResize then
		self.callbacks.onResize(self, width, height)
	end
end

---Set if the object should be drawn or not
---@public
---@param visibility boolean True to make it visible, otherwise false
function Object:setVisible(visibility)
	assert(type(visibility) == 'boolean')
	self.visible = visibility

	if self.callbacks.onSetVisible then
		self.callbacks.onSetVisible(self, visibility)
	end

	if not self.visible then
		self:_blur()
	end
end

---Inherit config from parent Container
---@param config table
function Object:_inheritConfig(config)
	self.config = config or {}
end

---Find the top-level component in the chain of parents
---@return Object
function Object:_findTopLevelComponent()
	local tlc = self
	while tlc.parent and tlc ~= tlc.parent do
		tlc = tlc.parent
	end

	return tlc
end

---Get the index of a child object
---@return number|nil
function Object:indexOf(_)
	return nil
end

---Get child object from index
---@return Object|nil
function Object:child(_)
	return nil
end

---Find a child by name
---@return Object|nil
function Object:childByName(_)
	return nil
end

---Find a sibling (object with the same parent) based on relative position
---@return Object|nil
function Object:sibling(relativePos)
	if not self.parent then
		return nil
	end

	local index = self.parent:indexOf(self)
	return self.parent:child(index + relativePos)
end

---Get the x,y position of a child object
---@return number,number
function Object:getPositionOf(_)
	return 0, 0
end

---Get the position of this object in relation to its parent
---@return number,number
function Object:getPositionIn(parent)
	assert(self ~= parent, 'Can not get position inside itself')
	local current = self
	local prev
	local xo = 0
	local yo = 0
	while current and current ~= current.parent do
		prev = current
		current = current.parent

		if current then
			local tx, ty = current:getPositionOf(prev)
			xo = xo + tx
			yo = yo + ty

			if current == parent then
				break
			end
		end
	end

	return xo, yo
end

---Draw the actual object to it's own canvas. MUST be within own canvas renderTo context!
function Object:_draw()
end

---Render the result of _draw() to the canvas
function Object:_render()
	if self.canvas then
		self.canvas:renderTo(function()
			self:_draw()
		end)
	end
end

---Focus this object
function Object:_focus()
	if not self.focused then
		self.focused = true

		if self.callbacks.onFocus then
			self.callbacks.onFocus(self)
		end
	end
end

---Unfocus this object
function Object:_blur()
	if self.focused then
		self.focused = false

		if self.callbacks.onBlur then
			self.callbacks.onBlur(self)
		end
	end
end

---Called when the object is added to a container
function Object:_add()
	if self.callbacks.onAdd then
		self.callbacks.onAdd(self)
	end
end

---Called when the object is removed from a container
function Object:_remove()
	if self.callbacks.onRemove then
		self.callbacks.onRemove(self)
	end
end

---Called when the container wants the object to update
function Object:update()
	if self.parent and self.parent.width and self.parent.height then
		local width = self.width
		local height = self.height
		local maxWidth = self.parent.width - self.parent.padding * 2
		local maxHeight = self.parent.height - self.parent.padding * 2

		if width == nil then
			width = maxWidth
		elseif width < 0 then
			width = maxWidth + width
		end

		if height == nil then
			height = maxHeight
		elseif height < 0 then
			height = maxHeight + height
		end

		self:resize(width, height)
	end
end

---Called when a keyPressed event has reached this object
---@param key string Key that was pressed
---@param keyCode number KeyCode of the key that was pressed
function Object:_keyPressed(key, keyCode)
	if self.callbacks.keyPressed then
		self.callbacks.keyPressed(self, key, keyCode)
	end
end

---Called when a keyReleased event has reached this object
---@param key string Key that was released
---@param keyCode number KeyCode of the key that was released
function Object:_keyReleased(key, keyCode)
	if self.callbacks.keyReleased then
		self.callbacks.keyReleased(self, key, keyCode)
	end
end

---Called when a mousePressed event has reached this object
---@param x number X coordinate relative to this object
---@param y number Y coordinate relative to this object
---@param button number Button that was pressed
function Object:_mousePressed(x, y, button)
	if self.callbacks.mousePressed then
		self.callbacks.mousePressed(self, x, y, button)
	end
end

---Called when a mouseReleased event has reached this object
---@param x number X coordinate relative to this object
---@param y number Y coordinate relative to this object
---@param button number Button that was released
function Object:_mouseReleased(x, y, button)
	if self.callbacks.mouseReleased then
		self.callbacks.mouseReleased(self, x, y, button)
	end
end

---Called when a mouseDrag event has reached this object
---@param x number X coordinate relative to this object
---@param y number Y coordinate relative to this object
---@param button number Button that is held
function Object:_mouseDrag(x, y, button)
	if self.callbacks.mouseDrag then
		self.callbacks.mouseDrag(self, x, y, button)
	end
end

---Called when a mouseScroll event has reached this object
---@param x number X coordinate relative to this object
---@param y number Y coordinate relative to this object
---@param direction number Direction of scroll
function Object:_mouseScroll(x, y, direction)
	if self.callbacks.mouseScroll then
		self.callbacks.mouseScroll(self, direction, x, y)
	end
end

---Called when a textInput event has reached this object
---@param char string Character that was input
function Object:_textInput(char)
	if self.callbacks.textInput then
		self.callbacks.textInput(self, char)
	end
end

---Return a string representation of this object
---@return string
function Object:__tostring()
	return self.type .. ' (' .. self.id .. ')'
end

return Object
