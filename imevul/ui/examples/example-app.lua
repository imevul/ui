local ui = dofile('/imevul/ui/init.lua')

-- Save a ref for later
local text

-- Main application
local app = UI_App({
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

-- Main window
local win = UI_Window({
	title = 'Window Title',
	width = app.width,
	height = app.height,
	background = colors.black
})
app:add(win)

-- Quit button
win:add(UI_Button({
	text = 'X',
	color = colors.red,
	callbacks = {
		mouseReleased = function()
			app:quit()
		end
	}
}), win.width - 1, 0)

-- Use previous ref
text = UI_Text({
	text = 'Text: Press q to quit'
})
win:add(text, 2, 2)

-- Add another line of text
local text2 = UI_Text({
	text = 'This text will change later'
})
win:add(text2, 2, 3)

-- Add an input field
local input = UI_Input({
	text = 'Input field',
	width = 20
})
win:add(input, 2, 4)

-- Add a button
local bar
local cnt = 0
win:add(UI_Button({
	text = 'This is a Button',
	padding = 1,
	callbacks = {
		mouseReleased = function ()
			cnt = cnt + 1
			text2:setText('The Button has been clicked ' ..  cnt .. ' times')
			bar.value = cnt
		end
	}
}), 5, 6)

-- Add a progress bar that tracks how many times we clicked the button
bar = UI_Bar({
	width = 30
})
win:add(bar, 2, 10)

-- Start app event loop
app:initialize()
