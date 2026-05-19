--!strict

local CombatEntity = require(script.Parent.Parent.CombatEntity)

local BaseEffect = {}
BaseEffect.__index = BaseEffect

export type BaseEffect = {
	Id: string,
	Duration: number,
	Stacks: number,
	MaxStacks: number,
	OnApply: (self: BaseEffect, target: CombatEntity) -> (),
	OnTurnStart: (self: BaseEffect, target: CombatEntity) -> (),
	OnTurnEnd: (self: BaseEffect, target: CombatEntity) -> (),
	OnRemove: (self: BaseEffect, target: CombatEntity) -> (),
} & typeof(BaseEffect)

function BaseEffect.new(id: string, duration: number, stacks: number, maxStacks: number): BaseEffect
	local self = setmetatable({
		Id = id,
		Duration = duration,
		Stacks = stacks,
		MaxStacks = maxStacks,
	}, BaseEffect)

	return self :: BaseEffect
end

function BaseEffect.OnApply(_self: BaseEffect, _target: CombatEntity) end

function BaseEffect.OnTurnStart(_self: BaseEffect, _target: CombatEntity) end

function BaseEffect.OnTurnEnd(_self: BaseEffect, _target: CombatEntity) end

function BaseEffect.OnRemove(_self: BaseEffect, _target: CombatEntity) end

return BaseEffect
