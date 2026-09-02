local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class Button : Text Builds on top of the Text class, but also draws an outline and provides an onClick event
---@field public color string Text color of the button
---@field public background string Background color of the button
local Button = ui.lib.class(ui.modules.Text, function(this, data)
	ui.modules.Text.init(this, data)

	data = data or {}
	this.color = data.color or nil
	this.background = data.background or nil
	this.default = data.default or false
	this.focusable = true
	this.type = 'Button'
end)

---@see Object#_draw
function Button:_draw()
	local bg
	local fg
	if self.focused then
		bg = self.config.theme.focusedBackground or colors.white
		fg = self.config.theme.focusedText or colors.black
	else
		bg = self.background or self.config.theme.primary or colors.cyan
		fg = self.color or self.config.theme.text or colors.white
	end
	gfx.setBackgroundColor(bg)
	gfx.clear()
	gfx.setColor(bg)
	gfx.rect('fill', 0, 0, self.width, self.height)
	local oldColor = self.color
	self.color = fg
	ui.modules.Text._draw(self)
	self.color = oldColor
	gfx.setColor(self.config.theme.text or colors.white)
	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

---Called when we detect that the button should be clicked. Can also be called manually.
---@public
function Button:click()
	if self.callbacks.onClick then
		self.callbacks.onClick(self)
	end
end

---@see Object#_keyReleased
function Button:_keyReleased(key, keyCode)
	ui.modules.Text._keyReleased(self, key, keyCode)
	if key == 'space' then
		self:click()
	end
end

---@see Object#_mouseReleased
function Button:_mouseReleased(x, y, button)
	ui.modules.Text._mouseReleased(self, x, y, button)
	self:click()
end

return Button
