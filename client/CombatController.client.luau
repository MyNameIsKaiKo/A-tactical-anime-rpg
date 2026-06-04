--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Network = require(ReplicatedStorage.Shared.Network)
local CombatApp = require(script.Parent.UI.CombatApp)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. On crée nos "États" Fusion (State)
local isMyTurn = Fusion.Value(false)
local activeSpells = Fusion.Value({})

-- 2. On instancie l'interface et on la place dans le PlayerGui
CombatApp({
	IsMyTurn = isMyTurn,
	ActiveSpells = activeSpells,
	
	OnActionSelected = function(spellId: string)
		print("[Client] Sort cliqué :", spellId)
		
		-- On cache la barre d'action instantanément
		isMyTurn:set(false) 
		
		-- On prévient le serveur ! 
		-- (Pour l'instant, on hardcode la cible, on fera le sélecteur plus tard)
		Network.ActionRequested:FireServer({
			SpellId = spellId,
			TargetId = "FighterB1" -- Remplace par l'ID exact de ta cible de test si besoin
		})
	end
}).Parent = PlayerGui

-- 3. On écoute le serveur
Network.TurnStarted.OnClientEvent:Connect(function(payload)
	print("[Client] Début du tour pour l'entité :", payload.EntityId)
	
	-- On simule que l'équipe 1 est la tienne. Si c'est à toi de jouer :
	if payload.TeamId == 1 then
		-- On charge les sorts de Shadow (basé sur ton Game Design !)
		activeSpells:set({
			{ Id = "SlimeBlade", Cost = 0 },
			{ Id = "SeveringStrike", Cost = 1 },
			{ Id = "BloodFrenzy", Cost = 2 },
			{ Id = "IAmAtomic", Cost = 5 }
		})
		
		-- On affiche l'interface
		isMyTurn:set(true)
	end
end)