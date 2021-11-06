local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

--[[
Class GridLayout
Automatically arranges elements in a grid
]]--
local GridLayout = ui.lib.class(ui.modules.Layout, function(this, data)
	ui.modules.Layout.init(this, data)

	data = data or {}
	this.columns = data.columns or 0
	this.rows = data.rows or 0

	if this.columns == 0 and this.rows == 0 then
		this.columns = 2
	end

	this.type = 'GridLayout'
end)


function GridLayout:update(objects, container)
	ui.modules.Layout.update(self, objects)

	if not self.container then
		self.container = container
	end

	if objects and self.container then
		if not (self.container.width and self.container.height) then
			self.container:update(true)
		else
			for i, obj in ipairs(objects) do
				if not obj.ref.absolute then
					local x, y = self:getPosition(i, #objects)

					obj.x = x
					obj.y = y
				end
			end
		end
	end
end

function GridLayout:getPosition(index, total)
	local numColumns, numRows
	if self.columns > 0 then
		numColumns = self.columns
	else
		numColumns = math.ceil((total - 1) / self.rows)
	end

	if self.rows > 0 then
		numRows = self.rows
	else
		numRows = math.ceil(total / numColumns)
	end

	local cellWidth = self.container.width / numColumns
	local cellHeight = self.container.height / numRows
	local column = (index - 1) % numColumns
	local row = math.ceil((index - 1) / numColumns) - 1

	local x = math.min(self.container.width - 1, math.max(0, column * cellWidth))
	local y = math.min(self.container.height - 1, math.max(0, row * cellHeight))

	if tonumber(x) == nil then
		x = 0
	end

	if tonumber(y) == nil then
		y = 0
	end

	return x, y
end

return GridLayout
