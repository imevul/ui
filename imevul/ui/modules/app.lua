local args = { ... }
local ui = args[1]
local gfx = ui.lib.cobalt.graphics

--[[
Class App
The main container for the application. Handles hooks into cobalt and rendering of the main app
]]--
local App = ui.lib.class(ui.modules.Container, function(this, data)
	data = data or {}
	data.width = data.width or 51
	data.height = data.height or 19

	data.config = data.config or {
		theme = {
			primary = colors.cyan,
			secondary = colors.red,
			text = colors.white,
			focusedText = colors.black,
			focusedBackground = colors.white,
			blurredBackground = colors.lightGray,
			background = colors.black,
		}
	}

	data.callbacks = data.callbacks or {}

	ui.modules.Container.init(this, data)

	this.type = 'App'
	this.width = data.width
	this.height = data.height

	this.config = data.config
	this.callbacks = data.callbacks
end)

function App:_draw()
	gfx.setBackgroundColor(colors.black)
	gfx.clear()

	ui.modules.Container._draw(self)
end

function App:_render()
	gfx.setBackgroundColor(colors.black)--self.config.theme.background or colors.gray)
	gfx.clear()
	self.canvas:renderTo(function()
		App:_draw()
	end)
	gfx.draw(self.canvas)
end

function App:initialize()
	-- Cobalt hooks
	local cobalt = ui.lib.cobalt

	cobalt.load = function()
		self:_load()
	end

	cobalt.update = function(dt)
		self:_update(dt)
	end

	cobalt.draw = function()
		self:_draw()
	end

	cobalt.keypressed = function(key, keyCode)
		self:_keyPressed(key, keyCode)
	end

	cobalt.keyreleased = function(key, keyCode)
		self:_keyReleased(key, keyCode)
	end

	cobalt.mousereleased = function(x, y, button)
		self:_mouseReleased(x, y, button)
	end

	cobalt.textinput = function(char)
		self:_textInput(char)
	end

	cobalt.eventhandler = function (event, a, b, c, d, e)
		self:_eventHandler(event, a, b, c, d, e)
	end

	ui.lib.cobalt.init()
end

function App:quit()
	ui.lib.cobalt.application.quit()
end

function App:_update(dt)
	if self.callbacks.update then
		self.callbacks.update(self, dt)
	end
end

function App:_load()
	if self.callbacks.load then
		self.callbacks.load(self)
	end
end

function App:_eventHandler(event, a, b, c, d, e)
	if self.callbacks[event] then
		self.callbacks[event](self, a, b, c, d, e)
	end
end

return App
