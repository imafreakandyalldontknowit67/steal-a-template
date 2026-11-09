local State = {}

State.CurrentTrack = nil
State.Connections = {}

function State.DisconnectAll()
	for _, connection in ipairs(State.Connections) do
		connection:Disconnect()
	end

	table.clear(State.Connections)
end

return State