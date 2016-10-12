local items = {
	["item_mjollnir"] = 1,
	["item_mjollnir_2"] = 2,
	["item_maelstrom"] = 1,
}

function OnIntervalThinkMachine(keys)
	local caster = keys.caster

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item then
			if items[item:GetName()] then
				item:SetLevel(0)
			end
		end
	end
end

function OnIntervalThinkRifle(keys)
	local caster = keys.caster

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)

		if item and item:GetPurchaser() == caster then
			if items[item:GetName()] then	
				item:SetLevel(items[item:GetName()])
			end
		end
		
	end

end