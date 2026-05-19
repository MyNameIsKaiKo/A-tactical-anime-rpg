--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Network)

type TurnStartedPayload = {
	ActiveEntityId: string,
	TeamId: number,
	TurnNumber: number,
	TeamACrystals: number,
	TeamBCrystals: number,
}

type ActionRequestedPayload = {
	SpellId: string,
	TargetId: string,
}

local LOCAL_PLAYER_TEAM_ID = 1

local turnStartedRemote = Network.GetRemoteEvent(Network.Events.TurnStarted)
local actionRequestedRemote = Network.GetRemoteEvent(Network.Events.ActionRequested)

turnStartedRemote.OnClientEvent:Connect(function(payload: TurnStartedPayload)
	print(
		"[CLIENT] Turn Started: "
			.. payload.ActiveEntityId
			.. " (Crystals: "
			.. payload.TeamACrystals
			.. " vs "
			.. payload.TeamBCrystals
			.. ")"
	)

	if payload.TeamId ~= LOCAL_PLAYER_TEAM_ID then
		return
	end

	print("[CLIENT] It's my turn! Thinking...")
	task.wait(1.5)

	local actionPayload: ActionRequestedPayload = {
		SpellId = "BloodFrenzy",
		TargetId = "FighterB1",
	}
	actionRequestedRemote:FireServer(actionPayload)
end)
