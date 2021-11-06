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

	if self.direction == ui.modules.Direction.HORIZONTAL then
		if self.reverse then
			gfx.pixel(math.max(0, math.floor(self.width - self.width * fillPercent) - 1), 0)
		else
			gfx.pixel(math.max(0, math.floor(self.width * fillPercent) - 1), 0)
		end
	else
		if self.reverse then
			gfx.pixel(0, math.max(0, math.floor(self.height - self.height * fillPercent) - 1))
		else
			gfx.pixel(0, math.max(0, math.floor(self.height * fillPercent) - 1))
		end
	end

	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

function Slider:setValueFromPoint(x, y)
	local percent
	if self.direction == ui.modules.Direction.HORIZONTAL then
		percent = math.min(1.0, math.max(0.0, x * 1.0 / self.width))
	else
		percent = math.min(1.0, math.max(0.0, y * 1.0 / self.height))
	end

	if self.reverse then
		percent = 1 - percent
	end

	self:setValue(math.floor(percent * self.maxValue))
end

function Slider:_keyPressed(key, keyCode)
	ui.modules.Bar._keyPressed(self, key, keyCode)
	local rv = 1
	if self.reverse then
		rv = -1
	end

	if self.direction == ui.modules.Direction.HORIZONTAL then
		if key == 'left' then
			self:setValue(self.value - self.step * rv)
		elseif key == 'right' then
			self:setValue(self.value + self.step * rv)
		end
	else
		if key == 'up' then
			self:setValue(self.value - self.step * rv)
		elseif key == 'down' then
			self:setValue(self.value + self.step * rv)
		end
	end
end

function Slider:_mousePressed(x, y, button)
	ui.modules.Bar._mousePressed(self, x, y, button)

	if button == 1 then
		self:setValueFromPoint(x, y)
	end
end

function Slider:_mouseDrag(x, y, button)
	ui.modules.Bar._mouseDrag(self, x, y, button)

	if button == 1 then
		self:setValueFromPoint(x, y)
	end
end

return Slider
