--[[
	StudTexture (client)

	The stud texture used behind the menus, built in-game from the pixel data below, so it
	needs no uploaded image. It is a seamless 64x64 tile of light/shadow only (transparent
	where flat), so it adds stud bumps on top of whatever colour a background already has.

	Usage:  StudTexture.apply(imageLabel)  -- sets the label's image to the stud tile

	In a live game this needs Game Settings > Security > "Allow Mesh / Image APIs" turned on.
	If it's off (or anything fails) the label is simply hidden and the plain background shows.
]]

local AssetService = game:GetService("AssetService")

local StudTexture = {}

local SIZE = 64
-- one byte per pixel: 128 = flat, above = lighter, below = darker
local DATA = "gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAfoCAgICAfn2AgICAgICAgICAgICAgICAfoCAgH5+gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICCgoKCfn5+fn5+fn5+fn5+fn5+foWCgICCgoB7gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIB+fn19foCAgICAgICAgICAgICAgIB7gIKAenmAhYCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgH5+fn5+fn5+gICDhISDgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgHp7fHx8enl4enp6enp6enp6enp6enp6enl5ent9fHp3gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIB4fIOKj5GRkJCQkJCRkZGRkJCQkJCQkJCOkZSSjIR7doCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4yaqbS7vby5ubm5ubm5ubq6urq6urq6u7e3vMC1nYeAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIuSnKaqqaSho6OjpKSkpKSlpaWlpaWlpamko6q3vr24gICAgICAgICAgICAgICAgICAgICAgICAgH6CgICCfH6Ch4+Ypa+ooqKioqKioqKio6Ojo6Ojo6Osq6yxsrK4v7mFeneAgIB+gICAgICAgICAgICAgICAgIB+goCAgHh6dnyGj5ynoJaWlpaWlpaWlpmZmZmZmpqanqSutru+vLq6nXp5gICAgICAgICAgICAgICAgICAgICAgIJ+gHxxdHV1d3qLoqego6Ojo6Ojo6OkpKSkpKSkpKKrtLjAxcC2ureAfIJ8foOAgICAgICAgICAgICAgICAgICAfoB4aW1qZWJpgqW3trW1tbW1tbW1tbW1tbW1tbWzury4u8G/t7e+i36De4CCgICAgICAgICAgICAgICAgICAgH6AdWNoVk5SZH6cq6asrKysrKysrK2tra2tra2tq7K4ubm7urWytJZ+g32AfoCAgICAgICAgICAgICAgIB+gICAgnRfZlBBRl92h4+IiIiIiIiIiIiIiIiIiIiIiI2WqLm9trCwrquafYJ+gH2AgICAgICAgICAgICAgICAfYCAgIR0XmVSOTtcc36GhIeHh4eHh4eHhoaGhoaGhoaCg5azu6ylrK6tlX6AgH6AgICAgICAgICAgICAgICAgH2AgICGdV1lUjU5YXmAiIiHh4eHh4eHh4iIiIiIiIiIj4KOq7SinquvtY5+fYB8g4CAgICAgICAgICAgICAgICAgIB+gndgYlA3Oltygo2DiIiIiIiIiIiIiIiIiIiIiIeIiK+1pZamqLeTeoCAfoCAgICAgICAgICAgICAgICAgICAfoN3YGJQNzpbcoKNg4iIiIiIiIiIiIiIiIiIiIiHiIivtaWWpqe3k3uAgH6AgICAgICAgICAgICAgICAgICAgH6Dd19iUDc6W3KCjYOIiIiIiIiIiIiIiIiIiIiIh4iIr7SllqWnt5N7gIB+gICAgICAgICAgICAgICAgICAgH5+hXZeY1A3Oltygo2DiIiIiIiIiIiIiIiIiIiIiIeIiK+0pJWlp7eSe4CAfoCAgICAgICAgICAgICAgICAgIB+foZ2XGRQNzpbcoKNg4iIiIiIiIiIiIiIiIiIiIiHiIivtKSVpKe3knuAgH6AgICAgICAgICAgICAgICAgICAfn6HdVxmUDc6W3KCjYOIiIiIiIiIiIiIiIiIiIiIh4iIrrOjlKSmt5J7gIB+gICAgICAgICAgICAgICAgICAgH1+iHVaZlA3Oltygo2DiIiIiIiIiIiIiIiIiIiIiIeIh66zo5SjpreRe4CAfoCAgICAgICAgICAgICAgICAgIB9foh1WmZQNzpbcoKNg4iIiIiIiIiIiIiIiIiIiIiHiIeus6OUo6a4kXuAgH6AgICAgICAgICAgICAgICAgIB+gICFdVpmTzg3XXOAkYeIiIiIiIiIiIiIiIiIiIiIh4WJsLWekZ+js5F6gH6AgICAgICAgICAgICAgICAgICAfoCAhXVaZk84N11zgJGHiIiIiIiIiIiIiIiIiIiIiIeFibC1npGfo7OQeoB+gICAgICAgICAgICAgICAgICAgH6AgIV1WWZPODdcc4CRhoiIiIiIiIiIiIiIiIiIiIiHhYmwtZ6Rn6OzkHqAgICAgICAgICAgICAgICAgICAgIB+gICFdVlmTzg3XHOAkIaIiIiIiIiIiIiIiIiIiIiIh4WJsLWekZ+js5B6gICAgICAgICAgICAgICAgICAgICAfoCAhXVZZk84N1xzgJCGiIiIiIiIiIiIiIiIiIiIiIeFibC1npGfo7OQeoCAgICAgICAgICAgICAgICAgICAgH6AgIV1WWVOODZcc4CQhoiIiIiIiIiIiIiIiIiIiIiHhYmwtZ6Rn6OzkHqAgICAgICAgICAgICAgICAgICAgIB+gICFdVllTjg2XHOAkIaIiIiIiIiIiIiIiIiIiIiIh4WJsLWekZ+js5B6gICAgICAgICAgICAgICAgICAgICAfoCAhXVZZU43NlxygJCGiIiIiIiIiIiIiIiIiIiIiIeFibC1npGfo7OQeoCAgICAgICAgICAgICAgICAgICAgIN8gIZxXWBQNjxYan2IgIaGhoaGhoaGiIiIiIiIiIiEfomms6OXnKiykXp+gIB9gICAgICAgICAgICAgICAgICCfYCIdFxmTjY7V2yCkYuRkZGRkZGRkZKSkpKSkpKSkouRpa6hnaiqspJ7foCAfoCAgICAgICAgICAgICAgICAgICAiHVZak03OE1fdYSDfX19fX19fX17e3t7e3t7e4iChJCVkputrLKTfX6AgICAgICAgICAgICAgICAgICAgH6AfoZ1VGZOOzU/S1xpa3BwcHBwcHBwb29vb29vb29ybm90d3uLn6mukoCAgICAgICAgICAgICAgICAgICAgIB+gn2DdVRcUEE3Nz5IUVRYWFhYWFhYWFtbW1tbW1tbWlhZXWNtfo6gpY6AgH6AgICAgICAgICAgICAgICAgICAfoB+gHlcVFRLPjc4Ojw/ODg4ODg4ODg3Nzc3Nzc3Nz0+Q0xYaXqEkpiIgIB+gICAgICAgICAgICAgICAgICAgn6AgICAalFZVkpAPzw5PDw8PDw8PDw8Ojo6Ojo6Ojo3OD1GVmp5foSMgoCAfoCAgICAgICAgICAgICAgICAgIJ+gICCh3ZSWl1VTU5LSExISEhISEhISEtLS0tLS0tLUE5OUl5veXh8hH1+gH6AgICAgICAgICAgICAgICAgICAgICAgICAgFVUVVtiZmNfY2NjY2NiYmJhYWFgYGBgX2VkY2RnbHF0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIBuZFhRUVVXV1RUVFVVVlZWVlZWV1dXWFhXWFpfZm52eoCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiIB1b25vb25xcXFwcHBwcHJycnFxcXBwdXR0dXd7gIKAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgISCgoOGhoOAg4OCgoKCgoKEhIODg4ODg4SDgICAgoSFgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIB9fHt8foCAfn5+gICAgICAfoCAgICAgICAgH5+foCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgoCAgICAgICCgoKCgICAgICAgICAgICAg4OCgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgoSEg4KAfn5+gICAgICAgICAgICAgH6AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIB+fn59fX6AgoCAgICAgICAgICAgICAgICAgICAgH59fYCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgA=="

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function decode(text: string): { number }
	local lookup = {}
	for i = 1, #ALPHABET do
		lookup[string.byte(ALPHABET, i)] = i - 1
	end
	local bytes = table.create(SIZE * SIZE)
	local bits, count = 0, 0
	for i = 1, #text do
		local value = lookup[string.byte(text, i)]
		if value then
			bits = bit32.bor(bit32.lshift(bits, 6), value)
			count += 6
			if count >= 8 then
				count -= 8
				table.insert(bytes, bit32.band(bit32.rshift(bits, count), 255))
				bits = bit32.band(bits, bit32.lshift(1, count) - 1)
			end
		end
	end
	return bytes
end

local content: Content? = nil
local failed = false

local function build(): Content?
	if content or failed then
		return content
	end
	local ok, result = pcall(function()
		local bytes = decode(DATA)
		local pixels = buffer.create(SIZE * SIZE * 4)
		for i = 0, SIZE * SIZE - 1 do
			local delta = (bytes[i + 1] or 128) - 128
			local shade, alpha = 0, 0
			if delta > 0 then
				shade, alpha = 255, math.min(1, delta / 70) -- highlight
			elseif delta < 0 then
				shade, alpha = 0, math.min(1, -delta / 79) -- shadow
			end
			buffer.writeu8(pixels, i * 4, shade)
			buffer.writeu8(pixels, i * 4 + 1, shade)
			buffer.writeu8(pixels, i * 4 + 2, shade)
			buffer.writeu8(pixels, i * 4 + 3, math.floor(alpha * 255 + 0.5))
		end
		local image = AssetService:CreateEditableImage({ Size = Vector2.new(SIZE, SIZE) })
		image:WritePixelsBuffer(Vector2.zero, Vector2.new(SIZE, SIZE), pixels)
		return Content.fromObject(image)
	end)
	if ok and result then
		content = result
	else
		failed = true
		warn("[EggShop] Stud texture is off:", tostring(result),
			"- turn on Game Settings > Security > Allow Mesh / Image APIs to show it.")
	end
	return content
end

-- Point an ImageLabel at the stud tile (one shared image for every label). Returns true if shown.
function StudTexture.apply(label: ImageLabel): boolean
	local tile = build()
	if tile then
		label.ImageContent = tile
		label.Visible = true
		return true
	end
	label.Visible = false
	return false
end

return StudTexture
