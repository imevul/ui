local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class App : Container The main container for the application. Owns the event loop and presents the screen.
local App = ui.lib.class(ui.modules.Container, function(this, data)
	data = data or {}
	local termSize = {term.getSize()}
	data.width = data.width or termSize[1] or 51
	data.height = data.height or termSize[2] or 19

	local defaultTheme = {
		primary = colors.cyan,
		secondary = colors.red,
		text = colors.white,
		focusedText = colors.black,
		focusedBackground = colors.white,
		blurredBackground = colors.lightGray,
		background = colors.black,
	}
	data.config = data.config or {}
	data.config.theme = data.config.theme or {}
	for key, value in pairs(defaultTheme) do
		if data.config.theme[key] == nil then
			data.config.theme[key] = value
		end
	end

	data.callbacks = data.callbacks or {}

	ui.modules.Container.init(this, data)

	this.type = 'App'
	this.width = data.width
	this.height = data.height

	this.config = data.config
	this.callbacks = data.callbacks
	this._shiftHeld = false
end)

---@see Object#resize
function App:resize(width, height)
	ui.modules.Object.resize(self, width, height)
	self:update()
end

---Blur the tree and focus the ancestor chain down to target
---@public
---@param target Object|nil
function App:setFocus(target)
	self:_blur()
	if not target then
		return
	end

	local chain = {}
	local node = target
	while node do
		table.insert(chain, 1, node)
		node = node.parent
	end

	for _, obj in ipairs(chain) do
		ui.modules.Object._focus(obj)
	end
end

---Deepest focused descendant, or nil
---@public
---@return Object|nil
function App:getFocusedLeaf()
	local node = self
	local leaf = nil
	while node do
		local child = nil
		if node.objectsReverse then
			for _, obj in ipairs(node.objectsReverse) do
				if obj.ref.focused then
					child = obj.ref
					break
				end
			end
		end
		if child then
			leaf = child
			node = child
		else
			break
		end
	end
	return leaf
end

---Topmost visible modal, if any
---@protected
---@return Object|nil
function App:_findTopModal()
	local function findModal(container)
		if not container.objectsReverse then
			return nil
		end
		for _, obj in ipairs(container.objectsReverse) do
			if obj.ref.visible and obj.ref.type == 'ModalWindow' then
				return obj.ref
			end
			local nested = findModal(obj.ref)
			if nested then
				return nested
			end
		end
		return nil
	end
	return findModal(self)
end

---Focus ring root: top modal if shown, otherwise the app
---@protected
---@return Object
function App:_focusRoot()
	return self:_findTopModal() or self
end

---Move keyboard focus to the next focusable widget
---@public
function App:focusNext()
	local list = self:_focusRoot():collectFocusable({})
	if #list == 0 then
		return
	end
	local current = self:getFocusedLeaf()
	local idx = 0
	for i, obj in ipairs(list) do
		if obj == current then
			idx = i
			break
		end
	end
	self:setFocus(list[(idx % #list) + 1])
end

---Move keyboard focus to the previous focusable widget
---@public
function App:focusPrev()
	local list = self:_focusRoot():collectFocusable({})
	if #list == 0 then
		return
	end
	local current = self:getFocusedLeaf()
	local idx = 0
	for i, obj in ipairs(list) do
		if obj == current then
			idx = i
			break
		end
	end
	local prev = idx - 1
	if prev < 1 then
		prev = #list
	end
	self:setFocus(list[prev])
end

---First visible default Button under the focused window, else under the app
---@protected
---@return Object|nil
function App:_findDefaultButton()
	local function findDefault(container)
		if not container.objects then
			return nil
		end
		for _, obj in ipairs(container.objects) do
			local ref = obj.ref
			if ref.visible and ref.default and ref.click then
				return ref
			end
			local nested = findDefault(ref)
			if nested then
				return nested
			end
		end
		return nil
	end

	local leaf = self:getFocusedLeaf()
	local window = leaf
	while window and window.type ~= 'Window' and window.type ~= 'ModalWindow' do
		window = window.parent
	end
	return findDefault(window or self)
end

---@see Object#_keyPressed
function App:_keyPressed(key, keyCode)
	if key == 'leftShift' or key == 'rightShift' then
		self._shiftHeld = true
	end
	if key == 'tab' then
		if self._shiftHeld then
			self:focusPrev()
		else
			self:focusNext()
		end
		return
	end
	ui.modules.Container._keyPressed(self, key, keyCode)
end

---@see Object#_keyReleased
function App:_keyReleased(key, keyCode)
	if key == 'leftShift' or key == 'rightShift' then
		self._shiftHeld = false
	end
	if key == 'escape' then
		local modal = self:_findTopModal()
		if modal then
			modal:setVisible(false)
			return
		end
		local node = self:getFocusedLeaf()
		while node do
			if (node.type == 'Window' or node.type == 'ModalWindow') and node.closable then
				node:close()
				return
			end
			node = node.parent
		end
		return
	end
	if key == 'enter' then
		local leaf = self:getFocusedLeaf()
		if not leaf or leaf.type ~= 'Input' then
			local btn = self:_findDefaultButton()
			if btn then
				btn:click()
				return
			end
		end
	end
	ui.modules.Container._keyReleased(self, key, keyCode)
end

---@see Object#draw
function App:_draw()
	gfx.setBackgroundColor((self.config.theme and self.config.theme.background) or colors.black)
	gfx.clear()

	ui.modules.Container._draw(self)
end

---Blit the app canvas to the terminal
---@protected
function App:_present()
	if not self.canvas then
		self:createCanvas()
	end
	if not self.canvas then
		return
	end
	gfx.setCanvas(self.canvas)
	self:_draw()
	gfx.present(self.canvas)
end

---Initialize the app and start the main event loop
---@public
function App:initialize()
	self._running = true
	self:_load()
	self:_present()

	local period = 0.05
	local timer = os.startTimer(period)

	while self._running do
		local event, a, b, c, d, e = os.pullEvent()

		if event == 'timer' and a == timer then
			self:_update(period)
			self:_present()
			timer = os.startTimer(period)
		elseif event == 'key' then
			self:_keyPressed(keys.getName(a) or tostring(a), a)
		elseif event == 'key_up' then
			self:_keyReleased(keys.getName(a) or tostring(a), a)
		elseif event == 'char' then
			self:_textInput(a)
		elseif event == 'mouse_click' then
			self:_mousePressed(b - 1, c - 1, a)
		elseif event == 'mouse_up' then
			self:_mouseReleased(b - 1, c - 1, a)
		elseif event == 'mouse_drag' then
			self:_mouseDrag(b - 1, c - 1, a)
		elseif event == 'mouse_scroll' then
			self:_mouseScroll(b - 1, c - 1, a)
		elseif event == 'term_resize' then
			local tw, th = term.getSize()
			self:resize(tw, th)
			self:_eventHandler(event, a, b, c, d, e)
			self:_present()
		else
			self:_eventHandler(event, a, b, c, d, e)
		end
	end

	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1, 1)
end

---Quit the app
---@public
function App:quit()
	self._running = false
end

---Called as part of the main event loop
function App:_update(dt)
	ui.modules.Container.update(self)
	if self.callbacks.update then
		self.callbacks.update(self, dt)
	end
end

---Called when the app has finished loading
function App:_load()
	if self.callbacks.load then
		self.callbacks.load(self)
	end
end

---Called for any non-standard event
function App:_eventHandler(event, a, b, c, d, e)
	if self.callbacks[event] then
		self.callbacks[event](self, a, b, c, d, e)
	end
end

return App
