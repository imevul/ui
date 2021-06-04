local args = { ... }
local ui = args[1]

local Button = ui.lib.class(ui.modules.Text,function(this, data)
	data = data or {}
	ui.modules.Text.init(this, data)
end)

function Button:_draw()
	this.canvas:renderTo(function()
		ui.lib.cobalt.graphics.rect('line', 0, 0, this.width, this.height)
		ui.lib.cobalt.graphics.print(this.text, 0, 0)
	end)
end

return Button
