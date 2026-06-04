--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ActionBar = require(script.Parent.ActionBar)

local New = Fusion.New
local Children = Fusion.Children

type Props = {
	IsMyTurn: Fusion.StateObject<boolean>,
	ActiveSpells: Fusion.StateObject<{any}>,
	OnActionSelected: (spellId: string) -> ()
}

local function CombatApp(props: Props)
	return New "ScreenGui" {
		Name = "CombatUI",
		ResetOnSpawn = false,
		-- L'interface ne s'affiche que si c'est ton tour !
		Enabled = props.IsMyTurn,

		[Children] = {
			New "Frame" {
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