local __SRC__ = debug.getinfo(1).short_src
local __DIR__ = fs.getDir(__SRC__)

local ui = {
	version = '1.5.0',
	config = {
		path = __DIR__,
		debug = false
	},
	lib = {},
	modules = {},
}

-- Load libraries
ui.lib.class = dofile(ui.config.path .. '/lib/class.lua')
ui.lib.graphics = dofile(ui.config.path .. '/lib/graphics.lua')

---Print debug information to stdout
---@public
---@param text string
ui.printDebug = function(text)
	if ui.config.debug then
		print(text)
	end
end

---Load a module onto ui.modules and ui[name]
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
	ui[module] = ui.modules[module]
	return ui.modules[module]
end

ui.loadModule('Direction', 'enums')

ui.loadModule('Layout', 'layouts')
ui.loadModule('ListLayout', 'layouts')
ui.loadModule('GridLayout', 'layouts')

ui.loadModule('Object')
ui.loadModule('Container')
ui.loadModule('Window')
ui.loadModule('ModalWindow')
ui.loadModule('Panel')
ui.loadModule('TabPanel')
ui.loadModule('ScrollPanel')
ui.loadModule('List')
ui.loadModule('Text')
ui.loadModule('Image')
ui.loadModule('Input')
ui.loadModule('NumberField')
ui.loadModule('Checkbox')
ui.loadModule('Radio')
ui.loadModule('RadioGroup')
ui.loadModule('ToggleButton')
ui.loadModule('Button')
ui.loadModule('Tooltip')
ui.loadModule('TabButton')
ui.loadModule('DropDown')
ui.loadModule('Bar')
ui.loadModule('Slider')
ui.loadModule('Dialog')
ui.loadModule('App')

ui.dialog = ui.Dialog
ui.alert = ui.Dialog.alert
ui.confirm = ui.Dialog.confirm

---Assign the old UI_* global names (UI_App, UI_Window, …)
---@public
function ui.exportGlobals()
	UI_Direction = ui.Direction
	UI_Layout = ui.Layout
	UI_ListLayout = ui.ListLayout
	UI_GridLayout = ui.GridLayout
	UI_Object = ui.Object
	UI_Container = ui.Container
	UI_Window = ui.Window
	UI_ModalWindow = ui.ModalWindow
	UI_Panel = ui.Panel
	UI_TabPanel = ui.TabPanel
	UI_ScrollPanel = ui.ScrollPanel
	UI_List = ui.List
	UI_Text = ui.Text
	UI_Image = ui.Image
	UI_Input = ui.Input
	UI_NumberField = ui.NumberField
	UI_Checkbox = ui.Checkbox
	UI_Radio = ui.Radio
	UI_RadioGroup = ui.RadioGroup
	UI_ToggleButton = ui.ToggleButton
	UI_Button = ui.Button
	UI_Tooltip = ui.Tooltip
	UI_TabButton = ui.TabButton
	UI_DropDown = ui.DropDown
	UI_Bar = ui.Bar
	UI_Slider = ui.Slider
	UI_Dialog = ui.Dialog
	UI_App = ui.App
end

return ui
