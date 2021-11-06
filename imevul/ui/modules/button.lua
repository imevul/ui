local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class Button
Builds on top of the Text class, but also draws an outline
]]--
local Button = ui.lib.class(ui.modules.Text, function(this, data)
	ui.modules.Text.init(this, data)

	data = data or {}
	this.color = data.color or nil
	this.background = data.background or nil
	this.type = 'Button'
end)

function Button:_draw()
	gfx.setBackgroundColor(self.background or self.config.theme.primary or colors.cyan)
	gfx.clear()
	gfx.setColor(self.background or self.config.theme.primary or colors.cyan)
	gfx.rect('fill', 0, 0, self.width, self.height)
	gfx.setColor(self.color or self.config.theme.text or colors.white)
	ui.modules.Text._draw(self)
	gfx.setColor(self.config.theme.text or colors.white)
	gfx.setBackgroundColor(self.config.theme.background or colors.black)
end

function Button:click()
	if self.callbacks.onClick then
		self.callbacks.onClick(self)
	end
end

function Button:_keyReleased(key, keyCode)
	ui.modules.Text._keyReleased(self, key, keyCode)
	if key == 'space' then
		self:click()
	end
end

function Button:_mouseReleased(x, y, button)
	ui.modules.Text._mouseReleased(self, x, y, button)
	self:click()
end

return Button
