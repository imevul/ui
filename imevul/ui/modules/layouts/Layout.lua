local args = { ... }
local ui = args[1]

--[[
Class Layout
Base class for automatically arranging elements
]]--
local Layout = ui.lib.class(function(this, data)
	data = data or {}
	this.container = data.container or nil
	this.spacing = data.spacing or 0
	assert(this.spacing >= 0)

	this.type = 'Layout'
end)


function Layout:update(_)
end

function Layout:__tostring()
	return self.type
end

return Layout
