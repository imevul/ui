-- Headless CraftOS-PC smoke (F-1 / F-2 / F-3).
assert(fs.exists('/imevul/ui/init.lua'), 'mount missing: /imevul/ui/init.lua')
local ui = dofile('/imevul/ui/init.lua')
assert(type(ui.version) == 'string')
assert(ui.version == '1.4.0')
assert(type(ui.App) == 'function' or type(ui.App) == 'table')
assert(UI_App == nil, 'UI_App must not be global unless exportGlobals is called')

local app = ui.App({
	callbacks = {
		load = function(a)
			local win = ui.Window({
				layout = ui.ListLayout({ spacing = 1 })
			})
			a:add(win)
			assert(win.width == a.width and win.height == a.height, 'fill window should match App (no App padding inset)')

			local function childXY(container, child)
				for _, obj in ipairs(container.objects) do
					if obj.ref == child then
						return obj.x, obj.y
					end
				end
			end

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

			local ix, iy = childXY(win, input)
			local bx, by = childXY(win, btn)
			win:update()
			win:update()
			local ix2, iy2 = childXY(win, input)
			local bx2, by2 = childXY(win, btn)
			assert(ix == ix2 and iy == iy2, 'layout should stay put across updates')
			assert(bx == bx2 and by == by2, 'later siblings should stay put across updates')
			assert(by > iy, 'list layout should keep add order')

			a:focusNext()
			assert(a:getFocusedLeaf() == input, 'focusNext should land on the first focusable')

			a:setFocus(input)
			assert(a:getFocusedLeaf() == input)
			a:_mousePressed(0, 0, 1)
			assert(a:getFocusedLeaf() == nil, 'clicking background should clear focus')
			local clickX, clickY = childXY(win, input)
			a:_mousePressed(clickX, clickY, 1)
			assert(a:getFocusedLeaf() == input, 'clicking a field should restore focus')

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

			local group = ui.RadioGroup({
				padding = 0,
				height = 2,
				items = {
					{ text = 'S', value = 's' },
					{ text = 'M', value = 'm' },
				}
			})
			win:add(group)
			group:setValue('m')
			assert(group:getValue() == 'm', 'RadioGroup setValue')

			local num = ui.NumberField({
				value = 5,
				min = 0,
				max = 6,
				step = 1,
				width = 5
			})
			win:add(num)
			num:_keyPressed('up', 0)
			assert(num:getValue() == 6, 'NumberField up steps')
			num:_keyPressed('up', 0)
			assert(num:getValue() == 6, 'NumberField clamps to max')

			local tipIn = ui.Input({
				text = 'x',
				width = 5,
				tooltip = 'hint'
			})
			win:add(tipIn)
			a:setFocus(tipIn)
			assert(a._tooltipOwner == tipIn, 'tooltip shows on focus')
			assert(tipIn.focused, 'tooltip input still focuses')

			local modal = ui.dialog(a, {
				title = 'T',
				message = 'Hi',
				buttons = {
					{ text = 'OK', default = true, result = 'ok' },
				}
			})
			assert(modal, 'dialog constructs')
			local pad = modal.padding or 0
			for _, obj in ipairs(modal.objects) do
				if not obj.ref.absolute then
					assert(obj.y + (obj.ref.height or 0) <= modal.height - pad, 'dialog content should stay inside the frame')
				end
			end
			local ix3, iy3 = childXY(win, input)
			assert(ix == ix3 and iy == iy3, 'opening a modal should not reflow siblings')
			assert(a.objects[1] and a.objects[1].ref == win, 'document order should keep the window first')
			assert(a.objectsDraw[#a.objectsDraw] and a.objectsDraw[#a.objectsDraw].ref == modal, 'modal should paint last')

			local modalLeaf = a:getFocusedLeaf()
			assert(modalLeaf and modalLeaf.focusable, 'dialog should focus a control')
			a:_mousePressed(0, 0, 1)
			assert(a:getFocusedLeaf() == modalLeaf, 'click outside a modal should keep its focus')
			local mx, my = modal:getPositionIn(a)
			a:_mousePressed(mx + 1, my + 1, 1)
			assert(a:getFocusedLeaf() == nil, 'clicking modal chrome should clear focus')

			a:quit()
		end
	}
})
app:initialize()
print('SMOKE_OK')
os.shutdown()
