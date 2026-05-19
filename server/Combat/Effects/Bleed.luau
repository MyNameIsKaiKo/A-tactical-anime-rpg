--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseEffect = require(script.Parent.BaseEffect)
local CombatEntity = require(script.Parent.Parent.CombatEntity)
local DamageUtil = require(ReplicatedStorage.Shared.Combat.Utils.DamageUtil)

local Bleed = {}
Bleed.__index = Bleed
Bleed.Id = "Bleed"
Bleed.MaxStacks = 5

setmetatable(Bleed, { __index = BaseEffect })

export type Bleed = BaseEffect.BaseEffect & typeof(Bleed)

function Bleed.new(duration: number, stacks: number): Bleed
	local self = setmetatable(BaseEffect.new(Bleed.Id, duration, stacks, Bleed.MaxStacks), Bleed)
	return self :: Bleed
end

function Bleed.OnTurnStart(self: Bleed, target: CombatEntity)
	local damage = self.Stacks * 10
	DamageUtil.ApplyDamage(target, damage)
	print(
		`[Bleed] Target {target.Id} takes {damage} bleed damage! HP: {target.ActiveStats.CurrentHp}/{target.ActiveStats.MaxHp}`
	)
end

return Bleed
