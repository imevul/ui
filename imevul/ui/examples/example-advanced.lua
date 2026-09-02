local ui = dofile('/imevul/ui/init.lua')

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
win = ui.Window({
	title = 'Example App',
	background = colors.black,
	closeButton = true,
	layout = ui.ListLayout(),
	callbacks = {
		onRemove = function()
			app:quit()
		end
	},
})
	:add(
	ui.Panel({
		padding = 0,
		layout = ui.ListLayout({ direction = ui.Direction.HORIZONTAL, spacing = 3 }),
		items = {
			ui.List({
				name = 'sidebar',
				width = app.width * 0.2,
				background = colors.gray,
				items = {
					ui.Text({text = 'Foo'}),
					ui.Text({text = 'Bar'}),
					ui.Text({text = 'Baz'}),
					ui.Text({text = 'Bingo'}),
					ui.Text({text = 'Bongo'}),
					ui.Text({text = 'Bango'}),
				}
			}),

			ui.Panel({
				width = app.width * 0.8,
				layout = ui.ListLayout({ spacing = 1}),
				padding = 1,
				items = {
					ui.Text({
						name = 'text1',
						text = 'Text: Press q to quit'
					}),
					ui.Text({
						name = 'text2',
						text = 'This text will change later'
					}),
					ui.Input({
						text = 'Input',
						width = 20
					}),
					ui.Button({
						text = 'This is a Button',
						padding = 1,
						default = true,
						callbacks = {
							onClick = function (_)
								cnt = cnt + 1
								win:childByName('text2', true):setText('Clicked ' ..  cnt .. ' times')
								win:childByName('bar', true):setValue(cnt)
							end
						}
					}),
					ui.Button({
						text = 'Show Modal Window',
						padding = 1,
						callbacks = {
							onClick = function (_)
								app:childByName('modal', true):setVisible(true)
							end
						}
					}),
					ui.DropDown({
						text = 'Menu!',
						padding = 1,
						items = {
							ui.Button({text = 'Foo', padding = 1, callbacks = {onClick = menuCallback}}),
							ui.Button({text = 'Bar', padding = 1, callbacks = {onClick = menuCallback}}),
							ui.Button({text = 'Bazbazbazbaz', padding = 1, callbacks = {onClick = menuCallback}}),
						}
					}),
					ui.Text({
						name = 'menuText',
						text = ' '
					}),
					ui.Bar({
						name = 'bar',
						width = 30,
						height = 1,
						gradient = -1
					}),
					ui.Slider({
						width = 30,
						height = 1,
						value = 25,
						--style = ui.Slider.STYLE_BAR
					}),
					ui.Checkbox({
						text = 'Check this!'
					}),
					ui.Checkbox({
						text = 'Check this too!'
					}),
					ui.ToggleButton({
						text = 'Toggled?'
					})
				}
			})
		}
	})
)
app:add(win)


-- Modal window
local win2 = ui.ModalWindow({
	name = 'modal',
	title = 'Modal',
	visible = false,
	padding = 2,
	layout = ui.ListLayout(),
	width = app.width - 20,
	height = app.height - 15,
})
app:add(win2, 10, 5)

win2:add(ui.TabPanel({
	title = 'TabPanel',
	padding = 0,
	tabColor = colors.lightGray,
	tabs = {
		{
			name = 'Foo',
			tab = ui.ScrollPanel({
				background = colors.red,
				layout = ui.ListLayout(),
				items = {
					ui.Button({
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
			tab = ui.Panel({
				background = colors.green,
				layout = ui.ListLayout(),
				items = {
					ui.Image({
						source = 'test.nfp'
					})
				}
			})
		},
		{
			name = 'Baz',
			tab = ui.Panel({
				background = colors.brown,
				layout = ui.ListLayout(),
				items = {
					ui.List({
						width = 15,
						height = 4,
						items = {
							ui.Text({text = 'Foo'}),
							ui.Text({text = 'Bar'}),
							ui.Text({text = 'Baz'}),
							ui.Text({text = 'Bingo'}),
							ui.Text({text = 'Bongo'}),
							ui.Text({text = 'Bango'}),
						}
					})
				}
			})
		},
	}
}))


-- Start app event loop
app:initialize()
