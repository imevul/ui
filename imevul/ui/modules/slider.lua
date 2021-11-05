local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Slider
Input control of a slider type
]]--
local Slider = ui.lib.class(ui.modules.Bar, function(this, data)
	ui.modules.Bar.init(this, data)

	this.step = data.step or 1
	this.style = data.style or ui.modules.Slider.STYLE_SLIDER
	this.type = 'Slider'
end)

Slider.STYLE_SLIDER = 'slider'
Slider.STYLE_BAR = 'bar'

function Slider:_draw()
	if self.style == Slider.STYLE_BAR then
		ui.modules.Bar._draw(self)
		return
	end

	local fillPercent = math.min(1.0, math.max(0.0, self.value * 1.0 / self.maxValue))

	if self.focused then
		gfx.setBackgroundColor(self.config.theme.focusedBackground or colors.white)
		gfx.setColor(self.color or self.config.theme.focusedText or colors.black)
	else
		gfx.setBackgroundColor(self.config.theme.blurredBackground or colors.lightGray)
		gfx.setColor(self.color or self.config.theme.text or colors.white)
	end

	gfx.clear()

	--gfx.rect('fill', math.max(0, math.floor(self.width * fillPercent) - 1), 0, 1, 1)
	gfx.pixel(math.max(0, math.floor(self.width * fillPercent) - 1), 0)
	if self.align == 'left' then
		tx = math.ceil(self.padding / 2)
	elseif self.align == 'center' then
		tx = math.floor((self.width - string.len(self.text)) / 2)
	elseif self.align == 'right' then
		tx = math.floor(self.width - self.padding / 2 - string.len(self.text))
	end

	--gfx.print(tostring(self.value), tx, 0);
	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

function Slider:setValue(value)
	self.value = math.min(self.maxValue, math.max(0.0, value))

	if self.callbacks.onChange then
		self.callbacks.onChange(self)
	end
end

function Slider:_keyPressed(key, keyCode)
	ui.modules.Bar._keyPressed(self, key, keyCode)

	if key == 'left' then
		self:setValue(self.value - self.step)
	elseif key == 'right' then
		self:setValue(self.value + self.step)
	end
end

function Slider:_mousePressed(x, y, button)
	ui.modules.Bar._mousePressed(self, x, y, button)

	if button == 1 then
		self:setValue(math.min(1.0, math.max(0.0, x * 1.0 / self.width)) * self.maxValue)
	end
end

function Slider:_mouseDrag(x, y, button)
	ui.modules.Bar._mouseDrag(self, x, y, button)

	if button == 1 then
		self:setValue(math.min(1.0, math.max(0.0, x * 1.0 / self.width)) * self.maxValue)
	end
end

function Slider:_mouseReleased(x, y, button)
	ui.modules.Bar._mousePressed(self, x, y, button)
end

return Slider
