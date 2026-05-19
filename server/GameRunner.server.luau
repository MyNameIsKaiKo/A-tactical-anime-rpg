--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatTypes = require(ReplicatedStorage.Shared.Combat.CombatTypes)
local Network = require(ReplicatedStorage.Shared.Network)
local CombatEntity = require(script.Parent.Combat.CombatEntity)
local MatchManager = require(script.Parent.Combat.MatchManager)
local EffectManager = require(script.Parent.Combat.Effects.EffectManager)
local Bleed = require(script.Parent.Combat.Effects.Bleed)
local BloodFrenzy = require(script.Parent.Combat.Spells.BloodFrenzy)

local TEAM_A_ID = 1
local TEAM_B_ID = 2
local ENEMY_AI_TEAM_ID = 2
local PLAYER_TEAM_ID = 1

type ActionRequestedPayload = {
	SpellId: string,
	TargetId: string,
}

local DEFAULT_SPELLS: { CombatTypes.Spell } = {
	{ Id = "AutoAttack", Cost = 0, Type = "Auto" },
	{ Id = "SpellSlot2", Cost = 1, Type = "Spell" },
	{ Id = "BloodFrenzy", Cost = 2, Type = "Spell" },
	{ Id = "PassiveSlot", Cost = 0, Type = "Passive" },
	{ Id = "UltimateSlot", Cost = 5, Type = "Ultimate" },
}

local actionRequestedRemote = Network.GetRemoteEvent(Network.Events.ActionRequested)

local function makeStats(maxHp: number, speed: number): CombatTypes.Stats
	return {
		MaxHp = maxHp,
		CurrentHp = maxHp,
		Def = 20,
		DefSpe = 15,
		Atck = 30,
		AtckSpe = 25,
		Speed = speed,
	}
end

local function createEntity(
	id: string,
	teamId: number,
	tags: { string },
	stats: CombatTypes.Stats,
	spells: { CombatTypes.Spell }?
)
	return CombatEntity.new({
		Id = id,
		TeamId = teamId,
		Tags = tags,
		BaseStats = stats,
		ActiveStats = stats,
		Spells = spells or DEFAULT_SPELLS,
	})
end

local function findEntityById(entities: { CombatEntity.CombatEntity }, entityId: string): CombatEntity.CombatEntity?
	for _, entity in entities do
		if entity.Id == entityId then
			return entity
		end
	end

	return nil
end

local teamA: { CombatEntity.CombatEntity } = {
	createEntity("FighterA1", TEAM_A_ID, { "Human" }, makeStats(100, 60)),
	createEntity("FighterA2", TEAM_A_ID, { "Human" }, makeStats(100, 55)),
	createEntity("Shadow", TEAM_A_ID, { "Demon" }, makeStats(120, 120), DEFAULT_SPELLS),
}

local teamB: { CombatEntity.CombatEntity } = {
	createEntity("FighterB1", TEAM_B_ID, { "Human" }, makeStats(100, 50)),
	createEntity("FighterB2", TEAM_B_ID, { "Human" }, makeStats(100, 50)),
	createEntity("FighterB3", TEAM_B_ID, { "Human" }, makeStats(100, 50)),
}

local function executePlayerAction(caster: CombatEntity.CombatEntity, payload: ActionRequestedPayload)
	if payload.SpellId ~= "BloodFrenzy" then
		warn(`[GameRunner] Unsupported spell: {payload.SpellId}`)
		return
	end

	local target = findEntityById(teamB, payload.TargetId)
	if not target then
		warn(`[GameRunner] Target not found: {payload.TargetId}`)
		return
	end

	EffectManager.ApplyEffect(target, Bleed, 3, 3)
	BloodFrenzy.new():Execute(caster, { target })
end

print("[GameRunner] Bootstrapping event-driven 3v3 combat simulation...")

local Players = game:GetService("Players")
if #Players:GetPlayers() == 0 then
	Players.PlayerAdded:Wait()
end
task.wait(1) -- Extra buffer to ensure LocalScripts have fully connected their events

local match = MatchManager.new(teamA, teamB)
match:InitializeTimeline()

task.spawn(function()
	while true do
		local active = match:StartNextTurn()
		if not active then
			warn("[GameRunner] No active entity; stopping match loop.")
			break
		end

		print(`--- TURN [{match.TurnNumber}] | ACTIVE: [{active.Id}] ---`)

		if active.TeamId == ENEMY_AI_TEAM_ID then
			task.wait(1)
		elseif active.TeamId == PLAYER_TEAM_ID then
			local _player, payload = actionRequestedRemote.OnServerEvent:Wait()
			local actionPayload = payload :: ActionRequestedPayload

			print("[SERVER] Received Action: " .. actionPayload.SpellId .. " on " .. actionPayload.TargetId)
			executePlayerAction(active, actionPayload)
		else
			warn(`[GameRunner] Unknown team for active entity: {active.TeamId}`)
		end

		match:EndTurn(active)
	end

	print("[GameRunner] Match loop ended.")
end)
