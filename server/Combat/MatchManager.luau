--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatEntity = require(script.Parent.CombatEntity)
local EffectManager = require(script.Parent.Effects.EffectManager)
local Network = require(ReplicatedStorage.Shared.Network)

local turnStartedRemote = Network.GetRemoteEvent(Network.Events.TurnStarted)

local MAX_TEAM_CRYSTALS = 10
local TEAM_A_ID = 1
local TEAM_B_ID = 2

local function incrementCapAndFill(cap: number): (number, number)
	local newCap = math.min(cap + 1, MAX_TEAM_CRYSTALS)
	return newCap, newCap
end

local function appendTeamEntities(timeline: { CombatEntity }, team: { CombatEntity })
	for _, entity in team do
		table.insert(timeline, entity)
	end
end

local function sortTimelineBySpeed(timeline: { CombatEntity })
	table.sort(timeline, function(left: CombatEntity, right: CombatEntity): boolean
		return left.ActiveStats.Speed > right.ActiveStats.Speed
	end)
end

local function buildTimeline(
	teamA: { CombatEntity },
	teamB: { CombatEntity }
): { CombatEntity }
	local timeline: { CombatEntity } = {}
	appendTeamEntities(timeline, teamA)
	appendTeamEntities(timeline, teamB)
	sortTimelineBySpeed(timeline)
	return timeline
end

local function advanceTeamCrystals(
	teamACrystals: number,
	teamBCrystals: number,
	teamACap: number,
	teamBCap: number,
	teamId: number
): (number, number, number, number)
	if teamId == TEAM_A_ID then
		local newCap, newCrystals = incrementCapAndFill(teamACap)
		return newCrystals, teamBCrystals, newCap, teamBCap
	end

	if teamId == TEAM_B_ID then
		local newCap, newCrystals = incrementCapAndFill(teamBCap)
		return teamACrystals, newCrystals, teamACap, newCap
	end

	warn(`[MatchManager] Unknown TeamId: {teamId}`)
	return teamACrystals, teamBCrystals, teamACap, teamBCap
end

local function rotateTimeline(timeline: { CombatEntity })
	local activeEntity = table.remove(timeline, 1)
	if activeEntity then
		table.insert(timeline, activeEntity)
	end
end

local MatchManager = {}
MatchManager.__index = MatchManager

export type MatchManager = {
	TeamACrystals: number,
	TeamBCrystals: number,
	TurnNumber: number,
	Timeline: { CombatEntity },
	InitializeTimeline: (self: MatchManager) -> (),
	StartNextTurn: (self: MatchManager) -> CombatEntity?,
	EndTurn: (self: MatchManager, entity: CombatEntity) -> (),
} & typeof(MatchManager)

function MatchManager.new(
	teamA: { CombatEntity },
	teamB: { CombatEntity }
): MatchManager
	local self = setmetatable({
		_teamA = teamA,
		_teamB = teamB,
		_teamACrystalCap = 0,
		_teamBCrystalCap = 0,
		TeamACrystals = 0,
		TeamBCrystals = 0,
		TurnNumber = 0,
		Timeline = {},
	}, MatchManager)

	return self :: MatchManager
end

function MatchManager.InitializeTimeline(self: MatchManager)
	self.Timeline = buildTimeline(self._teamA, self._teamB)
end

function MatchManager.StartNextTurn(self: MatchManager): CombatEntity?
	local activeEntity = self.Timeline[1]
	if not activeEntity then
		warn("[MatchManager] Cannot start turn: Timeline is empty.")
		return nil
	end

	self.TurnNumber += 1
	self.TeamACrystals, self.TeamBCrystals, self._teamACrystalCap, self._teamBCrystalCap = advanceTeamCrystals(
		self.TeamACrystals,
		self.TeamBCrystals,
		self._teamACrystalCap,
		self._teamBCrystalCap,
		activeEntity.TeamId
	)

	print(
		`[Match] Turn {self.TurnNumber} started | Entity={activeEntity.Id} | Team={activeEntity.TeamId} | Speed={activeEntity.ActiveStats.Speed} | TeamACrystals={self.TeamACrystals} | TeamBCrystals={self.TeamBCrystals}`
	)

	EffectManager.ProcessTurn(activeEntity, "TurnStart")

	rotateTimeline(self.Timeline)

	turnStartedRemote:FireAllClients({
		ActiveEntityId = activeEntity.Id,
		TeamId = activeEntity.TeamId,
		TurnNumber = self.TurnNumber,
		TeamACrystals = self.TeamACrystals,
		TeamBCrystals = self.TeamBCrystals,
	})

	return activeEntity
end

function MatchManager.EndTurn(self: MatchManager, entity: CombatEntity)
	EffectManager.ProcessTurn(entity, "TurnEnd")
end

return MatchManager
