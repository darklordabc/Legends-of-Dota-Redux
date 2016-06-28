function SetCastRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:GetLevel() <= 0 then return end
	-- Remove old cast range
	caster:RemoveModifierByName("modifier_item_aether_lens")
	-- Replace cast range
	caster:AddNewModifier(caster,ability,"modifier_item_aether_lens",{})
	-- Incompatible with aether lens for now for obvious reasons, fix this if desired once proper cast range support exists
end
