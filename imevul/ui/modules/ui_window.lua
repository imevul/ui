local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.graphics

---@class Window : Container Container with a border and a title
---@field public borderStyle string 'solid' (default) or 'lines'
local Window = ui.lib.class(ui.modules.Container, function(this, data)
	ui.modules.Container.init(this, data)

	data = data or {}
	data.color = data.color or nil
	this.title = data.title or ''
	this.color = data.color
	this.background = data.background or nil
	this.borderStyle = data.borderStyle == 'lines' and 'lines' or 'solid'
	this.type = 'Window'
	this.padding = data.padding or 2
	this.closable = data.closeButton and true or false

	if data.closeButton then
		this:add(ui.modules.Button({
			text = 'X',
			background = colors.red,
			absolute = true,
			callbacks = {
				onClick = function()
					this:close()
				end
			}
		}), -1, 0)
	end
end)

---Border and title. Drawn after children so overflowing content cannot eat the frame.
---@protected
function Window:_drawChrome()
	local line = self.color or self.config.theme.primary
	local fill = self.background or self.config.theme.background
	local lined = self.borderStyle == 'lines'
	gfx.frame(0, 0, self.width, self.height, {
		borderStyle = self.borderStyle,
		color = line,
		fill = fill,
		title = self.title,
		titleColor = lined and (self.config.theme.text or colors.white) or colors.white,
		titleFill = lined and fill or line,
	})
	gfx.setBackgroundColor(fill)
end

---@see Object#_draw
function Window:_draw()
	gfx.setBackgroundColor(self.background or self.config.theme.background)
	gfx.clear()

	ui.modules.Container._draw(self)
	self:_drawChrome()
end

---Close the window. This will remove it from its parent if it has one, or simply set it as not visible otherwise
---@public
function Window:close()
	if self.parent then
		self.parent:remove(self)
	else
		self:setVisible(false)
		self:_remove()
	end
end

return Window
