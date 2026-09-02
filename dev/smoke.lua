-- Headless CraftOS-PC smoke (F-1 / F-2 / F-3).
assert(fs.exists('/imevul/ui/init.lua'), 'mount missing: /imevul/ui/init.lua')
local ui = dofile('/imevul/ui/init.lua')
assert(type(ui.version) == 'string')
assert(ui.version == '1.3.0')
assert(type(ui.App) == 'function' or type(ui.App) == 'table')
assert(UI_App == nil, 'UI_App must not be global unless exportGlobals is called')

local app = ui.App({
	callbacks = {
		load = function(a)
			local win = ui.Window({})
			a:add(win)
			assert(win.width and win.width > 0, 'fill window should pick up App size')

			local input = ui.Input({
				text = 'ab',
				width = 10,
				maxLength = 5
			})
			win:add(input)

			local btn = ui.Button({
				text = 'Go',
				default = true
			})
			win:add(btn)

			a:focusNext()
			assert(a:getFocusedLeaf() == input, 'focusNext should land on the first focusable')

			a:setFocus(input)
			input.caret = 3
			input:_textInput('c')
			assert(input.text == 'abc', 'insert at caret')
			assert(input.caret == 4, 'caret advances after insert')
			input:_textInput('d')
			input:_textInput('e')
			assert(input.text == 'abcde')
			input:_textInput('f')
			assert(input.text == 'abcde', 'maxLength should reject extra chars')

			input:_mousePressed(1, 0, 1)
			assert(input.caret == 2, 'click-to-caret should move caret')

			local oldW = win.width
			a:resize(a.width + 10, a.height)
			assert(win.width > oldW, 'fill child should grow on App:resize')

			a:quit()
		end
	}
})
app:initialize()
print('SMOKE_OK')
os.shutdown()
