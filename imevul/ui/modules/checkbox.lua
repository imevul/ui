local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Checkbox
Toggle on or off.
]]--
local Checkbox = ui.lib.class(ui.modules.Text, function(this, data)
	data = data or {}
	data.text = data.text or ''
	data.text = '[ ] ' .. data.text
	ui.modules.Text.init(this, data)

	data.value = data.value or false

	this.value = data.value
	this.type = 'Input'
end)

function Checkbox:setText(newText)
	if self.text == newText then
		return
	end

	local prefix = '[ ] '

	if newText:sub(0, string.len(prefix)) ~= prefix then
		newText = prefix .. newText
	end

	self.text = newText
	self:_resizeForText(newText)
end

function Checkbox:_draw()
	self:setText(self.text)

	ui.modules.Text._draw(self)

	if self.focused then
		gfx.setBackgroundColor(colors.white or self.config.theme.focusBackground)
		gfx.setColor(self.config.theme.focusedText)
	else
		gfx.setBackgroundColor(colors.lightGray or self.config.theme.blurredBackground)
		gfx.setColor(self.config.theme.text)
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
		gfx.print('X', tx + 1, ty)
	else
		gfx.print(' ', tx + 1, ty)
	end

	gfx.setBackgroundColor(colors.black or self.config.theme.background)
end

function Checkbox:toggle()
	self.value = not self.value

	if self.callbacks.onChange then
		self.callbacks.onChange(self)
	end
end

function Checkbox:_keyReleased(key)
	if key == 'space' then
		self:toggle()
	end
end

function Checkbox:_mouseReleased()
	self:toggle()
end

return Checkbox
