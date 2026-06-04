--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

type Props = {
	Spells: Fusion.StateObject<{any}>,
	OnSpellClicked: (spellId: string) -> ()
}

local function ActionBar(props: Props)
	return New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		
		[Children] = {
			New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 15)
			},
			
			-- Fusion.ForValues parcourt ton tableau de sorts pour générer les boutons
			Fusion.ForValues(props.Spells, function(spell)
				return New "TextButton" {
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