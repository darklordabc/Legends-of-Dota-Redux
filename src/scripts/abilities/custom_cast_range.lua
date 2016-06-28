function SetCastRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abLvl = ability:GetLevel()
	if abLvl <= 0 then return end
	-- Remove old cast range
	caster:RemoveModifierByName("modifier_item_aether_lens")
	-- Replace cast range
	caster:AddNewModifier(caster,ability,"modifier_item_aether_lens",{})
	
end