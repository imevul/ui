local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics
local objectId = 0

--[[
Class Object
Base object that all other UI elements inherit from.
]]--
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

function Object:createCanvas()
	local width = self.width or 0
	local height = self.height or 0

	if width > 0 and height > 0 then
		self.canvas = gfx.newCanvas(width, height)
	else
		self.canvas = nil
	end
end

function Object:resize(width, height)
	self.width = width
	self.height = height
	self:createCanvas()

	if self.callbacks.onResize then
		self.callbacks.onResize(self, width, height)
	end
end

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

function Object:_inheritConfig(config)
	self.config = config or {}
end

function Object:_findTopLevelComponent()
	local tlc = self
	while tlc.parent and tlc ~= tlc.parent do
		tlc = tlc.parent
	end

	return tlc
end

function Object:indexOf(_)
	return nil
end

function Object:child(_)
	return nil
end

function Object:childByName(_)
	return nil
end

function Object:sibling(relativePos)
	if not self.parent then
		return nil
	end

	local index = self.parent:indexOf(self)
	return self.parent:child(index + relativePos)
end

function Object:getPositionOf(_)
	return 0, 0
end

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

--[[
Draw the actual object to it's own canvas.
MUST be within own canvas renderTo context!
]]--
function Object:_draw()
end

--[[
Render the result of _draw() to the canvas
]]--
function Object:_render()
	if self.canvas then
		self.canvas:renderTo(function()
			self:_draw()
		end)
	end
end

function Object:_focus()
	if not self.focused then
		self.focused = true

		if self.callbacks.onFocus then
			self.callbacks.onFocus(self)
		end
	end
end

function Object:_blur()
	if self.focused then
		self.focused = false

		if self.callbacks.onBlur then
			self.callbacks.onBlur(self)
		end
	end
end

function Object:_add()
	if self.callbacks.onAdd then
		self.callbacks.onAdd(self)
	end
end

function Object:_remove()
	if self.callbacks.onRemove then
		self.callbacks.onRemove(self)
	end
end

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

function Object:_keyPressed(key, keyCode)
	if self.callbacks.keyPressed then
		self.callbacks.keyPressed(self, key, keyCode)
	end
end

function Object:_keyReleased(key, keyCode)
	if self.callbacks.keyReleased then
		self.callbacks.keyReleased(self, key, keyCode)
	end
end

function Object:_mousePressed(x, y, button)
	if self.callbacks.mousePressed then
		self.callbacks.mousePressed(self, x, y, button)
	end
end

function Object:_mouseReleased(x, y, button)
	if self.callbacks.mouseReleased then
		self.callbacks.mouseReleased(self, x, y, button)
	end
end

function Object:_mouseDrag(x, y, button)
	if self.callbacks.mouseDrag then
		self.callbacks.mouseDrag(self, x, y, button)
	end
end

function Object:_mouseScroll(x, y, direction)
	if self.callbacks.mouseScroll then
		self.callbacks.mouseScroll(self, direction, x, y)
	end
end

function Object:_textInput(char)
	if self.callbacks.textInput then
		self.callbacks.textInput(self, char)
	end
end

function Object:__tostring()
	return self.type .. ' (' .. self.id .. ')'
end

return Object
