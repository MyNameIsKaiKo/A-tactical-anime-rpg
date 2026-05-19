--!strict

local CombatTypes = require(script.Parent.Parent.CombatTypes)

type CombatEntity = CombatTypes.CombatEntity

local function calculateMitigatedDamage(attackerPower: number, defenderMitigation: number): number
	return attackerPower * (100 / (100 + defenderMitigation))
end

local DamageUtil = {}

function DamageUtil.CalculatePhysical(attackerAtk: number, defenderDef: number): number
	return calculateMitigatedDamage(attackerAtk, defenderDef)
end

function DamageUtil.CalculateSpecial(attackerAtkSpe: number, defenderDefSpe: number): number
	return calculateMitigatedDamage(attackerAtkSpe, defenderDefSpe)
end

function DamageUtil.ApplyDamage(target: CombatEntity, amount: number): boolean
	local activeStats = target.ActiveStats
	activeStats.CurrentHp = math.clamp(activeStats.CurrentHp - amount, 0, activeStats.MaxHp)
	return activeStats.CurrentHp == 0
end

function DamageUtil.ApplyHeal(target: CombatEntity, amount: number)
	local activeStats = target.ActiveStats
	activeStats.CurrentHp = math.clamp(activeStats.CurrentHp + amount, 0, activeStats.MaxHp)
end

return DamageUtil
