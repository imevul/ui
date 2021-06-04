local ui = dofile('/imevul/ui/init.lua')

local app = UI_App()

local win = UI_Window({
	x = 1,
	y = 1,
	width = 20,
	height = 15
})
app:add(win)

win:add(UI_Text({
	x = 1,
	y = 1,
	text = 'This is a test'
}))

win:add(UI_Button({
	x = 1, y = 5,
	text = 'Weeee!',
	callbacks = {
		mouseReleased = function ()
			win:add(UI_Text({
				x = 1, y = 10,
				text = "Weeeeeeeeee!"
			}))
		end
	}
}))

app:init()
