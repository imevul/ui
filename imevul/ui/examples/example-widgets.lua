local ui = dofile('/imevul/ui/init.lua')

local size, qty, status

local app = ui.App({
	callbacks = {
		keyReleased = function(app, key, _)
			if key == 'q' then
				app:quit()
			end
		end
	}
})

local win = ui.Window({
	title = 'F-4 widgets',
	layout = ui.ListLayout({ spacing = 1 })
})
app:add(win)

local function refresh()
	if status and size and qty then
		status:setText('Size ' .. tostring(size:getValue()) .. ' x ' .. tostring(qty:getValue()))
	end
end

size = ui.RadioGroup({
	padding = 0,
	height = 3,
	items = {
		{ text = 'Small', value = 'S' },
		{ text = 'Medium', value = 'M' },
		{ text = 'Large', value = 'L' },
	},
	value = 'M',
	callbacks = {
		onChange = function()
			refresh()
		end
	}
})

qty = ui.NumberField({
	value = 2,
	min = 1,
	max = 99,
	step = 1,
	width = 6,
	tooltip = 'Up/down changes quantity',
	callbacks = {
		onChange = function()
			refresh()
		end
	}
})

status = ui.Text({ text = '' })

win:add(ui.Text({ text = 'Size (radio)  Tab/click, Space to select' }))
win:add(size)
win:add(ui.Panel({
	padding = 0,
	height = 1,
	layout = ui.ListLayout({ direction = ui.Direction.HORIZONTAL, spacing = 1 }),
	items = {
		ui.Text({ text = 'Qty' }),
		qty,
		ui.Tooltip({ text = 'Integer field. Arrows step; min 1 max 99.' }),
	}
}))
win:add(ui.Input({
	text = 'Name',
	width = 16,
	tooltip = 'Focus or hover for a hint'
}))
win:add(status)
win:add(ui.Button({
	text = 'Confirm order',
	default = true,
	padding = 1,
	callbacks = {
		onClick = function()
			ui.confirm(app, 'Place this order?', function(result)
				status:setText('Dialog: ' .. tostring(result))
			end)
		end
	}
}))
win:add(ui.Text({ text = 'q quit  Tab focus  click empty to blur' }))

refresh()
app:initialize()
