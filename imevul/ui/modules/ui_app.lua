local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class App : Container Top-level container. Owns os.pullEvent, presents the screen, and dispatches callbacks.
---App callbacks: load, update(dt), keyPressed, keyReleased, mousePressed, mouseReleased, mouseDrag, mouseScroll, textInput.
---callbacks.event(app, event, ...) fires on every pulled event (for example a VTerm handleEvent/forwardEvent hook).
---Other event names (term_resize, rednet_message, …) are forwarded through _eventHandler as callbacks[event].
---monitor = true uses the first monitor (or the next one that attaches). monitor = 'left' uses that name.
---monitor may also be a term-like object (CC window, later a VTerm). Nil keeps term.current().
---Do not set monitor if you already redirected to a VTerm that owns the screen; snapshot fallback is term.current().
---@field public monitor boolean|string|table|nil
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
	if data.padding == nil then
		data.padding = 0
	end

	ui.modules.Container.init(this, data)

	this.type = 'App'
	this.width = data.width
	this.height = data.height

	this.config = data.config
	this.callbacks = data.callbacks
	this.monitor = data.monitor
	this._fallback = term.current()
	this._outputName = nil
	this._outputTerm = nil
	this._shiftHeld = false
	this._hoverTarget = nil
	this._hoverSince = 0
	this._tooltipOwner = nil
	this._tooltipBubble = nil
	this._tooltipSource = nil
end)

local function isTermLike(obj)
	return type(obj) == 'table' and type(obj.getSize) == 'function'
end

---Redirect to a term-like object and resize the app to it
---@protected
---@param termObj table
---@param name string|nil Peripheral name when App owns a monitor
function App:_adoptOutput(termObj, name)
	if not isTermLike(termObj) then
		return
	end
	term.redirect(termObj)
	self._outputTerm = termObj
	self._outputName = name
	local tw, th = termObj.getSize()
	self:resize(tw, th)
end

---Redirect back to the term.current() snapshot from construct
---@protected
function App:_restoreFallback()
	local fallback = self._fallback or term.native()
	term.redirect(fallback)
	self._outputTerm = nil
	self._outputName = nil
	local tw, th = fallback.getSize()
	self:resize(tw, th)
end

---Whether this App should adopt the named monitor
---@protected
---@param name string
---@return boolean
function App:_wantsMonitor(name)
	if not name then
		return false
	end
	if self.monitor == true then
		return self._outputName == nil
	end
	return self.monitor == name
end

---Wrap and adopt a monitor peripheral if it matches the monitor option
---@protected
---@param name string
function App:_tryAdoptNamed(name)
	if not name or not self:_wantsMonitor(name) then
		return
	end
	if not peripheral or not peripheral.getType or peripheral.getType(name) ~= 'monitor' then
		return
	end
	local wrap = peripheral.wrap(name)
	if wrap then
		self:_adoptOutput(wrap, name)
	end
end

---Adopt a configured term object or an already-present monitor before the event loop
---@protected
function App:_adoptConfiguredOutput()
	if isTermLike(self.monitor) then
		self:_adoptOutput(self.monitor, nil)
		return
	end
	if self.monitor == true and peripheral and peripheral.getNames then
		for _, name in ipairs(peripheral.getNames()) do
			if peripheral.getType(name) == 'monitor' then
				self:_tryAdoptNamed(name)
				if self._outputName then
					return
				end
			end
		end
		return
	end
	if type(self.monitor) == 'string' then
		self:_tryAdoptNamed(self.monitor)
	end
end

---Ignore computer mouse while painting on a named monitor
---@protected
---@return boolean
function App:_usingNamedMonitor()
	return self._outputName ~= nil
end

---Show the single app tooltip bubble under owner
---@public
---@param owner Object
---@param text string|nil
---@param source string|nil
function App:showTooltip(owner, text, source)
	self:hideTooltip()
	text = text or (owner and owner.tooltip) or ''
	if not owner or text == '' then
		return
	end

	local label = ui.modules.Text({
		text = text,
		color = self.config.theme.focusedText or colors.black
	})
	local width = math.min((#text) + 2, self.width or (#text + 2))
	local bubble = ui.modules.Panel({
		width = width,
		height = 1,
		padding = 0,
		background = self.config.theme.focusedBackground or colors.white,
		absolute = true,
		drawOrder = 100000,
		items = { label }
	})

	local ox, oy = 0, 0
	if owner.getPositionIn and owner ~= self then
		ox, oy = owner:getPositionIn(self)
	end
	local px = ox
	local py = oy + (owner.height or 1)
	if px + width > (self.width or width) then
		px = (self.width or width) - width
	end
	if py + 1 > (self.height or 1) then
		py = oy - 1
	end
	if px < 0 then
		px = 0
	end
	if py < 0 then
		py = 0
	end

	self._tooltipOwner = owner
	self._tooltipSource = source or 'focus'
	self._tooltipBubble = bubble
	self:add(bubble, px, py)
end

---Remove the tooltip bubble if present
---@public
function App:hideTooltip()
	if self._tooltipBubble then
		if self._tooltipBubble.parent then
			self:remove(self._tooltipBubble)
		end
		self._tooltipBubble = nil
		self._tooltipOwner = nil
		self._tooltipSource = nil
	end
end

function App:_tooltipAt(x, y)
	if not self.hitTest then
		return nil
	end
	local hit = self:hitTest(x, y)
	if hit and hit.tooltip and hit.tooltip ~= '' then
		return hit
	end
	return nil
end

function App:_mouseMove(x, y)
	local target = self:_tooltipAt(x, y)
	if target ~= self._hoverTarget then
		self._hoverTarget = target
		self._hoverSince = os.clock()
		if not target and self._tooltipSource == 'hover' then
			self:hideTooltip()
		end
	end
end

---@see Object#resize
function App:resize(width, height)
	ui.modules.Object.resize(self, width, height)
	self:update()
end

---Blur the tree and focus the ancestor chain down to target. Nil target clears focus.
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

---Widget under the click for focus, or false if a modal ate an outside click
---@protected
---@param x number
---@param y number
---@return Object|nil|boolean
function App:_focusTargetAt(x, y)
	local modal = self:_findTopModal()
	if modal then
		local mx, my = 0, 0
		if modal.getPositionIn and modal ~= self then
			mx, my = modal:getPositionIn(self)
		end
		local mw = modal.width or 0
		local mh = modal.height or 0
		if x < mx or y < my or x >= mx + mw or y >= my + mh then
			return false
		end
		if modal.hitTest then
			return modal:hitTest(x - mx, y - my) or modal
		end
		return modal
	end
	if self.hitTest then
		return self:hitTest(x, y)
	end
	return nil
end

---Click empty space or chrome to clear focus; clicks outside a modal leave its focus alone
---@see Object#_mousePressed
function App:_mousePressed(x, y, button)
	local target = self:_focusTargetAt(x, y)
	if target ~= false and (not target or not target.focusable) then
		self:setFocus(nil)
	end
	ui.modules.Container._mousePressed(self, x, y, button)
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

---Tab / Shift-Tab move the focus ring
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

---Escape hides a modal or closes a closable window; Enter clicks the default Button
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
		if not leaf or (leaf.type ~= 'Input' and leaf.type ~= 'NumberField') then
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
	if self.canvas then
		self.canvas.overwrite = true
	end

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
	self:_adoptConfiguredOutput()
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
			if not self:_usingNamedMonitor() then
				self:_mousePressed(b - 1, c - 1, a)
			end
		elseif event == 'mouse_up' then
			if not self:_usingNamedMonitor() then
				self:_mouseReleased(b - 1, c - 1, a)
			end
		elseif event == 'mouse_drag' then
			if not self:_usingNamedMonitor() then
				self:_mouseDrag(b - 1, c - 1, a)
			end
		elseif event == 'mouse_scroll' then
			if not self:_usingNamedMonitor() then
				self:_mouseScroll(b - 1, c - 1, a)
			end
		elseif event == 'mouse_move' then
			if not self:_usingNamedMonitor() then
				if c ~= nil then
					self:_mouseMove(b - 1, c - 1)
				else
					self:_mouseMove((a or 1) - 1, (b or 1) - 1)
				end
			end
		elseif event == 'term_resize' then
			local tw, th = term.getSize()
			self:resize(tw, th)
			self:_eventHandler(event, a, b, c, d, e)
			self:_present()
		elseif event == 'peripheral' then
			self:_tryAdoptNamed(a)
			self:_eventHandler(event, a, b, c, d, e)
			self:_present()
		elseif event == 'peripheral_detach' then
			if a == self._outputName then
				self:_restoreFallback()
			end
			self:_eventHandler(event, a, b, c, d, e)
			self:_present()
		elseif event == 'monitor_touch' then
			if a == self._outputName then
				self:_mousePressed((b or 1) - 1, (c or 1) - 1, 1)
				self:_mouseReleased((b or 1) - 1, (c or 1) - 1, 1)
			end
			self:_eventHandler(event, a, b, c, d, e)
		elseif event == 'monitor_resize' then
			if a == self._outputName then
				local tw, th = term.getSize()
				self:resize(tw, th)
				self:_present()
			end
			self:_eventHandler(event, a, b, c, d, e)
		else
			self:_eventHandler(event, a, b, c, d, e)
		end

		if self.callbacks.event then
			self.callbacks.event(self, event, a, b, c, d, e)
		end
	end

	self:_restoreFallback()
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
	if self._hoverTarget and self._hoverTarget.tooltip and self._hoverTarget.tooltip ~= '' then
		if (os.clock() - (self._hoverSince or 0)) >= 0.4 then
			if self._tooltipOwner ~= self._hoverTarget then
				self:showTooltip(self._hoverTarget, nil, 'hover')
			end
		end
	end
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

---Forward unmatched events (term_resize, rednet_message, …) to callbacks[event]
function App:_eventHandler(event, a, b, c, d, e)
	if self.callbacks[event] then
		self.callbacks[event](self, a, b, c, d, e)
	end
end

return App
