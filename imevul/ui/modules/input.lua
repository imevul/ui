local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Input
Basic input field. Automatically updates itself, and provides callbacks for ease of use.callbacks
Callbacks include 'onSubmit', as well as 'onChang', 'onFocus', 'onBlur' from base class.
]]--
local Input = ui.lib.class(ui.modules.Text, function(this, data)
	ui.modules.Text.init(this, data)
	this.type = 'Input'
end)

function Input:_draw()
	ui.modules.Text._draw(self)

	if self.focused then
		gfx.setBackgroundColor(colors.white or self.config.theme.focusBackground)
		gfx.setColor(self.config.theme.focusedText)
	else
		gfx.setBackgroundColor(colors.lightGray or self.config.theme.blurredBackground)
		gfx.setColor(self.config.theme.text)
	end

	gfx.clear()

	local tx
	local ty = math.floor(self.height / 2)

	if self.align == 'left' then
		tx = math.ceil(self.padding / 2)
	elseif self.align == 'center' then
		tx = math.floor((self.width - string.len(self.text)) / 2)
	elseif self.align == 'right' then
		tx = math.floor(self.width - self.padding / 2 - string.len(self.text))
	end

	gfx.print(self.text, tx, ty)
end

function Input:_keyReleased(key)
	if key == 'enter' then
		self:_blur()

		if self.callbacks.onSubmit then
			self.callbacks.onSubmit(self)
		end
	end

	if key == 'backspace' then
		self:setText(self.text:sub(1, #self.text - 1))
	end
end

function Input:_textInput(char)
	ui.modules.Text._textInput(self, char)

	self:setText(self.text .. char)
end

return Input
