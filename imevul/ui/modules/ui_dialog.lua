local args = { ... }
local ui = args[1]
assert(ui, 'Imevul UI library not found')

local Dialog = {}

---@param app App
---@param data table
---@return ModalWindow
function Dialog.open(app, data)
	assert(app, 'dialog requires an App')
	data = data or {}
	local message = data.message or ''
	local buttons = data.buttons or {
		{ text = 'OK', default = true, result = 'ok' },
	}

	local width = math.min((app.width or 51) - 4, math.max(24, #message + 4))
	local pad = 2
	local spacing = 1
	local buttonPadding = 1
	local buttonHeight = 1 + math.ceil(buttonPadding * 2)
	local height = pad + 1 + spacing + buttonHeight + pad

	local modal = ui.modules.ModalWindow({
		title = data.title or '',
		width = width,
		height = height,
		visible = false,
		padding = pad,
		layout = ui.modules.ListLayout({ spacing = spacing }),
		closable = true,
	})

	local settled = false
	local function finish(result)
		if settled then
			return
		end
		settled = true
		if modal.visible then
			modal:setVisible(false)
		end
		if modal.parent then
			modal.parent:remove(modal)
		end
		if data.onResult then
			data.onResult(result)
		end
	end

	modal.callbacks = modal.callbacks or {}
	local prevVisible = modal.callbacks.onSetVisible
	modal.callbacks.onSetVisible = function(self, vis)
		if prevVisible then
			prevVisible(self, vis)
		end
		if not vis then
			finish('cancel')
		end
	end

	modal:add(ui.modules.Text({
		text = message
	}))

	local rowItems = {}
	for _, spec in ipairs(buttons) do
		local result = spec.result or spec.text or 'ok'
		table.insert(rowItems, ui.modules.Button({
			text = spec.text or result,
			default = spec.default or false,
			padding = buttonPadding,
			callbacks = {
				onClick = function()
					finish(result)
				end
			}
		}))
	end

	modal:add(ui.modules.Panel({
		padding = 0,
		height = buttonHeight,
		layout = ui.modules.ListLayout({
			direction = ui.modules.Direction.HORIZONTAL,
			spacing = 2
		}),
		items = rowItems
	}))

	local mx = math.max(0, math.floor(((app.width or width) - width) / 2))
	local my = math.max(0, math.floor(((app.height or height) - height) / 2))
	app:add(modal, mx, my)
	modal:setVisible(true)
	return modal
end

function Dialog.alert(app, message, onResult)
	return Dialog.open(app, {
		title = 'Alert',
		message = message,
		buttons = {
			{ text = 'OK', default = true, result = 'ok' },
		},
		onResult = onResult,
	})
end

function Dialog.confirm(app, message, onResult)
	return Dialog.open(app, {
		title = 'Confirm',
		message = message,
		buttons = {
			{ text = 'OK', default = true, result = 'ok' },
			{ text = 'Cancel', result = 'cancel' },
		},
		onResult = onResult,
	})
end

setmetatable(Dialog, {
	__call = function(_, app, data)
		return Dialog.open(app, data)
	end
})

return Dialog
