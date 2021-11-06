local args = { ... }
local ui = args[1]

--[[
Class ListLayout
Automatically arranges elements vertically
]]--
local ListLayout = ui.lib.class(ui.modules.Layout, function(this, data)
	ui.modules.Layout.init(this, data)

	this.type = 'ListLayout'
end)


function ListLayout:update(objects)
	ui.modules.Layout.update(self, objects)

	if objects then
		local x = 0
		local y = 0

		for _, obj in pairs(objects) do
			obj.x = x
			obj.y = y
			y = y + obj.ref.height + self.spacing
		end
	end
end

return ListLayout
