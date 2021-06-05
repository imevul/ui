local ui = dofile('/imevul/ui/init.lua')

-- Create the application itself
local app = UI_App({
	callbacks = {
		keyReleased = function(app, key, keyCode)
			-- Make sure we can quit the application
			if key == 'q' then
				app:quit()
			end
		end
	}
})

-- Create a window
local win = UI_Window({
	title = 'My window',
	width = app.width,
	height = app.height
})

-- Add the window as a child to the app
app:add(win)

-- Create and add a text object as a child to the window
win:add(UI_Text({
	text = 'My text'
}), 2, 2)

-- Start the main event loop
app:initialize()
