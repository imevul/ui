local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class Tooltip : Button "?" control that toggles the app tooltip bubble
local Tooltip = ui.lib.class(ui.modules.Button, function(this, data)
	data = data or {}
	this.helpText = data.text or ''
	data.text = data.label or '?'
	ui.modules.Button.init(this, data)
	this.type = 'Tooltip'
	this.focusable = true
end)

---@see Button#click
function Tooltip:click()
	ui.modules.Button.click(self)
	local tlc = self:_findTopLevelComponent()
	if not tlc.showTooltip then
		return
	end
	if tlc._tooltipOwner == self then
		tlc:hideTooltip()
	else
		tlc:showTooltip(self, self.helpText)
	end
end

return Tooltip
