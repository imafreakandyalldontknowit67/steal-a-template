local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILibrary = require(ReplicatedStorage.UITemplates.UILibrary)

local Fusion = UILibrary.Fusion
local Themer = UILibrary.Themer
local Util = UILibrary.Util
local CombineProps = UILibrary.CombineProps
local Children = UILibrary.Children
local peek = UILibrary.peek
local Components = UILibrary.Components

local GameTheme = UILibrary.Themes.Arcade
local Widget = UILibrary.Widget
local Pane = UILibrary.Pane
local ElevatedPane = UILibrary.ElevatedPane
local ElevatedButton = UILibrary.ElevatedButton
local Divider = UILibrary.Divider
local TextInput = UILibrary.TextInput

-- Extend Components with Scroller
local Scroller = require(UILibrary.OnyxUI.Components.Scroller)
local UIComponents = table.clone(Components)
UIComponents.Scroller = Scroller

local ICON_ASSETS = {
	Player = { colored = "rbxassetid://108785416685256", silhouette = "rbxassetid://99645999579294" },
	Hammer = { colored = "rbxassetid://114351107690014", silhouette = "rbxassetid://131529560207460" },
	Announce = { colored = "rbxassetid://113637400726540", silhouette = "rbxassetid://80597717520236" },
}

-- ============================================================
-- AdminPanel-specific sub-components
-- ============================================================

local function AdminSection(Scope, Props)
	Scope = Fusion.innerScope(Scope, Fusion, Util, UIComponents)
	local Theme = Themer.Theme:now()

	return Pane(Scope, {
		LayoutOrder = Props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = { All = Scope:UDim(0, Theme.Padding.Base) },
		[Children] = {
			Scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = Scope:UDim(0, Theme.Padding["0.5"]),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			Divider(Scope, {
				Text = Props.Title,
				LayoutOrder = 1,
			}),
			Scope:Frame {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				[Children] = {
					Scope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = Scope:UDim(0, Theme.Padding.Base),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					Props[Children],
				},
			},
		},
	})
end

-- ============================================================
-- Main component
-- ============================================================

local function AdminPanelComponent(Scope, Props)
	Scope = Fusion.innerScope(Scope, Fusion, Util, UIComponents)
	local Theme = Themer.Theme:now()

	local kickUsername = Scope:Value("")
	local kickDuration = Scope:Value("")
	local banUsername = Scope:Value("")
	local banDuration = Scope:Value("")
	local announcementText = Scope:Value("")

	-- Sizing math:
	-- Header(104) + Padding(32) = 136px overhead
	-- Content rows: 3 sections
	-- Each section: Divider(~40) + Inputs/Buttons(~120-180) + Padding(~32) ≈ 250px
	-- Total height ≈ 136 + (250 * 3) + 30 buffer ≈ 916px
	return Widget(Scope, CombineProps(Props, {
		Name = "AdminPanel",
		Size = Scope:UDim2Offset(800, 920),
		HeadingBanner = {
			Text = "Admin Panel",
		},
		[Children] = {
			Scope:Scroller {
				Size = UDim2.fromScale(1, 1),
				Padding = {},
				List = {
					Padding = Scope:UDim(0, Theme.Padding.Base),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					AdminSection(Scope, {
						Title = "Kick Player",
						LayoutOrder = 1,
						[Children] = {
							TextInput(Scope, {
								Text = kickUsername,
								PlaceholderText = "Username...",
								Size = UDim2.new(1, 0, 0, 50),
								LayoutOrder = 1,
							}),
							TextInput(Scope, {
								Text = kickDuration,
								PlaceholderText = "Reason / Duration...",
								Size = UDim2.new(1, 0, 0, 50),
								LayoutOrder = 2,
							}),
							ElevatedButton(Scope, {
								Size = UDim2.new(1, 0, 0, 60),
								LayoutOrder = 3,
								ColorSequence = Scope:Computed(function(use)
									return ColorSequence.new(use(use(Theme.Colors.Warning).Main), use(use(Theme.Colors.Warning).Dark))
								end),
								OnActivate = function()
									print("Kicking player:", peek(kickUsername), "for:", peek(kickDuration))
									if Props.OnKick then Props.OnKick(peek(kickUsername), peek(kickDuration)) end
								end,
								[Children] = {
									Scope:Image {
										Image = ICON_ASSETS.Hammer.silhouette,
										ImageColor3 = Scope:Computed(function(use) return use(use(Theme.Colors.BaseContent).Main) end),
										Size = UDim2.fromOffset(32, 32),
										BackgroundTransparency = 1,
									},
									Scope:Heading {
										Text = "Kick Player",
										TextSize = Theme.TextSize["1.25"],
										TextXAlignment = Enum.TextXAlignment.Center,
									},
								},
							}),
						},
					}),

					AdminSection(Scope, {
						Title = "Ban Player",
						LayoutOrder = 2,
						[Children] = {
							TextInput(Scope, {
								Text = banUsername,
								PlaceholderText = "Username...",
								Size = UDim2.new(1, 0, 0, 50),
								LayoutOrder = 1,
							}),
							TextInput(Scope, {
								Text = banDuration,
								PlaceholderText = "Duration (e.g. 1d, 7d, perm)...",
								Size = UDim2.new(1, 0, 0, 50),
								LayoutOrder = 2,
							}),
							ElevatedButton(Scope, {
								Size = UDim2.new(1, 0, 0, 60),
								LayoutOrder = 3,
								ColorSequence = Scope:Computed(function(use)
									return ColorSequence.new(use(use(Theme.Colors.Error).Main), use(use(Theme.Colors.Error).Dark))
								end),
								OnActivate = function()
									print("Banning player:", peek(banUsername), "for:", peek(banDuration))
									if Props.OnBan then Props.OnBan(peek(banUsername), peek(banDuration)) end
								end,
								[Children] = {
									Scope:Image {
										Image = ICON_ASSETS.Hammer.colored,
										Size = UDim2.fromOffset(32, 32),
										BackgroundTransparency = 1,
									},
									Scope:Heading {
										Text = "Ban Player",
										TextSize = Theme.TextSize["1.25"],
										TextXAlignment = Enum.TextXAlignment.Center,
									},
								},
							}),
						},
					}),

					AdminSection(Scope, {
						Title = "Global Announcement",
						LayoutOrder = 3,
						[Children] = {
							TextInput(Scope, {
								Text = announcementText,
								PlaceholderText = "Enter announcement message...",
								Size = UDim2.new(1, 0, 0, 80),
								LayoutOrder = 1,
							}),
							ElevatedButton(Scope, {
								Size = UDim2.new(1, 0, 0, 60),
								LayoutOrder = 2,
								ColorSequence = Scope:Computed(function(use)
									return ColorSequence.new(use(use(Theme.Colors.Info).Main), use(use(Theme.Colors.Info).Dark))
								end),
								OnActivate = function()
									print("Announcing:", peek(announcementText))
									if Props.OnAnnounce then Props.OnAnnounce(peek(announcementText)) end
								end,
								[Children] = {
									Scope:Image {
										Image = ICON_ASSETS.Announce.silhouette,
										ImageColor3 = Scope:Computed(function(use) return use(use(Theme.Colors.BaseContent).Main) end),
										Size = UDim2.fromOffset(32, 32),
										BackgroundTransparency = 1,
									},
									Scope:Heading {
										Text = "Send Announcement",
										TextSize = Theme.TextSize["1.25"],
										TextXAlignment = Enum.TextXAlignment.Center,
									},
								},
							}),
						},
					}),
				},
			},
		},
	}))
end

export type Props = {
	OnKick: ((username: string, duration: string) -> ())?,
	OnBan: ((username: string, duration: string) -> ())?,
	OnAnnounce: ((text: string) -> ())?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	return Themer.Theme:is(GameTheme):during(function()
		local innerScope = Fusion.innerScope(Scope, Fusion, Util, UIComponents)
		return AdminPanelComponent(innerScope, Props)
	end)
end
