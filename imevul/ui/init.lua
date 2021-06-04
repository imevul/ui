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
	ui.modules[module] = loadfile(ui.config.path .. '/modules/' .. module .. '.lua')(ui)
	return ui.modules[module]
end

UI_Object = loadModule('object')
UI_Container = loadModule('container')
UI_Window = loadModule('window')
UI_Text = loadModule('text')
UI_Button = loadModule('button')
UI_App = loadModule('app')

return ui
