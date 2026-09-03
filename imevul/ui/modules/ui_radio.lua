local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class Radio : Checkbox Exclusive option; value is the group key (not the boolean).
local Radio = ui.lib.class(ui.modules.Checkbox, function(this, data)
	data = data or {}
	local optionValue = data.optionValue
	if optionValue == nil and data.value ~= nil and type(data.value) ~= 'boolean' then
		optionValue = data.value
		data.value = data.selected or false
	elseif data.selected ~= nil then
		data.value = data.selected and true or false
	end

	this.prefix = '( )'
	this.prefixOn = '(*)'
	this.prefixOff = '( )'
	optionValue = optionValue or data.name or data.text

	ui.modules.Checkbox.init(this, data)
	this.optionValue = optionValue
	this.type = 'Radio'
end)

---Select this radio (does not toggle off)
---@public
function Radio:select()
	if self.parent and self.parent.selectRadio then
		self.parent:selectRadio(self)
	else
		self.value = true
		if self.callbacks.onChange then
			self.callbacks.onChange(self)
		end
	end
end

---@see Checkbox#toggle
function Radio:toggle()
	self:select()
end

return Radio
