local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

--[[
Class TabPanel
Container with an optional border and a title, and multiple pages controlled by tabs
]]--
local TabPanel = ui.lib.class(ui.modules.Panel, function(this, data)
	ui.modules.Panel.init(this, data)

	local tabHeight = 3

	this.tabColor = data.tabColor or nil

	this.tabs = data.tabs or {_ = ui.modules.Panel({
		width = this.width,
	})}

	this.type = 'TabPanel'
	this.layout = ui.modules.ListLayout({ spacing = 0 })

	this._tabButtons = {}
	this._tabButtonContainer = ui.modules.Panel({
		padding = 0,
		width = this.width,
		height = tabHeight,
		background = data.background or nil,
		layout = ui.modules.ListLayout( { direction = ui.modules.Direction.HORIZONTAL, spacing = 0 })
	})
	this:add(this._tabButtonContainer)

	local tabButtonXOffset = 0
	for i, tabData in ipairs(this.tabs) do
		this._tabButtons[i] = ui.modules.TabButton({
			text = tabData.name,
			padding = 1,
			index = i,
			drawOrder = i,
			background = this.tabColor,
			callbacks = {
				onClick = function(button)
					this:switchTab(button.index)
				end
			}
		})

		this._tabButtonContainer:add(this._tabButtons[i])
		tabButtonXOffset = tabButtonXOffset + this._tabButtons[i].width
	end

	this._tabContainer = ui.modules.Panel({
		width = this.width,
		background = data.background or nil
	})
	this:add(this._tabContainer)

	for _, tabData in ipairs(this.tabs) do
		if this.width and this.height then
			tabData.tab:resize(this.width, this.height - tabHeight)
		end
		tabData.tab:setVisible(false)

		this._tabContainer:add(tabData.tab)
	end

	this:switchTab(1)
end)

function TabPanel:switchTab(index)
	for i, tabData in pairs(self.tabs) do
		if i == index then
			tabData.tab:setVisible(true)
			self._tabButtons[i].background = tabData.tab.background
		else
			tabData.tab:setVisible(false)
			self._tabButtons[i].background = self._tabButtons[i].originalBackground
		end
	end
end

return TabPanel
