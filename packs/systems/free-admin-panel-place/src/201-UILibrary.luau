--[=[
	@class UILibrary

	Shared boilerplate components for UI templates.

	Exports: Themes (5 named themes), GameTheme (= Themes.Lemonade, default),
	Pane, ElevatedPane, ElevatedButton, CloseButton, HeadingBanner, LemonadeTag,
	Widget, Divider, TextInput, plus OnyxUI/Fusion re-exports.

	The component functions (Pane, ElevatedPane, ...) are dispatchers: they look
	up the currently-active `Themer.Theme` (via `Themer.Theme:now().ThemeName`)
	and forward to the matching per-theme implementation under `script.themes`.
	Themes without a dedicated module fall back to Lemonade.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OnyxUI = ReplicatedStorage.Packages.OnyxUI.Packages.OnyxUI
local Fusion = require(OnyxUI.Parent.Fusion)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)
local Text = require(OnyxUI.Components.Text)
local Heading = require(OnyxUI.Components.Heading)
local Group = require(OnyxUI.Components.Group)
local BaseButton = require(OnyxUI.Components.BaseButton)

local CombineProps = Util.CombineProps
local Children = Fusion.Children
local peek = Fusion.peek

local Components = {
	Frame = Frame,
	Image = Image,
	Text = Text,
	Heading = Heading,
	Group = Group,
	BaseButton = BaseButton,
}

-- ============================================================
-- Theme Registry (5 named themes)
-- ============================================================
-- Each theme config carries a `ThemeName` sentinel that dispatchers read to
-- decide which per-theme component module to use.

local ThemeConfigs = {
	Lemonade = {
		ThemeName = "Lemonade",
		Colors = {
			Primary = { Main = Color3.fromHex "00F7FF", Dark = Color3.fromHex "0066FF" },
			Secondary = { Main = Color3.fromHex "FFF600", Dark = Color3.fromHex "00A700" },
			Accent = { Main = Color3.new(1, 1, 1) },
			Neutral = { Main = Color3.fromHex "BABABA", Dark = Color3.fromHex "525252" },
			NeutralContent = { Main = Color3.fromHex "A8A29E" },
			Base = { Main = Color3.fromHex "0F1519" },
			BaseContent = { Main = Color3.new(1, 1, 1) },
			Success = { Main = Color3.fromHex "22C55E" },
			Error = { Main = Color3.fromHex "EF4444" },
			Warning = { Main = Color3.fromHex "F59E0B" },
			Info = { Main = Color3.fromHex "22D3EE" },
		},
		Font = {
			Body = "rbxasset://fonts/families/Montserrat.json",
			Heading = "rbxasset://fonts/families/Montserrat.json",
			Monospace = "rbxasset://fonts/families/Montserrat.json",
		},
		FontWeight = {
			Body = Enum.FontWeight.Bold,
			Bold = Enum.FontWeight.Bold,
			Heading = Enum.FontWeight.ExtraBold,
		},
		TextSize = { Base = 20 },
		CornerRadius = { Base = 8 },
		StrokeThickness = { Base = 4 },
		StrokeEmphasis = { Regular = 0.2 },
		Spacing = { Base = 22 },
		Sizing = { Base = 22 },
		Padding = { Base = 16 },
		SpringSpeed = { Base = 50 },
		SpringDampening = { Base = 1 },
		Sound = {},
		Emphasis = {},
	},

	Midnight = {
		ThemeName = "Midnight",
		Colors = {
			Primary = { Main = Color3.fromHex "4F6BFF", Dark = Color3.fromHex "1E2A78" },
			Secondary = { Main = Color3.fromHex "2F3A52", Dark = Color3.fromHex "3F4D6B" },
			Accent = { Main = Color3.fromHex "8FB4FF" },
			Neutral = { Main = Color3.fromHex "9AA4B8", Dark = Color3.fromHex "4A5268" },
			NeutralContent = { Main = Color3.fromHex "BCC2CE" },
			Base = { Main = Color3.fromHex "0A0F1C" },
			BaseContent = { Main = Color3.fromHex "F5F7FF" },
			Success = { Main = Color3.fromHex "22C55E" },
			Error = { Main = Color3.fromHex "EF4444" },
			Warning = { Main = Color3.fromHex "F59E0B" },
			Info = { Main = Color3.fromHex "60A5FA" },
		},
		Font = {
			Body = "rbxasset://fonts/families/Montserrat.json",
			Heading = "rbxasset://fonts/families/Montserrat.json",
			Monospace = "rbxasset://fonts/families/Montserrat.json",
		},
		FontWeight = {
			Body = Enum.FontWeight.Medium,
			Bold = Enum.FontWeight.Bold,
			Heading = Enum.FontWeight.ExtraBold,
		},
		TextSize = { Base = 20 },
		CornerRadius = { Base = 8 },
		StrokeThickness = { Base = 3 },
		StrokeEmphasis = { Regular = 0.2 },
		Spacing = { Base = 22 },
		Sizing = { Base = 22 },
		Padding = { Base = 16 },
		SpringSpeed = { Base = 50 },
		SpringDampening = { Base = 1 },
		Sound = {},
		Emphasis = {},
	},

	Pastel = {
		ThemeName = "Pastel",
		Colors = {
			Primary = { Main = Color3.fromHex "F6C9D7", Dark = Color3.fromHex "DCCFFB" },
			Secondary = { Main = Color3.fromHex "CFEEDD", Dark = Color3.fromHex "CFE7FF" },
			Accent = { Main = Color3.fromHex "FFF9F5" },
			Neutral = { Main = Color3.fromHex "CFC8DA", Dark = Color3.fromHex "9A93AB" },
			NeutralContent = { Main = Color3.fromHex "8A7E9E" },
			Base = { Main = Color3.fromHex "F8F7FC" },
			BaseContent = { Main = Color3.fromHex "5E5873" },
			Success = { Main = Color3.fromHex "7BCD92" },
			Error = { Main = Color3.fromHex "E88899" },
			Warning = { Main = Color3.fromHex "E8B46B" },
			Info = { Main = Color3.fromHex "7FB5D9" },
		},
		Font = {
			Body = "rbxasset://fonts/families/Nunito.json",
			Heading = "rbxasset://fonts/families/FredokaOne.json",
			Monospace = "rbxasset://fonts/families/Nunito.json",
		},
		FontWeight = {
			Body = Enum.FontWeight.SemiBold,
			Bold = Enum.FontWeight.Bold,
			Heading = Enum.FontWeight.Regular,
		},
		TextSize = { Base = 20 },
		CornerRadius = { Base = 16 },
		StrokeThickness = { Base = 2 },
		StrokeEmphasis = { Regular = 0.15 },
		Spacing = { Base = 26 },
		Sizing = { Base = 22 },
		Padding = { Base = 20 },
		SpringSpeed = { Base = 40 },
		SpringDampening = { Base = 1.1 },
		Sound = {},
		Emphasis = {},
	},

	Arcade = {
		ThemeName = "Arcade",
		Colors = {
			Primary = { Main = Color3.fromHex "2F7BFF", Dark = Color3.fromHex "FF3CAC" },
			Secondary = { Main = Color3.fromHex "FFD400", Dark = Color3.fromHex "7CFF4F" },
			Accent = { Main = Color3.fromHex "FFFFFF" },
			Neutral = { Main = Color3.fromHex "4A5A7E", Dark = Color3.fromHex "2B3650" },
			NeutralContent = { Main = Color3.fromHex "C4CFE4" },
			Base = { Main = Color3.fromHex "10182A" },
			BaseContent = { Main = Color3.fromHex "F8FBFF" },
			Success = { Main = Color3.fromHex "22E55D" },
			Error = { Main = Color3.fromHex "FF4D4F" },
			Warning = { Main = Color3.fromHex "FFB800" },
			Info = { Main = Color3.fromHex "3BE7FF" },
		},
		Font = {
			Body = "rbxasset://fonts/families/FredokaOne.json",
			Heading = "rbxasset://fonts/families/LuckiestGuy.json",
			Monospace = "rbxasset://fonts/families/RobotoMono.json",
		},
		FontWeight = {
			Body = Enum.FontWeight.Regular,
			Bold = Enum.FontWeight.Bold,
			Heading = Enum.FontWeight.Regular,
		},
		TextSize = { Base = 22 },
		CornerRadius = { Base = 12 },
		StrokeThickness = { Base = 4 },
		StrokeEmphasis = { Regular = 0.2 },
		Spacing = { Base = 22 },
		Sizing = { Base = 24 },
		Padding = { Base = 18 },
		SpringSpeed = { Base = 55 },
		SpringDampening = { Base = 1 },
		Sound = {},
		Emphasis = {},
	},

	Industrial = {
		ThemeName = "Industrial",
		Colors = {
			Primary = { Main = Color3.fromHex "F59E0B", Dark = Color3.fromHex "D97706" },
			Secondary = { Main = Color3.fromHex "6B7280", Dark = Color3.fromHex "374151" },
			Accent = { Main = Color3.fromHex "D1D5DB" },
			Neutral = { Main = Color3.fromHex "9CA3AF", Dark = Color3.fromHex "4B5563" },
			NeutralContent = { Main = Color3.fromHex "D1D5DB" },
			Base = { Main = Color3.fromHex "1A1D21" },
			BaseContent = { Main = Color3.fromHex "F3F4F6" },
			Success = { Main = Color3.fromHex "22C55E" },
			Error = { Main = Color3.fromHex "DC2626" },
			Warning = { Main = Color3.fromHex "FBBF24" },
			Info = { Main = Color3.fromHex "60A5FA" },
		},
		Font = {
			Body = "rbxasset://fonts/families/RobotoCondensed.json",
			Heading = "rbxasset://fonts/families/RobotoCondensed.json",
			Monospace = "rbxasset://fonts/families/RobotoMono.json",
		},
		FontWeight = {
			Body = Enum.FontWeight.SemiBold,
			Bold = Enum.FontWeight.Bold,
			Heading = Enum.FontWeight.ExtraBold,
		},
		TextSize = { Base = 20 },
		CornerRadius = { Base = 2 },
		StrokeThickness = { Base = 5 },
		StrokeEmphasis = { Regular = 0.25 },
		Spacing = { Base = 20 },
		Sizing = { Base = 22 },
		Padding = { Base = 16 },
		SpringSpeed = { Base = 70 },
		SpringDampening = { Base = 1.1 },
		Sound = {},
		Emphasis = {},
	},
}

-- Instantiate each theme in its own Fusion scope so state objects don't collide.
local Themes = {}
for name, config in pairs(ThemeConfigs) do
	Themes[name] = Themer.NewTheme(Fusion.scoped(Fusion), config)
end

-- Default GameTheme: picks the theme named by _G.__THEME_NAME (set by the
-- introspection/render pipeline), falling back to Lemonade for back-compat.
local GameTheme = Themes[_G.__THEME_NAME] or Themes.Lemonade

-- ============================================================
-- Per-theme component dispatch
-- ============================================================
-- Each theme module is a factory that takes the shared deps bag and returns a
-- table of theme-flavored components. Missing modules fall back to Lemonade so
-- rollouts can be incremental (skeleton phase = only Lemonade).

local deps = {
	Fusion = Fusion,
	Themer = Themer,
	Util = Util,
	ColorUtils = ColorUtils,
	CombineProps = CombineProps,
	Children = Children,
	peek = peek,
	Components = Components,
}

local themesFolder = script:FindFirstChild("themes")
local lemonadeComponents
local themeComponents = {}

if themesFolder then
	for name in pairs(ThemeConfigs) do
		local moduleScript = themesFolder:FindFirstChild(name)
		if moduleScript then
			themeComponents[name] = require(moduleScript)(deps)
		end
	end
end

lemonadeComponents = assert(themeComponents.Lemonade, "UILibrary: themes/Lemonade module is required")

local function currentThemeComponents()
	local active = Themer.Theme:now()
	local name = active and active.ThemeName or "Lemonade"
	return themeComponents[name] or lemonadeComponents
end

local function Pane(Scope, Props)
	return currentThemeComponents().Pane(Scope, Props)
end

local function ElevatedPane(Scope, Props)
	return currentThemeComponents().ElevatedPane(Scope, Props)
end

local function ElevatedButton(Scope, Props)
	return currentThemeComponents().ElevatedButton(Scope, Props)
end

local function CloseButton(Scope, Props)
	return currentThemeComponents().CloseButton(Scope, Props)
end

local function HeadingBanner(Scope, Props)
	return currentThemeComponents().HeadingBanner(Scope, Props)
end

local function Widget(Scope, Props)
	return currentThemeComponents().Widget(Scope, Props)
end

local function Divider(Scope, Props)
	return currentThemeComponents().Divider(Scope, Props)
end

local function TextInput(Scope, Props)
	return currentThemeComponents().TextInput(Scope, Props)
end

-- LemonadeTag is Lemonade-brand specific. Profile.luau still calls it directly
-- to render the footer, so route every caller to the Lemonade module's
-- implementation regardless of the active theme.
local function LemonadeTag(Scope, Props)
	return lemonadeComponents.LemonadeTag(Scope, Props)
end

-- ============================================================
-- Exports
-- ============================================================

return {
	-- Themes
	Themes = Themes,
	GameTheme = GameTheme,

	-- Shared components (dispatchers)
	Pane = Pane,
	ElevatedPane = ElevatedPane,
	ElevatedButton = ElevatedButton,
	CloseButton = CloseButton,
	HeadingBanner = HeadingBanner,
	LemonadeTag = LemonadeTag,
	Widget = Widget,
	Divider = Divider,
	TextInput = TextInput,

	-- Re-exports for template use
	Fusion = Fusion,
	Themer = Themer,
	Util = Util,
	ColorUtils = ColorUtils,
	CombineProps = CombineProps,
	Children = Children,
	peek = peek,

	-- Base Components table (templates can extend with table.clone)
	Components = Components,

	-- OnyxUI path for requiring additional components (Scroller, Avatar, etc.)
	OnyxUI = OnyxUI,
}
