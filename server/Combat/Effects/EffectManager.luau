--!strict

local BaseEffect = require(script.Parent.BaseEffect)
local CombatEntity = require(script.Parent.Parent.CombatEntity)

export type EffectTrigger = "TurnStart" | "TurnEnd"

export type EffectClass = {
	Id: string,
	MaxStacks: number,
	new: (duration: number, stacks: number) -> BaseEffect,
}

local activeEffects: { [CombatEntity]: { [string]: BaseEffect } } = {}

local function getEntityEffects(target: CombatEntity): { [string]: BaseEffect }
	local effects = activeEffects[target]
	if not effects then
		effects = {}
		activeEffects[target] = effects
	end

	return effects
end

local function clampStacks(stacks: number, maxStacks: number): number
	return math.clamp(stacks, 1, maxStacks)
end

local EffectManager = {}

function EffectManager.ApplyEffect(
	target: CombatEntity,
	effectClass: EffectClass,
	stacks: number,
	duration: number
): BaseEffect
	local entityEffects = getEntityEffects(target)
	local existing = entityEffects[effectClass.Id]

	if existing then
		existing.Stacks = clampStacks(existing.Stacks + stacks, existing.MaxStacks)
		existing.Duration = math.max(existing.Duration, duration)
		return existing
	end

	local effect = effectClass.new(duration, clampStacks(stacks, effectClass.MaxStacks))
	entityEffects[effectClass.Id] = effect
	effect:OnApply(target)

	return effect
end

function EffectManager.RemoveEffect(target: CombatEntity, effectId: string): boolean
	local entityEffects = activeEffects[target]
	if not entityEffects then
		return false
	end

	local effect = entityEffects[effectId]
	if not effect then
		return false
	end

	effect:OnRemove(target)
	entityEffects[effectId] = nil

	if next(entityEffects) == nil then
		activeEffects[target] = nil
	end

	return true
end

function EffectManager.GetEffect(target: CombatEntity, effectId: string): BaseEffect?
	local entityEffects = activeEffects[target]
	if not entityEffects then
		return nil
	end

	return entityEffects[effectId]
end

function EffectManager.ProcessTurn(target: CombatEntity, trigger: EffectTrigger)
	local entityEffects = activeEffects[target]
	if not entityEffects then
		return
	end

	if trigger == "TurnStart" then
		for _, effect in entityEffects do
			effect:OnTurnStart(target)
		end
		return
	end

	local expiredEffectIds: { string } = {}

	for effectId, effect in entityEffects do
		effect:OnTurnEnd(target)
		effect.Duration -= 1

		if effect.Duration <= 0 then
			table.insert(expiredEffectIds, effectId)
		end
	end

	for _, effectId in expiredEffectIds do
		EffectManager.RemoveEffect(target, effectId)
	end
end

return EffectManager
