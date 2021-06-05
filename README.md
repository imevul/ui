## Imevul UI - A simple Lua GUI library built on top of Cobalt 2

Please see the `examples` folder for some examples on how to use.

[Cobalt 2](https://github.com/ebernerd/cobalt-2) is not included, and needs to be downloaded separately!

# Installation

Download the entire repository and put it in the root directory as-is. You should then have a folder structure that looks like `/imevul/ui`.
Alternatively, you can choose your own location, but you will need to update the config if you decide to do so.

# How to use

The different modules are made available with a `UI_` prefix, for example `UI_App`.

```
local ui = dofile('/imevul/ui/init.lua')

-- Create the application itself
local app = UI_App({
	callbacks = {
		keyReleased = function(app, key, keyCode)
			-- Make sure we can quit the application
			if key == 'q' then
				app:quit()
			end
		end
	}
})

-- Create a window
local win = UI_Window({
	title = 'My window',
	width = app.width,
	height = app.height
})

-- Add the window as a child to the app
app:add(win)

-- Create and add a text object as a child to the window
win:add(UI_Text({
	text = 'My text'
}), 2, 2)

-- Start the main event loop
app:initialize()
```

This above code will generate something that will look like this:

![img.png](img.png)
