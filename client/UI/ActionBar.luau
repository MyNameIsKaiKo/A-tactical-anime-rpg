--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

type Props = {
	Spells: any,
	OnSpellClicked: (spellId: string) -> ()
}

local function ActionBar(props: Props)
	-- Scope local
	local scope = Fusion.scoped(Fusion)

	return scope:New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		
		[Children] = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 15)
			},
			
			-- Nouvelle syntaxe ForValues 0.3 avec use et innerScope
			scope:ForValues(props.Spells, function(use, innerScope, spell)
				return innerScope:New "TextButton" {
					Size = UDim2.new(0, 150, 0, 70),
					Text = spell.Id .. "\nCost: " .. tostring(spell.Cost or 0),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBold,
					TextSize = 16,
					
					[OnEvent "Activated"] = function()
						props.OnSpellClicked(spell.Id)
					end
				}
			end)
		}
	}
end

return ActionBar