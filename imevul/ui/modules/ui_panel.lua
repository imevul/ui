local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class Panel : Container Container with a border and a title
---@field public color string|nil
---@field public title string
---@field public border boolean
---@field public borderStyle string 'solid' (default) or 'lines'
---@field public background string|nil
local Panel = ui.lib.class(ui.modules.Container, function(this, data)
	ui.modules.Container.init(this, data)

	data = data or {}
	data.color = data.color or nil
	this.title = data.title or ''
	this.color = data.color
	this.border = data.border or false
	this.background = data.background or nil
	this.borderStyle = data.borderStyle == 'lines' and 'lines' or 'solid'
	this.type = 'Panel'
end)

---Border and title when border is enabled
---@protected
function Panel:_drawChrome()
	if not self.border then
		return
	end
	local line = self.color or self.config.theme.blurredBackground
	local fill = self.background or self.config.theme.background or colors.black
	local lined = self.borderStyle == 'lines'
	gfx.frame(0, 0, self.width, self.height, {
		borderStyle = self.borderStyle,
		color = line,
		fill = fill,
		title = self.title,
		titleColor = lined and line or (self.config.theme.focusedText or colors.black),
		titleFill = lined and fill or line,
	})
	gfx.setBackgroundColor(fill)
end

---@see Object#_draw
function Panel:_draw()
	gfx.setBackgroundColor(self.background or self.config.theme.background or colors.black)
	gfx.clear()

	self:_drawChrome()
	ui.modules.Container._draw(self)
end

return Panel
