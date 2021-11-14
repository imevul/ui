local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics

---@class ScrollPanel : Panel Container with a border and a title that can scroll components in and out of view
local ScrollPanel = ui.lib.class(ui.modules.Panel, function(this, data)
	ui.modules.Panel.init(this, data)

	this.type = 'ScrollPanel'
	this.offsetX = 0
	this.offsetY = 0
	this.maxWidth = this.width
	this.maxHeight = this.height

	if data.autoResize == nil then
		data.autoResize = true
	end

	this.autoResize = data.autoResize
	this.scrollDirection = data.scrollDirection or ui.modules.Direction.VERTICAL
end)

---@see Container#_drawObjects
function ScrollPanel:_drawObjects()
	gfx.currentCanvas.surface.overwrite = self.overwrite
	for _, obj in pairs(self.objects) do
		if obj.ref.visible and obj.ref.canvas then
			obj.ref:_render()
			gfx.draw(obj.ref.canvas, obj.x - self.offsetX, obj.y - self.offsetY)
		end
	end
end

---@see Object#_draw
function ScrollPanel:_draw()
	gfx.setBackgroundColor(self.background or self.config.theme.background or colors.black)
	gfx.clear()

	if self.border then
		gfx.setColor(self.color or self.config.theme.blurredBackground)
		gfx.rect('line', 0, 0, self.width, self.height)
		gfx.setColor(self.config.theme.focussedText)
		gfx.setBackgroundColor(self.color or self.config.theme.blurredBackground)
		gfx.print(self.title, math.floor((self.width - string.len(self.title)) / 2), 0)
		gfx.setBackgroundColor(self.background or self.config.theme.background or colors.black)
	end

	ui.modules.Container._draw(self)

	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

---@see Object#_mousePressed
function ScrollPanel:_mousePressed(x, y, button)
	ui.modules.Panel._mousePressed(self, x + self.offsetX, y + self.offsetY, button)
end

---@see Object#_mouseReleased
function ScrollPanel:_mouseReleased(x, y, button)
	ui.modules.Panel._mouseReleased(self, x + self.offsetX, y + self.offsetY, button)
end

---@see Object#_mouseDrag
function ScrollPanel:_mouseDrag(x, y, button)
	ui.modules.Panel._mouseDrag(self, x + self.offsetX, y + self.offsetY, button)
end

---@see Object#_mouseScroll
function ScrollPanel:_mouseScroll(x, y, direction)
	ui.modules.Panel._mouseScroll(self, x + self.offsetY, y + self.offsetY, direction)

	if self.scrollDirection == ui.modules.Direction.VERTICAL then
		self:scrollY(direction)
	else
		self:scrollX(direction)
	end
end

---@see Panel#add
function ScrollPanel:add(object, x, y)
	ui.modules.Panel.add(self, object, x, y)

	self:_updateSize()
end

---@see Panel#remove
function ScrollPanel:remove(object)
	ui.modules.Panel.remove(self, object)

	self:_updateSize()
end

---Called when the ScrollPanel needs to resize if autoResize is enabled
---@protected
function ScrollPanel:_updateSize()
	if self.autoResize and self.width and self.height then
		local width = self.width
		local height = self.height

		for _, obj in pairs(self.objects) do
			width = math.max(width, obj.x + obj.ref.width)
			height = math.max(height, obj.y + obj.ref.height)
		end

		self.maxWidth = math.max(self.width, width)
		self.maxHeight = math.max(self.height, height)

		if self.callbacks.onResize then
			self.callbacks.onResize(self, self.maxWidth, self.maxHeight)
		end
	end
end

---Scroll the panel a certain amount in the X direction
---@public
---@param amount number The amount to scroll
function ScrollPanel:scrollX(amount)
	if not (self.width and self.maxWidth) then
		return
	end
	self.offsetX = math.min(self.maxWidth - self.width, math.max(0, self.offsetX + amount))

	if self.callbacks.onScroll then
		self.callbacks.onScroll(self, self.offsetX, self.offsetY, amount, 0)
	end
end

---Scroll the panel a certain amount in the Y direction
---@public
---@param amount number The amount to scroll
function ScrollPanel:scrollY(amount)
	if not (self.height and self.maxHeight) then
		return
	end
	self.offsetY = math.min(self.maxHeight - self.height, math.max(0, self.offsetY + amount))

	if self.callbacks.onScroll then
		self.callbacks.onScroll(self, self.offsetX, self.offsetY, 0, amount)
	end
end

---Scroll the panel to a specific x, y offset
---@param x number X offset
---@param y number Y offset
---@param noEvent boolean True to not trigger an onScroll event
function ScrollPanel:scrollTo(x, y, noEvent)
	if not (self.width and self.maxWidth and self.height and self.maxHeight) then
		return
	end

	local amountX = x - self.offsetX
	local amountY = y - self.offsetY

	self.offsetX = math.min(self.maxWidth - self.width, math.max(0, x))
	self.offsetY = math.min(self.maxHeight - self.height, math.max(0, y))

	if self.callbacks.onScroll and not noEvent then
		self.callbacks.onScroll(self, self.offsetX, self.offsetY, amountX, amountY)
	end
end

return ScrollPanel
