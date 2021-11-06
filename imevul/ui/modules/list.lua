local args = { ... }
local ui = args[1]

--[[
Class List
Container with a border and a title
]]--
local List = ui.lib.class(ui.modules.Panel, function(this, data)
	ui.modules.Panel.init(this, data)

	if data.scrollbar == nil then
		data.scrollbar = true
	end

	this.scrollbar = data.scrollbar
	local scrollbarSize = 0
	if this.scrollbar then
		scrollbarSize = 1
	end

	this._list = ui.modules.ScrollPanel({
		width = this.width - scrollbarSize,
		height = this.height,
		background = data.background or nil,
		layout = data.layout or ui.modules.ListLayout({container = this}),
		scrollDirection = ui.modules.ScrollPanel.DIR_VERTICAL,
		callbacks = {
			onScroll = function(_, _, offsetY, _, _)
				if this._slider then
					this._slider:setValue(offsetY, true)
				end
			end
		}
	})
	this:add(this._list)

	local drawOrder = 0
	if data.items then
		for _, item in pairs(data.items) do
			if data.color then
				item.color = data.color
			end
			item.drawOrder = drawOrder
			this._list:add(item)
			drawOrder = drawOrder + 1
		end
	end

	if this.scrollbar then
		this._slider = ui.modules.Slider({
			height = this.height,
			direction = ui.modules.Direction.VERTICAL,
			value = 0,
			maxValue = #data.items - this.height,
			callbacks = {
				onChange = function(_, value)
					this._list:scrollTo(0, value, true)
				end
			}
		})
		this:add(this._slider, this.width - scrollbarSize)
	end

	this.type = 'List'
end)

function List:update()
	ui.modules.Panel.update(self)

	if self._slider then
		self._slider:setMaxValue(#self._list.objects - self.height)
	end
end

return List
