local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics
local objectId = 0

--[[
Class Object
Base object that all other UI elements inherit from.
]]--
local Object = ui.lib.class(function(this, data)
	data = data or {}
	data.width = data.width or 1
	data.height = data.height or 1
	data.callbacks = data.callbacks or {}
	data.config = data.config or {}
	assert(data.width > 0)
	assert(data.height > 0)

	objectId = objectId + 1
	this.id = objectId
	this.type = 'Object'
	this.width = data.width
	this.height = data.height
	this.visible = data.visible or true
	this.drawOrder = data.drawOrder or 0
	this.opaque = data.opaque or true
	this.config = data.config
	this.callbacks = data.callbacks
	this.focused = false
	this.canvas = gfx.newCanvas(this.width, this.height)
end)

function Object:setVisible(visibility)
	assert(type(visibility) == "boolean")
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
	self.canvas:renderTo(function()
		self:_draw()
	end)
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

function Object:_textInput(char)
	if self.callbacks.textInput then
		self.callbacks.textInput(self, char)
	end
end

function Object:__tostring()
	return self.type .. ' (' .. self.id .. ')'
end

return Object
