dofile('/imevul/ui/init.lua')

local app = UI_App()
app:add(UI_Text({ text = 'Hello world!' }), 2, 1)

app:initialize()
