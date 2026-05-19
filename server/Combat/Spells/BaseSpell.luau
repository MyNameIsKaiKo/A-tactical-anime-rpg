--!strict

local CombatEntity = require(script.Parent.Parent.CombatEntity)

local BaseSpell = {}
BaseSpell.__index = BaseSpell

export type BaseSpell = {
	Id: string,
	Cost: number,
	Execute: (self: BaseSpell, caster: CombatEntity, targets: { CombatEntity }) -> (),
} & typeof(BaseSpell)

function BaseSpell.new(id: string, cost: number): BaseSpell
	local self = setmetatable({
		Id = id,
		Cost = cost,
	}, BaseSpell)

	return self :: BaseSpell
end

function BaseSpell.Execute(_self: BaseSpell, _caster: CombatEntity, _targets: { CombatEntity }) end

return BaseSpell
