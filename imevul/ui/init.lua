local __SRC__ = debug.getinfo(1).short_src
local __DIR__ = fs.getDir(__SRC__)

local ui = {
	config = {
		path = __DIR__,
		cobaltPath = fs.combine(__DIR__, '../../cobalt'),
		debug = false
	},
	lib = {},
	modules = {},
}

-- Load libraries
ui.lib.class = dofile(ui.config.path .. '/lib/class.lua')
ui.lib.cobalt = dofile(ui.config.cobaltPath .. '/init.lua')

---Print debug information to stdout
---@public
---@param text string
ui.printDebug = function(text)
	if ui.config.debug then
		print(text)
	end
end

---Load a module and make it available globally
---@public
---@param module string the name of the module to load
---@param subPath string Optional name of subfolder under the modules folder, if relevant
ui.loadModule = function(module, subPath)
	subPath = subPath or ''
	if #subPath > 0 then
		subPath = subPath .. '/'
	end

	local path = ui.config.path .. '/modules/' .. subPath .. 'ui_' .. string.lower(module) .. '.lua'

	ui.printDebug('Loading module ' .. module .. ' (' .. path .. ')')

	local mod = loadfile(path)
	assert(mod, 'Module ' .. module .. ' could not be loaded (' .. path .. ')')
	ui.modules[module] = mod(ui)
	return ui.modules[module]
end

-- Make modules easily available
UI_Direction	= ui.loadModule('Direction', 'enums')

UI_Layout		= ui.loadModule('Layout', 'layouts')
UI_ListLayout	= ui.loadModule('ListLayout', 'layouts')
UI_GridLayout	= ui.loadModule('GridLayout', 'layouts')

UI_Object		= ui.loadModule('Object')
UI_Container	= ui.loadModule('Container')
UI_Window		= ui.loadModule('Window')
UI_ModalWindow	= ui.loadModule('ModalWindow')
UI_Panel		= ui.loadModule('Panel')
UI_TabPanel		= ui.loadModule('TabPanel')
UI_ScrollPanel	= ui.loadModule('ScrollPanel')
UI_List			= ui.loadModule('List')
UI_Text			= ui.loadModule('Text')
UI_Image		= ui.loadModule('Image')
UI_Input		= ui.loadModule('Input')
UI_Checkbox		= ui.loadModule('Checkbox')
UI_ToggleButton	= ui.loadModule('ToggleButton')
UI_Button		= ui.loadModule('Button')
UI_TabButton	= ui.loadModule('TabButton')
UI_DropDown		= ui.loadModule('DropDown')
UI_Bar			= ui.loadModule('Bar')
UI_Slider		= ui.loadModule('Slider')
UI_App			= ui.loadModule('App')

return ui
