--[[
	ShuffleTimeline

	Pure timing maths for the shuffle, shared by server and clients.
	  - The server uses totalDuration() to know how long the machine is busy.
	  - Clients use build() to know which egg to show at every moment.

	build() is deterministic for a given seed, so every player sees the same swap order,
	and its LAST swap is always the server's result, so the machine visibly lands on it.
	It contains no randomness that affects the result — the result is passed in.
]]

local ShuffleTimeline = {}

export type Timeline = {
	slotIndex: number,
	stopTime: number, -- seconds after the shuffle starts when this slot stops
	swapTimes: { number }, -- when each egg appears (seconds after the shuffle starts)
	sequence: { string }, -- which egg appears at each swap; the last one is the final result
	totalTurns: number, -- whole turns the egg spins before it stops facing the front
}

-- Seconds after the shuffle starts when slot `slotIndex` stops.
function ShuffleTimeline.slotStopTime(config, slotIndex: number): number
	return config.Shuffle.Duration + (slotIndex - 1) * config.Shuffle.SlotStopStagger
end

-- Seconds from the lever pull until the last slot has finished its reveal animation.
function ShuffleTimeline.totalDuration(config, slotCount: number): number
	return config.Shuffle.StartDelay
		+ ShuffleTimeline.slotStopTime(config, math.max(slotCount, 1))
		+ math.max(config.Reveal.PopTime, config.Reveal.EffectsTime)
end

function ShuffleTimeline.build(config, eggIds: { string }, finalEgg: string, slotIndex: number, seed: number): Timeline
	local shuffle = config.Shuffle
	local stopTime = ShuffleTimeline.slotStopTime(config, slotIndex)
	local fastest = math.max(shuffle.FastestSwapInterval, 1 / 60)
	local slowest = math.max(shuffle.SlowestSwapInterval, fastest)

	-- Swap times: the gap between swaps grows from `fastest` to `slowest` as the stop approaches.
	local swapTimes = {}
	local t = 0
	while t < stopTime do
		table.insert(swapTimes, t)
		local progress = t / stopTime
		t += fastest + (slowest - fastest) * progress ^ shuffle.SlowdownCurve
	end
	-- Give the landing egg a readable moment on screen before the stop.
	while #swapTimes > 1 and stopTime - swapTimes[#swapTimes] < slowest * 0.6 do
		table.remove(swapTimes)
	end

	-- Egg order: random, never the same egg twice in a row, ending on the server's result.
	local rng = Random.new(seed + slotIndex * 7919)
	local count = #swapTimes
	local sequence = table.create(count)
	sequence[count] = finalEgg
	for i = count - 1, 1, -1 do
		local avoid = sequence[i + 1]
		local pick = eggIds[rng:NextInteger(1, #eggIds)]
		if #eggIds > 1 then
			while pick == avoid do
				pick = eggIds[rng:NextInteger(1, #eggIds)]
			end
		end
		sequence[i] = pick
	end

	-- Ease-out cubic spin starts at 3 * turns / stopTime turns per second; pick whole turns
	-- that match the configured starting speed so the egg ends exactly facing the front.
	local turns = math.max(1, math.floor(shuffle.RotationSpeed * stopTime / (3 * 360) + 0.5))

	return {
		slotIndex = slotIndex,
		stopTime = stopTime,
		swapTimes = swapTimes,
		sequence = sequence,
		totalTurns = turns,
	}
end

-- Spin angle (radians) at time t: fast at first, easing smoothly to a full stop at stopTime.
function ShuffleTimeline.spinAngle(timeline: Timeline, t: number): number
	local u = math.clamp(t / timeline.stopTime, 0, 1)
	return timeline.totalTurns * 2 * math.pi * (1 - (1 - u) ^ 3)
end

return ShuffleTimeline
