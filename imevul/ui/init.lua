local ui = {
	config = {
		path = '/imevul/ui',
		cobaltPath = '/cobalt',
		debug = true
	},
	lib = {},
	modules = {}
}

-- Load libraries
ui.lib.class = dofile(ui.config.path .. '/lib/class.lua')
ui.lib.cobalt = dofile(ui.config.cobaltPath .. '/init.lua')

local printDebug = function(text)
	if ui.config.debug then
		print(text)
	end
end

local loadModule = function(module)
	printDebug('Loading module ' .. module)
	ui.modules[module] = loadfile(ui.config.path .. '/modules/' .. string.lower(module) .. '.lua')(ui)
	return ui.modules[module]
end

-- Make modules easily available
UI_Object = loadModule('Object')
UI_Container = loadModule('Container')
UI_Window = loadModule('Window')
UI_Text = loadModule('Text')
UI_Input = loadModule('Input')
UI_Checkbox = loadModule('Checkbox')
UI_Button = loadModule('Button')
UI_Bar = loadModule('Bar')
UI_App = loadModule('App')

return ui
