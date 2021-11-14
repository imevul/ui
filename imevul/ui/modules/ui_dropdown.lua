local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

---@class DropDown : Button Builds on top of the Button class. Shows a drop-down menu (List) when clicked
---@field public owner Container Object that should contain the menu
---@field protected _menu List
local DropDown = ui.lib.class(ui.modules.Button, function(this, data)
	ui.modules.Button.init(this, data)

	data = data or {}
	data.owner = data.owner or nil
	this.owner = data.owner
	this.type = 'DropDown'

	data.items = data.items or {}
	local totalItemHeight = 0
	local itemWidth = this.width
	for _, item in pairs(data.items) do
		totalItemHeight = totalItemHeight + item.height
		itemWidth = math.max(itemWidth, item.width)
	end

	this._menu = ui.modules.List({
		width = math.max(1, itemWidth),
		height = math.max(1, totalItemHeight),
		padding = 0,
		items = data.items,
		scrollbar = false,
		background = colors.gray,
		drawOrder = 99999,
		absolute = true,
		callbacks = {
			onBlur = function(_)
				this:hideMenu()
			end
		}
	})
end)

---Show the DropDown menu
---@public
function DropDown:showMenu()
	self:hideMenu()

	if not self.owner then
		self.owner = self.parent
	end

	if self.owner then
		local tx, ty = self:getPositionIn(self.owner)
		self.owner:add(self._menu, tx, ty + self.height)

		if self._menu.visible then
			self._menu:_focus()
		end
	end
end

---Hide the DropDown menu
---@public
function DropDown:hideMenu()
	if self.owner then
		self.owner:remove(self._menu)
	end
end

---@see Button#click
function DropDown:click()
	ui.modules.Button.click(self)
	self:showMenu()
end

return DropDown
