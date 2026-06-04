--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))
local ActionBar = require(script.Parent.ActionBar)

local Children = Fusion.Children

type Props = {
	IsMyTurn: any,
	ActiveSpells: any,
	OnActionSelected: (spellId: string) -> ()
}

local function CombatApp(props: Props)
	-- Scope local au composant
	local scope = Fusion.scoped(Fusion)

	-- On utilise scope:New au lieu de Fusion.New
	return scope:New "ScreenGui" {
		Name = "CombatUI",
		ResetOnSpawn = false,
		Enabled = props.IsMyTurn,

		[Children] = {
			scope:New "Frame" {
				Name = "BottomContainer",
				Size = UDim2.new(1, 0, 0, 120),
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(15, 15, 20),
				BackgroundTransparency = 0.3,

				[Children] = {
					ActionBar {
						Spells = props.ActiveSpells,
						OnSpellClicked = props.OnActionSelected
					}
				}
			}
		}
	}
end

return CombatApp