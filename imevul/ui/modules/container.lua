local args = { ... }
local ui = args[1]

local Container = ui.lib.class(ui.modules.Object, function(this)
	this.objects = {}
end)

function Container:_draw()
	-- Empty, since containers are just a data structure with no visual representation
	this:_drawObjects()
end

function Container:_drawObjects()
	-- Do draw their children though!
	for _, obj in pairs(this.objects) do
		obj.ref.draw()
	end

	this.canvas.renderTo(function()
		for _, obj in pairs(this.objects) do
			ui.lib.cobalt.graphics.draw(obj.ref.canvas, obj.x, obj.y)
		end
	end)
end

function Container:_mouseReleased(x, y, button)
	for _, obj in pairs(this.objects) do
		local rx = x - obj.x
		local ry = y - obj.y

		if rx >= 0 and ry >= 0 and rx < obj.ref.width and ry < obj.ref.height then
			obj.ref:_mouseReleased(rx, ry, button)
		end
	end
end

function Container:add(object, x, y)
	local obj = {
		ref = object,
		x = x,
		y = y
	}

	for _, value in pairs(this.objects) do
		if value == obj then
			return
		end
	end

	table.insert(this.objects, obj)
	object:_setParent(this)
end

return Container
