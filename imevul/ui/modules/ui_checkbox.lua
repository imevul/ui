local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class Checkbox : Text Input element that can be toggled on or off.
---@field public prefix string Prefix text
---@field public prefixOn string Prefix text when toggled on
---@field public prefixOff string Prefix text when toggled off
---@field public value boolean
local Checkbox = ui.lib.class(ui.modules.Text, function(this, data)
	data = data or {}
	this.prefix = this.prefix or '[ ]'
	this.prefixOn = this.prefixOn or '[X]'
	this.prefixOff = this.prefixOff or '[ ]'
	data.text = data.text or ''
	data.text = this.prefix .. ' ' .. data.text
	ui.modules.Text.init(this, data)

	data.value = data.value or false

	this.value = data.value
	this.focusable = true
	this.type = 'Checkbox'
end)

---Set the label. onChange is reserved for toggle(), so it does not fire here.
---@see Text#setText
function Checkbox:setText(newText)
	newText = tostring(newText or '')
	if self.text == newText then
		return
	end

	if newText:sub(1, string.len(self.prefix)) ~= self.prefix then
		newText = self.prefix .. ' ' .. newText
	end

	self.text = newText
	self:_resizeForText(newText)
end

---@see Object#_draw
function Checkbox:_draw()
	ui.modules.Text._draw(self)

	if self.focused then
		gfx.setBackgroundColor(self.config.theme.focusedBackground or colors.white)
		gfx.setColor(self.config.theme.focusedText or colors.black)
	else
		gfx.setBackgroundColor(self.config.theme.blurredBackground or colors.lightGray)
		gfx.setColor(self.config.theme.text or colors.white)
	end

	local tx
	local ty = math.floor(self.height / 2)

	if self.align == 'left' then
		tx = math.ceil(self.padding / 2)
	elseif self.align == 'center' then
		tx = math.floor((self.width - string.len(self.text)) / 2)
	elseif self.align == 'right' then
		tx = math.floor(self.width - self.padding / 2 - string.len(self.text))
	end

	if self.value then
		gfx.print(self.prefixOn, tx, ty)
	else
		gfx.print(self.prefixOff, tx, ty)
	end

	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

---Toggle the Checkbox on or off
function Checkbox:toggle()
	self.value = not self.value

	if self.callbacks.onChange then
		self.callbacks.onChange(self)
	end
end

---@see Object#_keyReleased
function Checkbox:_keyReleased(key, keyCode)
	ui.modules.Text._keyReleased(self, key, keyCode)
	if key == 'space' then
		self:toggle()
	end
end

---Left button only; a right-click should not flip the value
---@see Object#_mouseReleased
function Checkbox:_mouseReleased(x, y, button)
	ui.modules.Text._mouseReleased(self, x, y, button)
	if button == nil or button == 1 then
		self:toggle()
	end
end

return Checkbox
