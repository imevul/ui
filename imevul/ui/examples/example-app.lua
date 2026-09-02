local ui = dofile('/imevul/ui/init.lua')

-- Save a ref for later
local text

-- Main application
local app = ui.App({
	config = {
		theme = {
			primary = colors.cyan,
			secondary = colors.orange,
			text = colors.white,
			focusedText = colors.black,
			focusedBackground = colors.white,
			blurredBackground = colors.lightGray,
			background = colors.black,
		}
	},
	callbacks = {
		keyReleased = function(app, key, keyCode)
			if key == 'q' then
				app:quit()
			end
		end,
		update = function(app, dt)
			-- Reference text field from earlier
			text:setText('Text: Press q to quit - ' .. textutils.formatTime(os.time(), true))
		end
	}
})

-- Main window (fills the app; Tab / Shift-Tab move focus, Enter activates the default button)
local win = ui.Window({
	title = 'Window Title',
	background = colors.black
})
app:add(win)

-- Quit button
win:add(ui.Button({
	text = 'X',
	color = colors.red,
	callbacks = {
		onClick = function()
			app:quit()
		end
	}
}), -1, 0)

-- Use previous ref
text = ui.Text({
	text = 'Text: Press q to quit'
})
win:add(text, 2, 2)

-- Add another line of text
local text2 = ui.Text({
	text = 'This text will change later'
})
win:add(text2, 2, 3)

-- Add an input field
local input = ui.Input({
	text = 'Input field',
	width = 20
})
win:add(input, 2, 4)

-- Add a button
local bar
local cnt = 0
win:add(ui.Button({
	text = 'This is a Button',
	padding = 1,
	default = true,
	callbacks = {
		onClick = function ()
			cnt = cnt + 1
			text2:setText('The Button has been clicked ' ..  cnt .. ' times')
			bar:setValue(cnt)
		end
	}
}), 5, 6)

-- Add a progress bar that tracks how many times we clicked the button
bar = ui.Bar({
	width = 30
})
win:add(bar, 2, 10)

-- Start app event loop
app:initialize()
