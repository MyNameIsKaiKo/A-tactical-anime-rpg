--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatTypes = require(ReplicatedStorage.Shared.Combat.CombatTypes)

local function copyStats(stats: CombatTypes.Stats): CombatTypes.Stats
	return table.clone(stats)
end

local function copySpell(spell: CombatTypes.Spell): CombatTypes.Spell
	return table.clone(spell)
end

local function copyTags(tags: { string }): { string }
	return table.clone(tags)
end

local function copySpells(spells: { CombatTypes.Spell }): { CombatTypes.Spell }
	local copiedSpells: { CombatTypes.Spell } = {}
	for index, spell in spells do
		copiedSpells[index] = copySpell(spell)
	end
	return copiedSpells
end

local CombatEntity = {}
CombatEntity.__index = CombatEntity

export type CombatEntity = {
	Id: string,
	TeamId: number,
	Tags: { string },
	BaseStats: CombatTypes.Stats,
	ActiveStats: CombatTypes.Stats,
	Spells: { CombatTypes.Spell },
} & typeof(CombatEntity)

function CombatEntity.new(data: CombatTypes.EntityData): CombatEntity
	local self = setmetatable({
		Id = data.Id,
		TeamId = data.TeamId,
		Tags = copyTags(data.Tags),
		BaseStats = copyStats(data.BaseStats),
		ActiveStats = copyStats(data.BaseStats),
		Spells = copySpells(data.Spells),
	}, CombatEntity)

	return self :: CombatEntity
end

return CombatEntity
