--[=[
	@class LemonadeTheme

	Lemonade theme component implementations.

	Exported as a factory: require this module and call it with the shared deps
	bag from UILibrary to get a table of theme-flavored components:
		{ Pane, ElevatedPane, ElevatedButton, CloseButton, HeadingBanner, Widget,
		  Divider, TextInput }

	Implementations are the original UILibrary components, moved verbatim so
	the skeleton refactor produces zero visual change.
]=]

return function(deps)
	local Fusion = deps.Fusion
	local Themer = deps.Themer
	local Util = deps.Util
	local ColorUtils = deps.ColorUtils
	local CombineProps = deps.CombineProps
	local Children = deps.Children
	local Components = deps.Components

	local function Pane(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local children = Props[Children] or {}
		Props[Children] = nil

		return Scope:Frame(CombineProps(Props, {
			ClipsDescendants = true,
			AutomaticSize = Enum.AutomaticSize.None,
			Name = "Pane",
			Size = Scope:UDim2Offset(100, 100),
			BackgroundTransparency = 0.35,
			BackgroundColor3 = Theme.Colors.Base.Main,
			Corner = {
				Radius = Scope:UDim(0, Theme.CornerRadius.Base),
			},
			Stroke = {
				Thickness = Theme.StrokeThickness.Base,
				Color = Color3.new(0, 0, 0),
			},
			[Children] = {
				Scope:Frame {
					Size = UDim2.fromScale(1, 1),
					AutomaticSize = Enum.AutomaticSize.None,
					[Children] = Props.Background or {},
				},
				Scope:Image {
					Image = "rbxassetid://135275431100741",
					Size = UDim2.fromOffset(1200, 1200),
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(1, 1),
					ImageTransparency = 0.4,
					BackgroundTransparency = 1,
				},
				Scope:Frame {
					Size = UDim2.fromScale(1, 1),
					AutomaticSize = Enum.AutomaticSize.None,
					[Children] = children or {},
				},
			},
		}))
	end

	local function ElevatedPane(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local children = Props[Children] or {}
		Props[Children] = nil
		local padding = Props["Padding"] or nil
		Props.Padding = nil

		local size = Props.Size or Scope:UDim2(1, 0, 0, 104)
		local colorSequence = Props.ColorSequence
			or Scope:Computed(function(use)
				return ColorSequence.new(use(Theme.Colors.Primary.Main), use(Theme.Colors.Primary.Dark))
			end)
		local dark = Scope:Computed(function(use)
			local keypoints = use(colorSequence).Keypoints
			return ColorUtils.Darken(keypoints[#keypoints].Value, 0.5)
		end)

		local corner = Props.Corner or { Enabled = false }
		Props.Corner = nil

		return Scope:Frame(CombineProps(Props, {
			Size = size,
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = 0,
			BackgroundColor3 = dark,
			Stroke = { Color = Color3.new(0, 0, 0) },
			Corner = corner,
			[Children] = {
				Scope:Frame {
					Size = Scope:Computed(function(use)
						return UDim2.fromScale(1, 1) - UDim2.fromOffset(0, use(Props.Elevation) or 8)
					end),
					AutomaticSize = Enum.AutomaticSize.None,
					[Children] = {
						Pane(Scope, {
							Corner = corner,
							Stroke = { Enabled = false },
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Background = {
								Scope:Frame {
									Size = UDim2.fromScale(1, 1),
									AutomaticSize = Enum.AutomaticSize.None,
									BackgroundTransparency = 0,
									Gradient = { Color = colorSequence, Rotation = 90 },
									Corner = corner,
									[Children] = {
										Scope:New "UIStroke" {
											Thickness = Theme.StrokeThickness.Base,
											Color = Color3.new(1, 1, 1),
											Transparency = 0.4,
											BorderStrokePosition = Enum.BorderStrokePosition.Inner,
											[Children] = {
												Scope:New "UIGradient" {
													Transparency = NumberSequence.new(1, 0),
													Rotation = 90,
												},
											},
										},
									},
								},
							},
						[Children] = {
							Scope:Frame {
								Size = UDim2.fromScale(1, 1),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 1,
								Padding = padding,
								[Children] = { children },
							},
						},
						}),
					},
				},
			},
		}))
	end

	local function ElevatedButton(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local children = Props[Children] or {}
		Props[Children] = nil

		local hovering = Scope:Value(false)
		local holding = Scope:Value(false)
		local rawScale = Scope:Spring(
			Scope:Computed(function(use)
				if use(holding) then return 0.85
				elseif use(hovering) then return 1.025
				else return 1 end
			end),
			Scope:Computed(function(use)
				if use(holding) then return 10000 else return 25 end
			end),
			0.25
		)

		return Scope:BaseButton(CombineProps(Props, {
			Name = "ElevatedButton",
			Size = Scope:UDim2Offset(270, 50),
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme.Colors.Base.Main,
			AutomaticSize = Enum.AutomaticSize.None,
			Hovering = hovering,
			Holding = holding,
			[Children] = {
				Scope:New "Frame" {
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					[Children] = {
						Scope:New "UIScale" {
							Scale = Scope:Computed(function(use)
								return math.round(use(rawScale) * 100) / 100
							end),
						},
						ElevatedPane(Scope, CombineProps(Props.ElevatedPane or {}, {
							Elevation = 4,
							Size = UDim2.fromScale(1, 1),
							Corner = { Radius = Scope:UDim(0, Theme.CornerRadius.Base) },
							ColorSequence = Props.ColorSequence,
							[Children] = {
								Scope:Frame {
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromScale(0.5, 0.5),
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutomaticSize = Enum.AutomaticSize.None,
									BackgroundTransparency = Scope:Spring(
										Scope:Computed(function(use)
											if use(holding) then return 0.5
											elseif use(hovering) then return 0.75
											else return 1 end
										end),
										100
									),
								},
								-- ButtonContent: auto-centers all children horizontally and vertically
								Scope:New "Frame" {
									Name = "ButtonContent",
									Size = UDim2.fromScale(1, 1),
									BackgroundTransparency = 1,
									[Children] = {
										Scope:New "UIListLayout" {
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											FillDirection = Enum.FillDirection.Horizontal,
											Padding = UDim.new(0, 8),
											SortOrder = Enum.SortOrder.LayoutOrder,
										},
										children,
									},
								},
							},
						})),
					},
				},
			},
		}))
	end

	local function CloseButton(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()
		local hidden = Props.Hidden or false

		return ElevatedButton(Scope, CombineProps(Props, {
			-- Close button uses the theme's Error color (red-ish across all themes).
			ColorSequence = Scope:Computed(function(use)
				local base = use(Theme.Colors.Error.Main)
				return ColorSequence.new(base, ColorUtils.Darken(base, 0.4))
			end),
			Size = UDim2.fromOffset(60, 60),
			Visible = Scope:Computed(function(use)
				return not use(hidden)
			end),
			[Children] = {
				Scope:Text {
					Text = "X",
					TextSize = Theme.TextSize["1.875"],
					Stroke = {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						Color = Color3.new(0, 0, 0),
						LineJoinMode = Enum.LineJoinMode.Round,
					},
				},
			},
		}))
	end

	local function HeadingBanner(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local children = Props[Children] or {}
		Props[Children] = nil

		return ElevatedPane(Scope, CombineProps(Props, {
			Size = Scope:UDim2(1, 0, 0, 104),
			[Children] = {
				children,
				Scope:Group {
					Size = UDim2.fromScale(1, 1),
					[Children] = {
						Scope:New "Frame" {
							Size = UDim2.fromOffset(45, 200),
							BackgroundTransparency = 0.5,
							Position = UDim2.fromOffset(30, -30),
							Rotation = 8,
						},
						Scope:New "Frame" {
							Size = UDim2.fromOffset(25, 200),
							BackgroundTransparency = 0.5,
							Position = UDim2.fromOffset(85, -30),
							Rotation = 8,
						},
					},
				},
				Scope:Frame {
					Size = Scope:UDim2Scale(1, 1),
					AutomaticSize = Enum.AutomaticSize.None,
					Padding = {},
					[Children] = {
						Scope:Heading {
							Position = UDim2.fromScale(0, 0.5),
							AnchorPoint = Vector2.new(0, 0.5),
							Text = Props.Text or "Heading",
							TextSize = Props.TextSize or Theme.TextSize["2.25"],
							Stroke = {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Color = Color3.new(0, 0, 0),
								LineJoinMode = Enum.LineJoinMode.Round,
							},
						},
						CloseButton(Scope, CombineProps(Props.CloseButton or {}, {
							Position = UDim2.fromScale(1, 0.5),
							AnchorPoint = Vector2.new(1, 0.5),
						})),
					},
				},
			},
		}))
	end

	-- LemonadeTag is private to this module — only the Lemonade theme renders
	-- the Lemonade branding footer. Other themes omit it entirely.
	local function LemonadeTag(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)

		return Scope:Frame(CombineProps(Props, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			List = {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			},
			[Children] = {
				Scope:Image {
					Size = UDim2.fromOffset(24, 24),
					Image = "rbxassetid://99067925707434",
					BackgroundTransparency = 1,
					ImageTransparency = 0.5,
				},
			},
		}))
	end

	local function Widget(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local children = Props[Children] or {}
		Props[Children] = nil

		return Pane(Scope, CombineProps(Props, {
			Name = "Widget",
			AutomaticSize = Enum.AutomaticSize.None,
			Size = Scope:UDim2Offset(500, 500),
			Scale = {
				Scale = Props.DynamicScale or 1,
			},
			[Children] = {
				Scope:New "UIListLayout" {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				HeadingBanner(Scope, CombineProps(Props.HeadingBanner or {}, {
					Text = "Widget",
					CloseButton = {
						OnActivate = Props.OnClose,
					},
				})),
				Scope:Frame {
					Size = UDim2.fromScale(1, 1),
					AutomaticSize = Enum.AutomaticSize.None,
					Flex = { Mode = Enum.UIFlexMode.Fill },
					List = {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					},
					Padding = { All = Scope:UDim(0, Theme.Padding.Base) },
					[Children] = {
						Scope:Frame {
							Size = UDim2.fromScale(1, 1),
							AutomaticSize = Enum.AutomaticSize.None,
							Flex = { Mode = Enum.UIFlexMode.Fill },
							[Children] = { children },
						},
						Scope:Computed(function(use, InnerScope)
							if not use(Props.HideTag) then
								return LemonadeTag(InnerScope, {})
							end
							return nil
						end),
					},
				},
			},
		}))
	end

	local function Divider(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		return Scope:Frame(CombineProps(Props, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			[Children] = {
				Scope:New "Frame" {
					Size = UDim2.new(0.75, 0, 0, 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 0.5,
					[Children] = {
						Scope:New "UIGradient" {
							Transparency = NumberSequence.new {
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.5, 0),
								NumberSequenceKeypoint.new(1, 1),
							},
						},
					},
				},
				Scope:Text {
					Text = Props.Text or "Title",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = Theme.TextSize["1.875"],
					Stroke = {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						Color = Color3.new(0, 0, 0),
						LineJoinMode = Enum.LineJoinMode.Round,
					},
				},
			},
		}))
	end

	local function TextInput(Scope, Props)
		Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()
		local TextValue = Scope:EnsureValue(Util.Fallback(Props.Text, ""))

		return ElevatedPane(Scope, {
			Name = Props.Name or "TextInput",
			Size = Props.Size or UDim2.new(1, 0, 0, 50),
			LayoutOrder = Props.LayoutOrder,
			Stroke = { Enabled = false },
			ColorSequence = Props.ColorSequence or Scope:Computed(function(use)
				return ColorSequence.new(use(Theme.Colors.Neutral.Main), use(Theme.Colors.Neutral.Dark))
			end),
			[Children] = {
				Scope:New "TextBox" {
					Name = "Input",
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Text = TextValue,
					PlaceholderText = Props.PlaceholderText or "Enter text...",
					TextColor3 = Theme.Colors.BaseContent.Main,
					PlaceholderColor3 = Scope:Computed(function(use)
						return use(Theme.Colors.BaseContent.Main):Lerp(use(Theme.Colors.Base.Main), 0.5)
					end),
					TextSize = Props.TextSize or Theme.TextSize["1"],
					FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium),
					ClearTextOnFocus = false,
					TextXAlignment = Props.TextXAlignment or Enum.TextXAlignment.Left,
					[Fusion.Out "Text"] = TextValue,
				},
			},
		})
	end

	return {
		Pane = Pane,
		ElevatedPane = ElevatedPane,
		ElevatedButton = ElevatedButton,
		CloseButton = CloseButton,
		HeadingBanner = HeadingBanner,
		Widget = Widget,
		Divider = Divider,
		TextInput = TextInput,

		-- Exposed for back-compat: Profile.luau still imports UILibrary.LemonadeTag
		-- directly and drops it into the Widget content. Once all templates stop
		-- hand-placing branding footers this can move back to being private.
		LemonadeTag = LemonadeTag,
	}
end
