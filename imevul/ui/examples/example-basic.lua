local ui = dofile('/imevul/ui/init.lua')

-- Create the application itself
local app = ui.App({
	callbacks = {
		keyReleased = function(app, key, keyCode)
			-- Make sure we can quit the application
			if key == 'q' then
				app:quit()
			end
		end
	}
})

-- Create a window (omit width/height to fill the app; Tab / Shift-Tab move focus)
local win = ui.Window({
	title = 'My window'
})

-- Add the window as a child to the app
app:add(win)

-- Create and add a text object as a child to the window
win:add(ui.Text({
	text = 'My text'
}), 2, 2)

-- Start the main event loop
app:initialize()
