local args = { ... }
local ui = args[1]

local Container = ui.lib.class(ui.modules.Object, function(this, data)
	ui.modules.Object.init(this, data)
	this.objects = {}
end)

function Container:_draw()
	ui.modules.Object:_draw()

	-- Empty, since containers are just a data structure with no visual representation
	self:_drawObjects()
end

function Container:_drawObjects()
	-- Do draw their children though!
	self.objects = self.objects or {}

	for _, obj in pairs(self.objects) do
		obj.ref:_draw()
	end

	self.canvas.renderTo(function()
		for _, obj in pairs(self.objects) do
			ui.lib.cobalt.graphics.draw(obj.ref.canvas, obj.x, obj.y)
		end
	end)
end

function Container:_mouseReleased(x, y, button)
	self.objects = self.objects or {}

	for _, obj in pairs(self.objects) do
		local rx = x - obj.x
		local ry = y - obj.y

		if rx >= 0 and ry >= 0 and rx < obj.ref.width and ry < obj.ref.height then
			obj.ref:_mouseReleased(rx, ry, button)
		end
	end
end

function Container:add(object, x, y)
	self.objects = self.objects or {}

	local obj = {
		ref = object,
		x = x,
		y = y
	}

	for _, value in pairs(self.objects) do
		if value == obj then
			return
		end
	end

	table.insert(self.objects, obj)
	object:_inheritConfig(self.config)
end

return Container
