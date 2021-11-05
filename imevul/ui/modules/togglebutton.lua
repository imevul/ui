local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class ToggleButton
Toggle on or off
]]--
local ToggleButton = ui.lib.class(ui.modules.Checkbox, function(this, data)
	data = data or {}
	this.prefix    = '(     )'
	this.prefixOn  = '( ON *)'
	this.prefixOff = '(* OFF)'
	data.text = data.text or ''
	data.text = this.prefix .. ' ' .. data.text
	ui.modules.Text.init(this, data)

	data.value = data.value or false

	this.value = data.value
	this.type = 'ToggleButton'
end)

function ToggleButton:_draw()
	self:setText(self.text)

	ui.modules.Text._draw(self)

	if self.value then
		gfx.setBackgroundColor(colors.lime)
	else
		gfx.setBackgroundColor(colors.red)
	end

	if self.focused then
		gfx.setColor(self.config.theme.focusedText or colors.black)
	else
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

return ToggleButton
