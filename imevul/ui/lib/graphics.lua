-- Off-screen cell buffer with a Cobalt-shaped 0-based API.
-- Internal storage is 1-based; term.blit is 1-based.

local function resolveColor(color)
	if color == nil then
		return nil
	end
	if type(color) == 'string' and colors[color] then
		return colors[color]
	end
	return color
end

local function blitOf(color)
	if colors.toBlit then
		return colors.toBlit(color)
	end
	-- Fallback for older CraftOS: hex nibble from color bit
	local n = 0
	local bit = 1
	for i = 0, 15 do
		if color == bit then
			n = i
			break
		end
		bit = bit * 2
	end
	return string.format('%x', n)
end

local function newCells(width, height, fg, bg)
	width = math.max(0, math.floor(tonumber(width) or 0))
	height = math.max(0, math.floor(tonumber(height) or 0))
	local cells = {}
	for y = 1, height do
		cells[y] = {}
		for x = 1, width do
			cells[y][x] = { char = ' ', fg = fg, bg = bg }
		end
	end
	return cells
end

local Canvas = {}
Canvas.__index = Canvas

function Canvas:typeOf(kind)
	return kind == 'Canvas' or kind == 'Drawable'
end

function Canvas:getWidth()
	return self.width
end

function Canvas:getHeight()
	return self.height
end

function Canvas:renderTo(fn)
	local graphics = self._graphics
	local old = graphics.getCanvas()
	graphics.setCanvas(self)
	graphics.clear()
	fn()
	graphics.setCanvas(old)
end

local graphics = {
	color = colors.white,
	background = colors.black,
	overwrite = true,
	currentCanvas = nil,
}

local function setCell(canvas, x, y, char, fg, bg)
	if not canvas or not canvas.cells then
		return
	end
	local ix = math.floor(tonumber(x) or 0) + 1
	local iy = math.floor(tonumber(y) or 0) + 1
	if ix < 1 or iy < 1 then
		return
	end
	if canvas.width and ix > canvas.width then
		return
	end
	if canvas.height and iy > canvas.height then
		return
	end
	local row = canvas.cells[iy]
	if not row then
		return
	end
	row[ix] = { char = char, fg = fg, bg = bg }
end

function graphics.setOverwrite(flag)
	if flag == nil then
		flag = true
	end
	graphics.overwrite = flag and true or false
	if graphics.currentCanvas then
		graphics.currentCanvas.overwrite = graphics.overwrite
	end
end

function graphics.setCanvas(canvas)
	graphics.currentCanvas = canvas
end

function graphics.getCanvas()
	return graphics.currentCanvas
end

function graphics.setColor(color)
	graphics.color = resolveColor(color) or graphics.color
end

function graphics.getColor()
	return graphics.color
end

function graphics.setBackgroundColor(color)
	graphics.background = resolveColor(color) or graphics.background
end

function graphics.getBackgroundColor()
	return graphics.background
end

function graphics.clear()
	local canvas = graphics.currentCanvas
	if not canvas then
		return
	end
	local fg = graphics.color
	local bg = graphics.background
	canvas.defaultBg = bg
	canvas.width = math.max(0, math.floor(tonumber(canvas.width) or 0))
	canvas.height = math.max(0, math.floor(tonumber(canvas.height) or 0))
	canvas.cells = newCells(canvas.width, canvas.height, fg, bg)
end

function graphics.print(text, x, y)
	local canvas = graphics.currentCanvas
	if not canvas then
		return
	end
	text = tostring(text or '')
	x = math.floor(x or 0)
	y = math.floor(y or 0)
	local fg = graphics.color
	local bg = graphics.background
	for i = 1, #text do
		setCell(canvas, x + i - 1, y, text:sub(i, i), fg, bg)
	end
end

function graphics.pixel(x, y)
	local canvas = graphics.currentCanvas
	if not canvas then
		return
	end
	local color = graphics.color
	setCell(canvas, x or 0, y or 0, ' ', color, color)
end

function graphics.rect(mode, x, y, width, height)
	local canvas = graphics.currentCanvas
	if not canvas then
		return
	end
	x = math.floor(x or 0)
	y = math.floor(y or 0)
	width = math.floor(width or 0)
	height = math.floor(height or 0)
	local color = graphics.color
	if mode == 'fill' then
		for iy = y, y + height - 1 do
			for ix = x, x + width - 1 do
				setCell(canvas, ix, iy, ' ', color, color)
			end
		end
	elseif mode == 'line' then
		if width <= 0 or height <= 0 then
			return
		end
		for ix = x, x + width - 1 do
			setCell(canvas, ix, y, ' ', color, color)
			setCell(canvas, ix, y + height - 1, ' ', color, color)
		end
		for iy = y, y + height - 1 do
			setCell(canvas, x, iy, ' ', color, color)
			setCell(canvas, x + width - 1, iy, ' ', color, color)
		end
	else
		error("Must supply valid shape mode: 'fill' or 'line'")
	end
end

graphics.rectangle = graphics.rect

-- Sextant bits: TL=1 TR=2 ML=4 MR=8 BL=16. BR is invert (swap fg/bg, 31-bits).
local SEXT_TL = 1
local SEXT_TR = 2
local SEXT_ML = 4
local SEXT_MR = 8
local SEXT_BL = 16
local SEXT_BR = 32

local function bitOr(a, b)
	local result = 0
	local place = 1
	for _ = 0, 5 do
		if (a % 2) == 1 or (b % 2) == 1 then
			result = result + place
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
		place = place * 2
	end
	return result
end

local function sextantCell(mask, line, fill)
	local br = mask >= SEXT_BR
	local bits = mask % SEXT_BR
	if br then
		return string.char(128 + (31 - bits)), fill, line
	end
	return string.char(128 + bits), line, fill
end

local function putSextant(canvas, x, y, mask, line, fill)
	local ch, fg, bg = sextantCell(mask, line, fill)
	setCell(canvas, x, y, ch, fg, bg)
end

---Draw a rectangular frame. borderStyle 'solid' (default) or 'lines' (teletext 128-159).
---@param x number
---@param y number
---@param width number
---@param height number
---@param opts table|nil color, fill, borderStyle, title, titleColor, titleFill
function graphics.frame(x, y, width, height, opts)
	local canvas = graphics.currentCanvas
	if not canvas then
		return
	end
	opts = opts or {}
	x = math.floor(x or 0)
	y = math.floor(y or 0)
	width = math.floor(width or 0)
	height = math.floor(height or 0)
	if width <= 0 or height <= 0 then
		return
	end

	local style = opts.borderStyle
	if style ~= 'lines' then
		style = 'solid'
	end
	local line = resolveColor(opts.color) or graphics.color
	local fill = resolveColor(opts.fill) or graphics.background
	local title = tostring(opts.title or '')

	if style == 'solid' then
		local old = graphics.color
		graphics.color = line
		graphics.rect('line', x, y, width, height)
		graphics.color = old
		if title ~= '' then
			local tfg = resolveColor(opts.titleColor) or colors.white
			local tbg = resolveColor(opts.titleFill) or line
			local tx = x + math.floor((width - #title) / 2)
			local savedFg = graphics.color
			local savedBg = graphics.background
			graphics.color = tfg
			graphics.background = tbg
			graphics.print(title, tx, y)
			graphics.color = savedFg
			graphics.background = savedBg
		end
		return
	end

	local left = bitOr(bitOr(SEXT_TL, SEXT_ML), SEXT_BL)
	local right = bitOr(bitOr(SEXT_TR, SEXT_MR), SEXT_BR)
	local top = bitOr(SEXT_TL, SEXT_TR)
	local bottom = bitOr(SEXT_BL, SEXT_BR)

	if width == 1 and height == 1 then
		putSextant(canvas, x, y, bitOr(bitOr(left, right), bitOr(top, bottom)), line, fill)
	elseif width == 1 then
		putSextant(canvas, x, y, bitOr(bitOr(left, right), top), line, fill)
		for iy = y + 1, y + height - 2 do
			putSextant(canvas, x, iy, bitOr(left, right), line, fill)
		end
		if height > 1 then
			putSextant(canvas, x, y + height - 1, bitOr(bitOr(left, right), bottom), line, fill)
		end
	elseif height == 1 then
		putSextant(canvas, x, y, bitOr(bitOr(left, top), bottom), line, fill)
		for ix = x + 1, x + width - 2 do
			putSextant(canvas, ix, y, bitOr(top, bottom), line, fill)
		end
		if width > 1 then
			putSextant(canvas, x + width - 1, y, bitOr(bitOr(right, top), bottom), line, fill)
		end
	else
		putSextant(canvas, x, y, bitOr(left, top), line, fill)
		putSextant(canvas, x + width - 1, y, bitOr(right, top), line, fill)
		putSextant(canvas, x, y + height - 1, bitOr(left, bottom), line, fill)
		putSextant(canvas, x + width - 1, y + height - 1, bitOr(right, bottom), line, fill)
		for ix = x + 1, x + width - 2 do
			putSextant(canvas, ix, y, top, line, fill)
			putSextant(canvas, ix, y + height - 1, bottom, line, fill)
		end
		for iy = y + 1, y + height - 2 do
			putSextant(canvas, x, iy, left, line, fill)
			putSextant(canvas, x + width - 1, iy, right, line, fill)
		end
	end

	if title ~= '' then
		local tfg = resolveColor(opts.titleColor) or line
		local tbg = resolveColor(opts.titleFill) or fill
		local tx = x + math.floor((width - #title) / 2)
		local savedFg = graphics.color
		local savedBg = graphics.background
		graphics.color = tfg
		graphics.background = tbg
		graphics.print(title, tx, y)
		graphics.color = savedFg
		graphics.background = savedBg
	end
end

function graphics.draw(drawable, x, y)
	local dest = graphics.currentCanvas
	if not dest or not drawable then
		return
	end
	if drawable.typeOf and not drawable:typeOf('Drawable') then
		return
	end
	if dest == drawable then
		error('Cannot draw canvas to self')
	end
	x = math.floor(x or 0)
	y = math.floor(y or 0)
	local overwrite = dest.overwrite
	if overwrite == nil then
		overwrite = graphics.overwrite
	end
	local srcBg = drawable.defaultBg or colors.black
	local sw = drawable.width or 0
	local sh = drawable.height or 0
	for sy = 1, sh do
		local row = drawable.cells[sy]
		if row then
			for sx = 1, sw do
				local cell = row[sx]
				if cell then
					local transparent = (cell.char == ' ' and cell.bg == srcBg)
					if overwrite or not transparent then
						setCell(dest, x + sx - 1, y + sy - 1, cell.char, cell.fg, cell.bg)
					end
				end
			end
		end
	end
end

function graphics.present(canvas)
	canvas = canvas or graphics.currentCanvas
	if not canvas then
		return
	end
	local tw, th = term.getSize()
	local h = math.min(canvas.height, th)
	local w = math.min(canvas.width, tw)
	for row = 1, h do
		local chars = {}
		local fgs = {}
		local bgs = {}
		local src = canvas.cells[row]
		for col = 1, w do
			local cell = src and src[col]
			if cell then
				chars[col] = cell.char
				fgs[col] = blitOf(cell.fg)
				bgs[col] = blitOf(cell.bg)
			else
				chars[col] = ' '
				fgs[col] = blitOf(colors.white)
				bgs[col] = blitOf(colors.black)
			end
		end
		term.setCursorPos(1, row)
		term.blit(table.concat(chars), table.concat(fgs), table.concat(bgs))
	end
end

function graphics.newCanvas(width, height)
	width = math.max(0, math.floor(width or 0))
	height = math.max(0, math.floor(height or 0))
	local canvas = setmetatable({
		width = width,
		height = height,
		cells = newCells(width, height, colors.white, colors.black),
		defaultBg = colors.black,
		overwrite = true,
		_graphics = graphics,
	}, Canvas)
	return canvas
end

function graphics.newImage(path)
	local img = paintutils.loadImage(path)
	if not img then
		return nil
	end
	local width = 0
	local height = 0
	for y, row in pairs(img) do
		if type(y) == 'number' and y > height then
			height = y
		end
		if type(row) == 'table' then
			for x, _ in pairs(row) do
				if type(x) == 'number' and x > width then
					width = x
				end
			end
		end
	end
	local canvas = graphics.newCanvas(width, height)
	canvas.defaultBg = colors.black
	function canvas:typeOf(kind)
		return kind == 'Image' or kind == 'Canvas' or kind == 'Drawable'
	end
	for y = 1, height do
		local row = img[y]
		if row then
			for x = 1, width do
				local col = row[x]
				if col then
					canvas.cells[y][x] = { char = ' ', fg = col, bg = col }
				end
			end
		end
	end
	return canvas
end

return graphics
