local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics

---@class Panel : Container Container with a border and a title
---@field public color string|nil
---@field public title string
---@field public border boolean
---@field public background string|nil
local Panel = ui.lib.class(ui.modules.Container, function(this, data)
	ui.modules.Container.init(this, data)

	data = data or {}
	data.color = data.color or nil
	this.title = data.title or ''
	this.color = data.color
	this.border = data.border or false
	this.background = data.background or nil
	this.type = 'Panel'
end)

---@see Object#_draw
function Panel:_draw()
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

return Panel
