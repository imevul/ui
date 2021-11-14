local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class ListLayout : Layout Automatically arranges elements vertically
---@field direction number
local ListLayout = ui.lib.class(ui.modules.Layout, function(this, data)
	ui.modules.Layout.init(this, data)

	data = data or {}
	this.direction = data.direction or ui.modules.Direction.VERTICAL
	this.type = 'ListLayout'
end)

---@see Layout#update
function ListLayout:update(objects, container)
	ui.modules.Layout.update(self, objects)

	if not self.container then
		self.container = container
	end

	if objects then
		local x = 0
		local y = 0

		if self.container and self.container.padding and self.container.padding > 0 then
			x = self.container.padding
			y = self.container.padding
		end

		for _, obj in pairs(objects) do
			if not obj.ref.absolute then
				obj.x = x
				obj.y = y

				if self.direction == ui.modules.Direction.VERTICAL then
					y = y + (obj.ref.height or 1) + self.spacing
				else
					x = x + (obj.ref.width or 1) + self.spacing
				end
			end
		end
	end
end

return ListLayout
