function SetCastRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abLvl = ability:GetLevel()
	if abLvl <= 0 then return end
        -- FIXME: Remove this hack once the proper property is released.
	-- Remove old cast range
	--caster:RemoveModifierByName("modifier_item_aether_lens")
	-- Replace cast range
	caster:RemoveModifierByName("modifier_spell_aether_lens") 
	caster:AddNewModifier(caster,ability,"modifier_spell_aether_lens",{}) 
	
end

LinkLuaModifier("modifier_spell_aether_lens","abilities/aether_range_lod_global.lua",LUA_MODIFIER_MOTION_NONE)
modifier_spell_aether_lens = class({})

function modifier_spell_aether_lens:IsPermanent()
	return true
end
function modifier_spell_aether_lens:IsHidden()
  return true
end

function modifier_spell_aether_lens:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end

function modifier_spell_aether_lens:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
	end
end
