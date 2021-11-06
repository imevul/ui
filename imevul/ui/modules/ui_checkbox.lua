local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics

--[[
Class Checkbox
Toggle on or off.
]]--
local Checkbox = ui.lib.class(ui.modules.Text, function(this, data)
	data = data or {}
	this.prefix = '[ ]'
	this.prefixOn = '[X]'
	this.prefixOff = '[ ]'
	data.text = data.text or ''
	data.text = this.prefix .. ' ' .. data.text
	ui.modules.Text.init(this, data)

	data.value = data.value or false

	this.value = data.value
	this.type = 'Checkbox'
end)

function Checkbox:setText(newText)
	if self.text == newText then
		return
	end

	if newText:sub(0, string.len(self.prefix)) ~= self.prefix then
		newText = self.prefix .. ' ' .. newText
	end

	self.text = newText
	self:_resizeForText(newText)
end

function Checkbox:_draw()
	self:setText(self.text)

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

	gfx.setBackgroundColor(colors.black or self.config.theme.background)
end

function Checkbox:toggle()
	self.value = not self.value

	if self.callbacks.onChange then
		self.callbacks.onChange(self)
	end
end

function Checkbox:_keyReleased(key, keyCode)
	ui.modules.Text._keyReleased(self, key, keyCode)
	if key == 'space' then
		self:toggle()
	end
end

function Checkbox:_mouseReleased(x, y, button)
	ui.modules.Text._mouseReleased(self, x, y, button)
	self:toggle()
end

return Checkbox
