local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Bar
Basic "progress bar" style meter
]]--
local Bar = ui.lib.class(ui.modules.Object, function(this, data)
	ui.modules.Object.init(this, data)

	data = data or {}
	data.value = data.value or 0
	data.maxValue = data.maxValue or 100
	data.color = data.color or nil
	data.gradient = data.gradient or 0
	assert(data.maxValue > 0, 'MaxValue must be higher than 0')

	this.value = data.value
	this.maxValue = data.maxValue
	this.color = data.color
	this.gradient = data.gradient
	this.type = 'Bar'
end)

function Bar:_draw()
	local fillPercent = math.min(1.0, math.max(0.0, self.value * 1.0 / self.maxValue))

	gfx.setBackgroundColor(self.background or self.config.theme.blurredBackground)
	gfx.clear()

	local color = self.color or self.config.theme.primary
	if self.gradient > 0 then
		if fillPercent < 0.3 then
			color = colors.red
		elseif fillPercent < 0.5 then
			color = colors.orange
		elseif fillPercent < 0.8 then
			color = colors.yellow
		else
			color = colors.lime
		end
	elseif self.gradient < 0 then
		if fillPercent > 0.7 then
			color = colors.red
		elseif fillPercent > 0.5 then
			color = colors.orange
		elseif fillPercent > 0.3 then
			color = colors.yellow
		else
			color = colors.lime
		end
	end

	gfx.setColor(color)
	gfx.rect('fill', 0, 0, math.floor(self.width * fillPercent), self.height)
	gfx.setBackgroundColor(self.config.theme.background)
end

return Bar
