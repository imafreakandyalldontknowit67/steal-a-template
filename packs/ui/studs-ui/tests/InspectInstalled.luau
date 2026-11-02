-- Read-only snapshot for the parent's Studio MCP execution AFTER installation.
-- No installation, input simulation, property writes, waits, or external calls.
-- Set this local option false only when deliberately inspecting an open panel.
local EXPECT_INITIAL_STATE = true

local PANEL_NAMES = {
	"DailyRewards", "Shop", "Rebirth", "Index", "SeasonPass", "Upgrades",
	"StockShop", "Settings", "StarterPack",
}
local report = {
	schemaVersion = 1,
	readOnly = true,
	expectInitialState = EXPECT_INITIAL_STATE,
	interactionTestsExecuted = false,
	summary = { PASS = 0, WARN = 0, FAIL = 0 },
	findings = {},
	containers = {},
}

local function add(level, code, path, message)
	report.summary[level] = report.summary[level] + 1
	table.insert(report.findings, { level = level, code = code, path = path, message = message })
end

local function finite(number)
	return number == number and number > -math.huge and number < math.huge
end

local function vector(value)
	return { x = value.X, y = value.Y }
end

local function effectivelyVisible(object, screen)
	local current = object
	while current and current ~= screen do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		current = current.Parent
	end
	return screen.Enabled
end

local function required(parent, name, className)
	local matches = {}
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == name then
			table.insert(matches, child)
		end
	end
	local path = parent:GetFullName() .. "." .. name
	if #matches ~= 1 then
		add("FAIL", "hierarchy.count", path, "Expected exactly one direct child; observed " .. #matches .. ".")
		return nil
	end
	if not matches[1]:IsA(className) then
		add("FAIL", "hierarchy.class", path, "Expected " .. className .. "; observed " .. matches[1].ClassName .. ".")
		return nil
	end
	add("PASS", "hierarchy.present", path, "Required direct child exists with expected class.")
	return matches[1]
end

local function rect(object)
	local position, size = object.AbsolutePosition, object.AbsoluteSize
	return { left = position.X, top = position.Y, right = position.X + size.X, bottom = position.Y + size.Y }
end

local function intersects(a, b)
	return a.right > b.left and a.left < b.right and a.bottom > b.top and a.top < b.bottom
end

local function contained(a, b)
	local tolerance = 2 -- Rounding, borders, and scale transforms can differ slightly.
	return a.left >= b.left - tolerance and a.top >= b.top - tolerance
		and a.right <= b.right + tolerance and a.bottom <= b.bottom + tolerance
end

local function intersection(a, b)
	return {
		left = math.max(a.left, b.left), top = math.max(a.top, b.top),
		right = math.min(a.right, b.right), bottom = math.min(a.bottom, b.bottom),
	}
end

local function inspectLayout(screen, canvas, live, result)
	result.layout = {
		available = false, checked = 0, hiddenSkipped = 0, rotatedSkipped = 0,
		scrollDescendantsSkipped = 0, clipped = 0, zeroSized = 0, offCanvas = 0,
	}
	result.scrolling = {}
	local layout = result.layout
	local sizeOK, screenSize = pcall(function() return screen.AbsoluteSize end)
	local positionOK, screenPosition = pcall(function() return screen.AbsolutePosition end)
	local available = live and sizeOK and positionOK and screenSize.X > 0 and screenSize.Y > 0
		and finite(screenSize.X) and finite(screenSize.Y)
		and canvas and canvas.AbsoluteSize.X > 0 and canvas.AbsoluteSize.Y > 0
	layout.available = available == true
	if not layout.available then
		add("WARN", "layout.unavailable", screen:GetFullName(),
			"Pixel checks skipped: StarterGui is a template, or the live viewport/DesignCanvas has no settled positive layout. Inspect client PlayerGui after rendering.")
	end
	local bounds = nil
	if layout.available then
		layout.viewport = vector(screenSize)
		bounds = intersection(rect(canvas), {
			left = screenPosition.X, top = screenPosition.Y,
			right = screenPosition.X + screenSize.X, bottom = screenPosition.Y + screenSize.Y,
		})
		layout.bounds = bounds
		if bounds.right <= bounds.left or bounds.bottom <= bounds.top then
			add("WARN", "layout.canvas_outside", canvas:GetFullName(), "DesignCanvas does not intersect the live viewport; inspect after transitions settle.")
		end
	end

	for _, object in ipairs(screen:GetDescendants()) do
		if object:IsA("ScrollingFrame") then
			local scrolling = {
				path = object:GetFullName(), visible = effectivelyVisible(object, screen),
				scrollingEnabled = object.ScrollingEnabled, clipsDescendants = object.ClipsDescendants,
				direction = object.ScrollingDirection.Name, automaticCanvasSize = object.AutomaticCanvasSize.Name,
				layoutAvailable = false,
			}
			table.insert(result.scrolling, scrolling)
			if not object.ClipsDescendants then
				add("WARN", "scroll.clipping", scrolling.path, "ScrollingFrame does not clip descendants; confirm content does not spill out.")
			end
			local canvasSize = object.CanvasSize
			for _, number in ipairs({ canvasSize.X.Scale, canvasSize.X.Offset, canvasSize.Y.Scale, canvasSize.Y.Offset }) do
				if not finite(number) then
					add("FAIL", "scroll.nonfinite", scrolling.path, "CanvasSize contains a non-finite component.")
					break
				end
			end
			-- Hidden modal geometry may be stale/zero; defer its pixel checks.
			if layout.available and scrolling.visible then
				local window, extent, position = object.AbsoluteWindowSize, object.AbsoluteCanvasSize, object.CanvasPosition
				scrolling.window = vector(window)
				scrolling.canvas = vector(extent)
				scrolling.position = vector(position)
				scrolling.layoutAvailable = window.X > 0 and window.Y > 0
				if not finite(extent.X) or not finite(extent.Y) or not finite(position.X) or not finite(position.Y) then
					add("FAIL", "scroll.nonfinite", scrolling.path, "Live canvas extent/position is not finite.")
				elseif scrolling.layoutAvailable then
					local overflowX, overflowY = extent.X > window.X + 2, extent.Y > window.Y + 2
					local direction = object.ScrollingDirection
					local allowsX = direction == Enum.ScrollingDirection.X or direction == Enum.ScrollingDirection.XY
					local allowsY = direction == Enum.ScrollingDirection.Y or direction == Enum.ScrollingDirection.XY
					if (overflowX or overflowY) and not object.ScrollingEnabled then
						add("WARN", "scroll.disabled_overflow", scrolling.path, "Canvas overflows while scrolling is disabled; may be an intentional temporary state.")
					end
					if (overflowX and not allowsX) or (overflowY and not allowsY) then
						add("WARN", "scroll.direction", scrolling.path, "Canvas overflows an axis not enabled for scrolling.")
					end
					if position.X < -2 or position.Y < -2 or position.X > math.max(0, extent.X - window.X) + 2
						or position.Y > math.max(0, extent.Y - window.Y) + 2 then
						add("WARN", "scroll.position", scrolling.path, "CanvasPosition is outside nominal bounds; elastic scrolling/transitions may explain this snapshot.")
					end
					-- Direct visible children checked in unscrolled canvas coordinates.
					-- Nested scrolling contents are deliberately not flattened here.
					for _, child in ipairs(object:GetChildren()) do
						if child:IsA("GuiObject") and child.Visible and child.AbsoluteRotation == 0 then
							local relative = child.AbsolutePosition - object.AbsolutePosition + position
							local childSize = child.AbsoluteSize
							if relative.X + childSize.X > extent.X + 3 or relative.Y + childSize.Y > extent.Y + 3 then
								add("WARN", "scroll.content_extent", child:GetFullName(), "Direct child extends beyond its scroll canvas; check final-row reachability after layout settles.")
							end
						end
					end
					add("PASS", "scroll.geometry_observed", scrolling.path, "Finite positive viewport observed; scrolling interaction itself was not tested.")
				else
					add("WARN", "scroll.zero_window", scrolling.path, "Visible scroll viewport is zero-sized; may be awaiting layout.")
				end
			end
		end

		if layout.available and object:IsA("GuiObject") then
			if not effectivelyVisible(object, screen) then
				layout.hiddenSkipped = layout.hiddenSkipped + 1
			elseif object.AbsoluteRotation ~= 0 then
				layout.rotatedSkipped = layout.rotatedSkipped + 1
			else
				layout.checked = layout.checked + 1
				local objectSize = object.AbsoluteSize
				if objectSize.X <= 0 or objectSize.Y <= 0 then
					layout.zeroSized = layout.zeroSized + 1
					add("WARN", "layout.zero_size", object:GetFullName(), "Effectively visible GuiObject is zero-sized; an intentional anchor/decorator or pending layout may explain it.")
				else
					local objectRect = rect(object)
					local inScroll = false
					local clipped = false
					local ancestor = object.Parent
					while ancestor and ancestor ~= screen do
						if ancestor:IsA("ScrollingFrame") then
							inScroll = true
						elseif ancestor:IsA("GuiObject") and ancestor.ClipsDescendants and not intersects(objectRect, rect(ancestor)) then
							clipped = true
						end
						ancestor = ancestor.Parent
					end
					if inScroll then
						-- Off-window scroll rows are normal, not off-canvas failures.
						layout.scrollDescendantsSkipped = layout.scrollDescendantsSkipped + 1
					else
						if clipped then layout.clipped = layout.clipped + 1 end
						if not contained(objectRect, bounds) then
							layout.offCanvas = layout.offCanvas + 1
							add("WARN", "layout.off_canvas", object:GetFullName(), "Element extends outside DesignCanvas/viewport bounds; review after animations settle.")
						end
					end
					-- Do NOT enforce containment in a panel's rectangle. Index rarity
					-- tabs may deliberately sit outside Index while on the design canvas.
				end
			end
		end
	end
	if #result.scrolling == 0 then
		add("WARN", "scroll.none", screen:GetFullName(), "No ScrollingFrame found; manually check whether long content is reachable.")
	else
		add("PASS", "scroll.inventory", screen:GetFullName(), "Recorded " .. #result.scrolling .. " scroll containers; hidden-container geometry was not judged.")
	end
	if layout.clipped > 0 then
		add("WARN", "layout.clipped", screen:GetFullName(), "Some visible objects lie wholly outside a non-scrolling clipping ancestor; review intentional clipping.")
	end
end

local function inspect(container, label, live)
	local result = { scope = label, found = false, panels = {}, actions = {} }
	table.insert(report.containers, result)
	if not container then
		add("FAIL", "container.missing", label, "Expected container is unavailable.")
		return
	end
	local screen = required(container, "StudsUI", "ScreenGui")
	if not screen then return end
	result.found = true
	result.resetOnSpawn = screen.ResetOnSpawn
	result.enabled = screen.Enabled
	add(screen.ResetOnSpawn == false and "PASS" or "FAIL", "gui.reset", screen:GetFullName(), "ResetOnSpawn must be false.")
	add(screen.Enabled and "PASS" or "FAIL", "gui.enabled", screen:GetFullName(), "StudsUI should be enabled.")
	local controller = required(screen, "Controller", "LocalScript")
	if controller then
		local enabledOK, enabled = pcall(function() return controller.Enabled end)
		if not enabledOK then enabled = not controller.Disabled end
		result.controllerEnabled = enabled
		add(enabled and "PASS" or "FAIL", "controller.enabled", controller:GetFullName(), "Controller must be enabled; this does not prove its event handlers ran.")
	end
	local canvas = required(screen, "DesignCanvas", "GuiObject")
	local modals = nil
	if canvas then
		required(canvas, "HUD", "GuiObject")
		modals = required(canvas, "Modals", "GuiObject")
	end
	local panels = {}
	local coverage = {}
	result.visibleModalCount = 0
	result.effectiveVisibleModalCount = 0
	for _, name in ipairs(PANEL_NAMES) do
		coverage[name] = { launchers = {}, closeButtons = {}, externalLaunchers = 0, visibleExternalLaunchers = 0, internalCloses = 0 }
		local panel = modals and required(modals, name, "Frame")
		local row = { name = name, found = panel ~= nil }
		table.insert(result.panels, row)
		if panel then
			panels[name] = panel
			row.visible = panel.Visible
			row.effectivelyVisible = effectivelyVisible(panel, screen)
			if panel.Visible then result.visibleModalCount = result.visibleModalCount + 1 end
			if row.effectivelyVisible then result.effectiveVisibleModalCount = result.effectiveVisibleModalCount + 1 end
		end
	end
	if modals then
		local frames = 0
		for _, child in ipairs(modals:GetChildren()) do
			if child:IsA("Frame") then
				frames = frames + 1
				if not coverage[child.Name] then
					add("WARN", "panels.extra", child:GetFullName(), "Extra direct Frame may be decoration; verify it is not an undocumented panel.")
				end
			end
		end
		result.directModalFrameCount = frames
		if not live or EXPECT_INITIAL_STATE then
			add(result.visibleModalCount == 0 and "PASS" or "FAIL", "panels.initially_closed", modals:GetFullName(),
				"Initial/template snapshot expects all panels Visible=false; observed " .. result.visibleModalCount .. " visible flags.")
		elseif result.effectiveVisibleModalCount > 1 then
			add("WARN", "panels.multiple_visible", modals:GetFullName(), "Multiple effective visible panels; transient tween overlap may explain this. Recheck when settled.")
		else
			add("PASS", "panels.visible_count", modals:GetFullName(), "At most one effectively visible modal in this interaction snapshot.")
		end
	end

	local function owningPanel(button)
		local current = button.Parent
		while current and current ~= screen do
			if panels[current.Name] == current then return current.Name end
			current = current.Parent
		end
		return nil
	end
	result.actions.buttonCount = 0
	result.actions.coverage = coverage
	for _, button in ipairs(screen:GetDescendants()) do
		if button:IsA("GuiButton") then
			result.actions.buttonCount = result.actions.buttonCount + 1
			local action = button:GetAttribute("StudsAction")
			local target = button:GetAttribute("StudsTarget")
			local path = button:GetFullName()
			if type(action) ~= "string" or action == "" then
				add("FAIL", "action.missing", path, "Every button must expose a nonempty StudsAction string.")
			elseif action == "OpenPanel" or action == "ClosePanel" then
				if type(target) ~= "string" or not panels[target] then
					add("FAIL", "action.target", path, "OpenPanel/ClosePanel requires StudsTarget naming an existing required panel.")
				else
					local owner = owningPanel(button)
					if action == "OpenPanel" then
						table.insert(coverage[target].launchers, path)
						if owner == nil then
							coverage[target].externalLaunchers = coverage[target].externalLaunchers + 1
							if effectivelyVisible(button, screen) then
								coverage[target].visibleExternalLaunchers = coverage[target].visibleExternalLaunchers + 1
							end
						end
					else
						table.insert(coverage[target].closeButtons, path)
						if owner == target then coverage[target].internalCloses = coverage[target].internalCloses + 1 end
					end
				end
			end
		end
	end
	for _, name in ipairs(PANEL_NAMES) do
		local entry = coverage[name]
		add(#entry.launchers > 0 and "PASS" or "FAIL", "action.launch_coverage", label .. "." .. name, "OpenPanel button count: " .. #entry.launchers .. ".")
		add(#entry.closeButtons > 0 and "PASS" or "FAIL", "action.close_coverage", label .. "." .. name, "ClosePanel button count: " .. #entry.closeButtons .. ".")
		if #entry.launchers > 0 and entry.externalLaunchers == 0 then
			add("WARN", "action.launch_access", label .. "." .. name, "Launchers exist only inside panels; verify a route from the all-closed state.")
		elseif (not live or EXPECT_INITIAL_STATE) and entry.externalLaunchers > 0 and entry.visibleExternalLaunchers == 0 then
			add("WARN", "action.launch_hidden", label .. "." .. name, "External launcher exists but is hidden by a Visible/Enabled ancestor in this snapshot.")
		end
		if #entry.closeButtons > 0 and entry.internalCloses == 0 then
			add("WARN", "action.close_external", label .. "." .. name, "Close control is external to its target panel; manually verify availability while open.")
		end
	end
	inspectLayout(screen, canvas, live, result)
end

inspect(game:GetService("StarterGui"), "StarterGui", false)
local player = game:GetService("Players").LocalPlayer
if player then
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		inspect(playerGui, "LocalPlayer.PlayerGui", true)
	else
		add("WARN", "playergui.unavailable", "LocalPlayer", "PlayerGui is not available yet; rerun after the local client has started.")
	end
else
	add("WARN", "client.unavailable", "Players.LocalPlayer", "No local client in this execution context. StarterGui inspection is not a PlayerGui/runtime check.")
end
add("WARN", "scope.snapshot", "StudsUI", "Read-only snapshot only: no source parsing, source access, input activation, sounds, networking, purchase/reward calls, or behavior tests performed.")
report.ok = report.summary.FAIL == 0
return report
