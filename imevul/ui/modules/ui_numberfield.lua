local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class NumberField : Input Integer input with min/max/step and arrow keys
local NumberField = ui.lib.class(ui.modules.Input, function(this, data)
	data = data or {}
	this.min = data.min
	this.max = data.max
	this.step = data.step or 1
	local value = data.value
	if value == nil then
		value = tonumber(data.text) or 0
	end
	value = math.floor(value)
	if this.min and value < this.min then
		value = this.min
	end
	if this.max and value > this.max then
		value = this.max
	end
	data.text = tostring(value)
	ui.modules.Input.init(this, data)
	this.value = value
	this.type = 'NumberField'
	this.focusable = true
end)

---@public
function NumberField:getValue()
	return self.value
end

---@public
---@param n number
function NumberField:setValue(n)
	n = math.floor(tonumber(n) or 0)
	if self.min and n < self.min then
		n = self.min
	end
	if self.max and n > self.max then
		n = self.max
	end
	local changed = self.value ~= n
	self.value = n
	ui.modules.Input.setText(self, tostring(n))
	if changed and self.callbacks.onChange then
		self.callbacks.onChange(self)
	end
end

function NumberField:_tryParse()
	local n = tonumber(self.text)
	if n == nil or n ~= math.floor(n) then
		return
	end
	if self.min and n < self.min then
		return
	end
	if self.max and n > self.max then
		return
	end
	if self.value ~= n then
		self.value = n
		if self.callbacks.onChange then
			self.callbacks.onChange(self)
		end
	end
end

---@see Input#_textInput
function NumberField:_textInput(char)
	if char == '-' then
		if self.caret ~= 1 or ((self.text or ''):find('-', 1, true)) then
			return
		end
	elseif not tostring(char):match('^%d$') then
		return
	end
	ui.modules.Input._textInput(self, char)
	self:_tryParse()
end

---@see Input#_keyPressed
function NumberField:_keyPressed(key, keyCode)
	if key == 'up' then
		self:setValue((self.value or 0) + self.step)
		return
	elseif key == 'down' then
		self:setValue((self.value or 0) - self.step)
		return
	end
	ui.modules.Input._keyPressed(self, key, keyCode)
	if key == 'backspace' or key == 'delete' then
		self:_tryParse()
	end
end

---@see Input#_keyReleased
function NumberField:_keyReleased(key, keyCode)
	ui.modules.Input._keyReleased(self, key, keyCode)
	if key == 'backspace' then
		self:_tryParse()
	end
end

return NumberField
