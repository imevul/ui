local args = { ... }
local ui = args[1]

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
		height = this.height - tabHeight,
		background = colors.pink,
		border = false
	})}

	this.type = 'TabPanel'

	local padding = 0
	if this.border then
		padding = 1
	end

	this._tabButtons = {}
	this._tabButtonContainer = ui.modules.Panel({
		width = this.width - padding * 2,
		height = tabHeight,
		background = data.background or nil,
		border = false
	})
	this:add(this._tabButtonContainer, padding, padding)

	local tabButtonXOffset = 0
	local tabIndex = 1
	for _, tabData in pairs(this.tabs) do
		this._tabButtons[tabIndex] = ui.modules.TabButton({
			text = tabData.name,
			padding = 1,
			index = tabIndex,
			color = this.tabColor,
			callbacks = {
				onClick = function(button)
					this:switchTab(button.index)
				end
			}
		})

		this._tabButtonContainer:add(this._tabButtons[tabIndex], tabButtonXOffset, 0)
		tabButtonXOffset = tabButtonXOffset + this._tabButtons[tabIndex].width
		tabIndex = tabIndex + 1
	end

	for _, tabData in pairs(this.tabs) do
		tabData.tab:resize(this.width, this.height - tabHeight)
		tabData.tab:setVisible(false)

		this:add(tabData.tab, 0, tabHeight)
	end

	this:switchTab(1)
end)

function TabPanel:switchTab(index)
	for i, tabData in pairs(self.tabs) do
		if i == index then
			tabData.tab:setVisible(true)
			self._tabButtons[i].color = tabData.tab.background
		else
			tabData.tab:setVisible(false)
			self._tabButtons[i].color = self._tabButtons[i].originalColor
		end
	end
end

return TabPanel
