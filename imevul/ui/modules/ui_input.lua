local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class Input : Text Basic input field with caret, overflow scroll, and optional maxLength.
local Input = ui.lib.class(ui.modules.Text, function(this, data)
	data = data or {}
	ui.modules.Text.init(this, data)
	this.type = 'Input'
	this.focusable = true
	this.maxLength = data.maxLength
	this.scroll = 0
	this.caret = #(this.text or '') + 1
end)

function Input:_textOrigin()
	return math.max(0, math.ceil((self.padding or 0) / 2))
end

function Input:_visibleWidth()
	local origin = self:_textOrigin()
	return math.max(1, (self.width or 1) - origin)
end

function Input:_ensureCaretVisible()
	local vis = self:_visibleWidth()
	local caretCol = self.caret - 1
	if caretCol < self.scroll then
		self.scroll = caretCol
	elseif caretCol >= self.scroll + vis then
		self.scroll = caretCol - vis + 1
	end
	if self.scroll < 0 then
		self.scroll = 0
	end
end

function Input:_clampCaret()
	local maxCaret = #(self.text or '') + 1
	if self.caret < 1 then
		self.caret = 1
	elseif self.caret > maxCaret then
		self.caret = maxCaret
	end
	self:_ensureCaretVisible()
end

function Input:_placeCaretFromX(x)
	local origin = self:_textOrigin()
	local vis = self:_visibleWidth()
	local col = math.floor(x - origin)
	if col < 0 then
		col = 0
	elseif col > vis then
		col = vis
	end
	self.caret = self.scroll + col + 1
	self:_clampCaret()
end

---Update the text value and move the caret to the end
---@public
---@param newText string
function Input:setText(newText)
	ui.modules.Text.setText(self, newText)
	self.caret = #(self.text or '') + 1
	self:_ensureCaretVisible()
end

---@see Object#_draw
function Input:_draw()
	ui.modules.Text._draw(self)

	local bg
	local fg
	if self.focused then
		bg = self.config.theme.focusedBackground or colors.white
		fg = self.config.theme.focusedText or colors.black
	else
		bg = self.config.theme.blurredBackground or colors.lightGray
		fg = self.config.theme.text or colors.white
	end

	gfx.setBackgroundColor(bg)
	gfx.setColor(fg)
	gfx.clear()

	local tx = self:_textOrigin()
	local ty = math.floor(self.height / 2)
	local vis = self:_visibleWidth()
	local shown = (self.text or ''):sub(self.scroll + 1, self.scroll + vis)
	gfx.print(shown, tx, ty)

	if self.focused and (math.floor(os.clock() * 2) % 2 == 0) then
		local cx = tx + self.caret - 1 - self.scroll
		if cx >= tx and cx < tx + vis then
			local idx = cx - tx + 1
			local ch = shown:sub(idx, idx)
			if ch == '' then
				ch = ' '
			end
			gfx.setBackgroundColor(fg)
			gfx.setColor(bg)
			gfx.print(ch, cx, ty)
		end
	end

	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

---@see Object#_focus
function Input:_focus()
	ui.modules.Object._focus(self)
	if not self.caret then
		self.caret = #(self.text or '') + 1
	end
	self:_clampCaret()
end

---@see Object#_keyPressed
function Input:_keyPressed(key, keyCode)
	ui.modules.Text._keyPressed(self, key, keyCode)

	if key == 'left' then
		self.caret = self.caret - 1
		self:_clampCaret()
	elseif key == 'right' then
		self.caret = self.caret + 1
		self:_clampCaret()
	elseif key == 'home' then
		self.caret = 1
		self:_clampCaret()
	elseif key == 'end' then
		self.caret = #(self.text or '') + 1
		self:_clampCaret()
	elseif key == 'delete' then
		local t = self.text or ''
		if self.caret <= #t then
			ui.modules.Text.setText(self, t:sub(1, self.caret - 1) .. t:sub(self.caret + 1))
			self:_clampCaret()
		end
	end
end

---@see Object#_keyReleased
function Input:_keyReleased(key, keyCode)
	ui.modules.Text._keyReleased(self, key, keyCode)

	if key == 'enter' then
		self:_blur()
		if self.callbacks.onSubmit then
			self.callbacks.onSubmit(self)
		end
	elseif key == 'backspace' then
		local t = self.text or ''
		if self.caret > 1 then
			ui.modules.Text.setText(self, t:sub(1, self.caret - 2) .. t:sub(self.caret))
			self.caret = self.caret - 1
			self:_clampCaret()
		end
	end
end

---@see Object#_textInput
function Input:_textInput(char)
	ui.modules.Text._textInput(self, char)

	local t = self.text or ''
	if self.maxLength and #t >= self.maxLength then
		return
	end

	local c = self.caret
	ui.modules.Text.setText(self, t:sub(1, c - 1) .. char .. t:sub(c))
	self.caret = c + 1
	self:_clampCaret()
end

---@see Object#_mousePressed
function Input:_mousePressed(x, y, button)
	ui.modules.Text._mousePressed(self, x, y, button)
	self:_placeCaretFromX(x)
end

---@see Object#_mouseReleased
function Input:_mouseReleased(x, y, button)
	ui.modules.Text._mouseReleased(self, x, y, button)
	self:_placeCaretFromX(x)
end

return Input
