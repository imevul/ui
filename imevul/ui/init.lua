local ui = {
	config = {
		path = '/imevul/ui',
		cobaltPath = '/cobalt'
	},
	lib = {},
	modules = {}
}

-- Load libraries
ui.lib.class = dofile(ui.config.path .. '/lib/class.lua')
ui.lib.cobalt = dofile(ui.config.cobaltPath .. '/init.lua')

local loadModule = function(module)
	ui.modules[module] = loadfile(ui.config.path .. '/modules/' .. string.lower(module) .. '.lua')(ui)
	return ui.modules[module]
end

UI_Object = loadModule('Object')
UI_Container = loadModule('Container')
UI_Window = loadModule('Window')
UI_Text = loadModule('Text')
UI_Button = loadModule('Button')
UI_App = loadModule('App')

return ui
