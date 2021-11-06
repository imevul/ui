dofile('/imevul/ui/init.lua')

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
		textInput = function(app, key, _)
			if key == 'q' then
				app:quit()
			end
		end,
		update = function(app, _)
			local text = app:childByName('text1', true)
			if text then
				text:setText('Text: Press q to quit - ' .. textutils.formatTime(os.time(), true))
			end
		end
	}
})

local cnt = 0
local win

local menuCallback = function(b)
	win:childByName('menuText', true):setText(b.text .. ' selected')
end

-- Main window
win = UI_Window({
	title = 'Example App',
	width = app.width,
	height = app.height,
	background = colors.black,
	closeButton = true,
	layout = UI_ListLayout(),
	callbacks = {
		onRemove = function()
			app:quit()
		end
	},
})
	:add(
	UI_Panel({
		padding = 0,
		layout = UI_ListLayout({ direction = UI_Direction.HORIZONTAL, spacing = 3 }),
		items = {
			UI_List({
				name = 'sidebar',
				width = app.width * 0.2,
				background = colors.gray,
				items = {
					UI_Text({text = 'Foo'}),
					UI_Text({text = 'Bar'}),
					UI_Text({text = 'Baz'}),
					UI_Text({text = 'Bingo'}),
					UI_Text({text = 'Bongo'}),
					UI_Text({text = 'Bango'}),
				}
			}),

			UI_Panel({
				width = app.width * 0.8,
				layout = UI_ListLayout({ spacing = 1}),
				padding = 1,
				items = {
					UI_Text({
						name = 'text1',
						text = 'Text: Press q to quit'
					}),
					UI_Text({
						name = 'text2',
						text = 'This text will change later'
					}),
					UI_Input({
						text = 'Input',
						width = 20
					}),
					UI_Button({
						text = 'This is a Button',
						padding = 1,
						callbacks = {
							onClick = function (_)
								cnt = cnt + 1
								win:childByName('text2', true):setText('Clicked ' ..  cnt .. ' times')
								win:childByName('bar', true):setValue(cnt)
							end
						}
					}),
					UI_Button({
						text = 'Show Modal Window',
						padding = 1,
						callbacks = {
							onClick = function (_)
								app:childByName('modal', true):setVisible(true)
							end
						}
					}),
					UI_DropDown({
						text = 'Menu!',
						padding = 1,
						items = {
							UI_Button({text = 'Foo', padding = 1, callbacks = {onClick = menuCallback}}),
							UI_Button({text = 'Bar', padding = 1, callbacks = {onClick = menuCallback}}),
							UI_Button({text = 'Bazbazbazbaz', padding = 1, callbacks = {onClick = menuCallback}}),
						}
					}),
					UI_Text({
						name = 'menuText',
						text = ' '
					}),
					UI_Bar({
						name = 'bar',
						width = 30,
						height = 1,
						gradient = -1
					}),
					UI_Slider({
						width = 30,
						height = 1,
						value = 25,
						--style = UI_Slider.STYLE_BAR
					}),
					UI_Checkbox({
						text = 'Check this!'
					}),
					UI_Checkbox({
						text = 'Check this too!'
					}),
					UI_ToggleButton({
						text = 'Toggled?'
					})
				}
			})
		}
	})
)
app:add(win)


-- Modal window
local win2 = UI_ModalWindow({
	name = 'modal',
	title = 'Modal',
	visible = false,
	padding = 2,
	layout = UI_ListLayout(),
	width = app.width - 20,
	height = app.height - 15,
})
app:add(win2, 10, 5)

win2:add(UI_TabPanel({
	title = 'TabPanel',
	padding = 0,
	tabColor = colors.lightGray,
	tabs = {
		{
			name = 'Foo',
			tab = UI_ScrollPanel({
				background = colors.red,
				layout = UI_ListLayout(),
				items = {
					UI_Button({
						text = 'Close',
						padding = 1,
						callbacks = {
							mouseReleased = function()
								win2:setVisible(false)
							end
						}
					})
				}
			})
		},
		{
			name = 'Bar',
			tab = UI_Panel({
				background = colors.green,
				layout = UI_ListLayout(),
				items = {
					UI_Image({
						source = 'test.nfp'
					})
				}
			})
		},
		{
			name = 'Baz',
			tab = UI_Panel({
				background = colors.brown,
				layout = UI_ListLayout(),
				items = {
					UI_List({
						width = 15,
						height = 4,
						items = {
							UI_Text({text = 'Foo'}),
							UI_Text({text = 'Bar'}),
							UI_Text({text = 'Baz'}),
							UI_Text({text = 'Bingo'}),
							UI_Text({text = 'Bongo'}),
							UI_Text({text = 'Bango'}),
						}
					})
				}
			})
		},
	}
}))


-- Start app event loop
app:initialize()
