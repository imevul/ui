local ui = {
	config = {
		path = '/imevul/ui',
		cobaltPath = '/cobalt',
		debug = true
	},
	lib = {},
	modules = {},
}

-- Load libraries
ui.lib.class = dofile(ui.config.path .. '/lib/class.lua')
ui.lib.cobalt = dofile(ui.config.cobaltPath .. '/init.lua')

ui.printDebug = function(text)
	if ui.config.debug then
		print(text)
	end
end

ui.loadModule = function(module)
	ui.printDebug('Loading module ' .. module)
	ui.modules[module] = loadfile(ui.config.path .. '/modules/' .. string.lower(module) .. '.lua')(ui)
	return ui.modules[module]
end

-- Make modules easily available
UI_Object		= ui.loadModule('Object')
UI_Container	= ui.loadModule('Container')
UI_Window		= ui.loadModule('Window')
UI_ModalWindow	= ui.loadModule('ModalWindow')
UI_Panel		= ui.loadModule('Panel')
UI_TabPanel		= ui.loadModule('TabPanel')
UI_ScrollPanel	= ui.loadModule('ScrollPanel')
UI_Text			= ui.loadModule('Text')
UI_Image		= ui.loadModule('Image')
UI_Input		= ui.loadModule('Input')
UI_Checkbox		= ui.loadModule('Checkbox')
UI_ToggleButton	= ui.loadModule('ToggleButton')
UI_Button		= ui.loadModule('Button')
UI_TabButton	= ui.loadModule('TabButton')
UI_Bar			= ui.loadModule('Bar')
UI_Slider		= ui.loadModule('Slider')
UI_App			= ui.loadModule('App')

return ui
