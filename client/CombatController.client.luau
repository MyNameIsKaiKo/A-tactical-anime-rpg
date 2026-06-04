--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Fusion = require(Packages:WaitForChild("Fusion"))
local Network = require(Shared:WaitForChild("Network"))
local CombatApp = require(script.Parent.UI.CombatApp)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- FUSION 0.3 : On crée un Scope pour la gestion de la mémoire
local scope = Fusion.scoped(Fusion)

-- On utilise scope:Value au lieu de Fusion.Value
local isMyTurn = scope:Value(false)
local activeSpells = scope:Value({})

CombatApp({
	IsMyTurn = isMyTurn,
	ActiveSpells = activeSpells,
	
	OnActionSelected = function(spellId: string)
		print("[Client] Sort cliqué :", spellId)
		
		isMyTurn:set(false) 
		
		Network.ActionRequested:FireServer({
			SpellId = spellId,
			TargetId = "FighterB1"
		})
	end
}).Parent = PlayerGui

Network.TurnStarted.OnClientEvent:Connect(function(payload)
	print("[Client] Début du tour pour l'entité :", payload.EntityId)
	
	if payload.TeamId == 1 then
		activeSpells:set({
			{ Id = "SlimeBlade", Cost = 0 },
			{ Id = "SeveringStrike", Cost = 1 },
			{ Id = "BloodFrenzy", Cost = 2 },
			{ Id = "IAmAtomic", Cost = 5 }
		})
		
		isMyTurn:set(true)
	end
end)