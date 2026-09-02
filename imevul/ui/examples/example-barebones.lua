local ui = dofile('/imevul/ui/init.lua')

local app = ui.App()
app:add(ui.Text({ text = 'Hello world!' }), 2, 1)

app:initialize()
