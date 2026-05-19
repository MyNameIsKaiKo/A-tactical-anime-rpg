--!strict

export type Stats = {
	MaxHp: number,
	CurrentHp: number,
	Def: number,
	DefSpe: number,
	Atck: number,
	AtckSpe: number,
	Speed: number,
}

export type SpellKind = "Auto" | "Spell" | "Passive" | "Ultimate"

export type Spell = {
	Id: string,
	Cost: number,
	Type: SpellKind,
}

export type EntityData = {
	Id: string,
	TeamId: number,
	Tags: {string},
	BaseStats: Stats,
	ActiveStats: Stats,
	Spells: {Spell},
}

export type CombatEntity = {
	Id: string,
	TeamId: number,
	Tags: {string},
	BaseStats: Stats,
	ActiveStats: Stats,
	Spells: {Spell},
}

return {}
