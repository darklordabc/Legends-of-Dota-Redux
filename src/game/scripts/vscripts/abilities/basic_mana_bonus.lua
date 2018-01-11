basic_mana_bonus=class({})

modifier_basic_mana_bonus = class({})
LinkLuaModifier("modifier_basic_mana_bonus","abilities/basic_mana_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_mana_bonus:GetIntrinsicModifierName()
 return "modifier_basic_mana_bonus"
end

function modifier_basic_mana_bonus:IsPermanent() return true end
function modifier_basic_mana_bonus:IsHidden() return true end

function modifier_basic_mana_bonus:DeclareFunctions() 
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_basic_mana_bonus:GetModifierManaBonus()
	if self:GetCaster():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor("mana_bonus")
end