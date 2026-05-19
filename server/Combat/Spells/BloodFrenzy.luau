--!strict

local BaseSpell = require(script.Parent.BaseSpell)
local CombatEntity = require(script.Parent.Parent.CombatEntity)
local EffectManager = require(script.Parent.Parent.Effects.EffectManager)

local BloodFrenzy = {}
BloodFrenzy.__index = BloodFrenzy

setmetatable(BloodFrenzy, { __index = BaseSpell })

export type BloodFrenzy = BaseSpell.BaseSpell & typeof(BloodFrenzy)

function BloodFrenzy.new(): BloodFrenzy
	local self = setmetatable(BaseSpell.new("BloodFrenzy", 2), BloodFrenzy)
	return self :: BloodFrenzy
end

local function hasHumanOrDemonTag(tags: { string }): boolean
	return table.find(tags, "Human") ~= nil or table.find(tags, "Demon") ~= nil
end

function BloodFrenzy.Execute(self: BloodFrenzy, caster: CombatEntity, targets: { CombatEntity })
	local target = targets[1]
	if not target then
		print("[Spell] BloodFrenzy failed. No target.")
		return
	end

	local bleedEffect = EffectManager.GetEffect(target, "Bleed")
	if not bleedEffect then
		print("[Spell] BloodFrenzy failed. No bleed stacks.")
		return
	end

	local stacks = bleedEffect.Stacks
	local heal = stacks * 20

	if hasHumanOrDemonTag(target.Tags) then
		heal *= 2
		print(`[Spell] BloodFrenzy triggered TAG BUFF (Human/Demon)! Caster {caster.Id} heals for {heal}!`)
	else
		print(`[Spell] BloodFrenzy normal heal. Caster {caster.Id} heals for {heal}!`)
	end

	EffectManager.RemoveEffect(target, "Bleed")
end

return BloodFrenzy
