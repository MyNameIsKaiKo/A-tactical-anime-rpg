--!strict
local RunService = game:GetService("RunService")

local Network = {}

-- Cette fonction crée l'événement sur le serveur, 
-- et force le client à ATTENDRE qu'il arrive par le réseau.
local function getRemote(name: string): RemoteEvent
	if RunService:IsServer() then
		local remote = script:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = script
		end
		return remote :: RemoteEvent
	else
		return script:WaitForChild(name) :: RemoteEvent
	end
end

-- On déclare nos événements
Network.TurnStarted = getRemote("TurnStarted")
Network.ActionRequested = getRemote("ActionRequested")

return Network