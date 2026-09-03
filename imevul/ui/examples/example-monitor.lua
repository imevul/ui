local ui = dofile('/imevul/ui/init.lua')

-- Opt-in: first monitor now, or the next one that attaches.
-- Detach falls back to the computer term. q quits.
local app = ui.App({
	monitor = true,
	callbacks = {
		keyReleased = function(app, key, _)
			if key == 'q' then
				app:quit()
			end
		end
	}
})

local win = ui.Window({
	title = 'Monitor',
	layout = ui.ListLayout({ spacing = 1 })
})
app:add(win)
win:add(ui.Text({
	text = 'Attach a monitor or resize this term. q quits.'
}))

app:initialize()
