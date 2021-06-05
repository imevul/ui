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
	assert(data.maxValue > 0, 'MaxValue must be higher than 0')

	this.value = data.value
	this.maxValue = data.maxValue
	this.color = data.color or nil
	this.type = 'Bar'
end)

function Bar:_draw()
	local fillPercent = math.min(1.0, math.max(0.0, self.value * 1.0 / self.maxValue))
	gfx.setBackgroundColor(self.background or self.config.theme.blurredBackground)
	gfx.clear()
	gfx.setColor(self.color or self.config.theme.primary)
	gfx.rect('fill', 0, 0, math.floor(self.width * fillPercent), self.height)
	gfx.setBackgroundColor(self.config.theme.background)
end

return Bar
