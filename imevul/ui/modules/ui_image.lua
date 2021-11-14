local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')
local gfx = ui.lib.cobalt.graphics

---@class Image : Object Draws an image (Cobalt 2 Drawable)
---@field public source string
---@field public image cobalt.Image|cobalt.Drawable
local Image = ui.lib.class(ui.modules.Object, function(this, data)
	ui.modules.Object.init(this, data)

	data = data or {}
	this.source = data.source or nil
	this.image = nil

	if this.source then
		if fs.exists(this.source) then
			this.image = gfx.newImage(this.source)
		end
	else
		if data.image and data.image.typeOf and data.image:typeOf('Drawable') then
			this.image = data.image
		end
	end

	if this.image then
		this:resize(this.image:getWidth(), this.image:getHeight())
	end

	this.type = 'Image'
end)

---@see Object#_draw
function Image:_draw()
	gfx.setBackgroundColor(self.config.theme.background or colors.black)
	gfx.clear()
	ui.modules.Object._draw(self)

	if self.image then
		gfx.draw(self.image)
	end
end

return Image
