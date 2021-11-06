local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class ScrollPanel
Container with a border and a title that can scroll components in and out of view
]]--
local ScrollPanel = ui.lib.class(ui.modules.Panel, function(this, data)
	ui.modules.Panel.init(this, data)

	this.type = 'ScrollPanel'
	this.offsetX = 0
	this.offsetY = 0
	this.maxWidth = this.width
	this.maxHeight = this.height
	this.scrollDirection = data.scrollDirection or ui.modules.ScrollPanel.DIR_VERTICAL
end)

ScrollPanel.DIR_VERTICAL = 0
ScrollPanel.DIR_HORIZONTAL = 1


function ScrollPanel:_drawObjects()
	gfx.currentCanvas.surface.overwrite = self.overwrite
	for _, obj in pairs(self.objects) do
		if obj.ref.visible then
			obj.ref:_render()
			gfx.draw(obj.ref.canvas, obj.x - self.offsetX, obj.y - self.offsetY)
		end
	end
end

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
end

function ScrollPanel:_mousePressed(x, y, button)
	ui.modules.Panel._mousePressed(self, x + self.offsetX, y + self.offsetY, button)
end

function ScrollPanel:_mouseReleased(x, y, button)
	ui.modules.Panel._mouseReleased(self, x + self.offsetX, y + self.offsetY, button)
end

function ScrollPanel:_mouseDrag(x, y, button)
	ui.modules.Panel._mouseDrag(self, x + self.offsetX, y + self.offsetY, button)
end

function ScrollPanel:_mouseScroll(x, y, direction)
	ui.modules.Panel._mouseScroll(self, x + self.offsetY, y + self.offsetY, direction)

	if self.scrollDirection == ScrollPanel.DIR_VERTICAL then
		self:scrollY(direction)
	else
		self:scrollX(direction)
	end
end

function ScrollPanel:add(object, x, y)
	ui.modules.Panel.add(self, object, x, y)

	self:_updateSize()
end

function ScrollPanel:remove(object)
	ui.modules.Panel.remove(self, object)

	self:_updateSize()
end

function ScrollPanel:_updateSize()
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

function ScrollPanel:scrollX(amount)
	self.offsetX = math.min(self.maxWidth, math.max(0, self.offsetX + amount))

	if self.callbacks.onScroll then
		self.callbacks.onScroll(self, self.offsetX, self.offsetY, amount, 0)
	end
end

function ScrollPanel:scrollY(amount)
	self.offsetY = math.min(self.maxHeight, math.max(0, self.offsetY + amount))

	if self.callbacks.onScroll then
		self.callbacks.onScroll(self, self.offsetX, self.offsetY, 0, amount)
	end
end

return ScrollPanel
