local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

local function asRadio(item)
	if item and item.type == 'Radio' then
		return item
	end
	return ui.modules.Radio(item or {})
end

---@class RadioGroup : Container Exclusive group of Radio children
local RadioGroup = ui.lib.class(ui.modules.Container, function(this, data)
	data = data or {}
	data.layout = data.layout or ui.modules.ListLayout()
	if data.items then
		local items = {}
		for i, item in ipairs(data.items) do
			items[i] = asRadio(item)
		end
		data.items = items
	end

	ui.modules.Container.init(this, data)
	this.type = 'RadioGroup'
	this._value = nil

	if data.value ~= nil then
		for _, obj in ipairs(this.objects) do
			if obj.ref.type == 'Radio' then
				obj.ref.value = (obj.ref.optionValue == data.value)
			end
		end
		this._value = data.value
	else
		this:_syncFromChildren()
	end
end)

---@see Container#add
function RadioGroup:add(object, x, y)
	if type(object) == 'table' and object.type == nil then
		object = asRadio(object)
	end
	return ui.modules.Container.add(self, object, x, y)
end

function RadioGroup:_syncFromChildren()
	self._value = nil
	for _, obj in ipairs(self.objects) do
		if obj.ref.type == 'Radio' and obj.ref.value then
			self._value = obj.ref.optionValue
			break
		end
	end
end

---Select one radio and clear siblings
---@public
---@param radio Radio
function RadioGroup:selectRadio(radio)
	for _, obj in ipairs(self.objects) do
		if obj.ref.type == 'Radio' then
			obj.ref.value = (obj.ref == radio)
		end
	end
	local nextValue = radio and radio.optionValue or nil
	if self._value ~= nextValue then
		self._value = nextValue
		if self.callbacks.onChange then
			self.callbacks.onChange(self)
		end
	end
end

---@public
function RadioGroup:getValue()
	return self._value
end

---@public
function RadioGroup:setValue(value)
	for _, obj in ipairs(self.objects) do
		if obj.ref.type == 'Radio' and obj.ref.optionValue == value then
			self:selectRadio(obj.ref)
			return
		end
	end
	self:selectRadio(nil)
end

return RadioGroup
