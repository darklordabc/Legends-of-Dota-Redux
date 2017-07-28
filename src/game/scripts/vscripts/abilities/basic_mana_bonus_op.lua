basic_mana_bonus_op=class({})

modifier_basic_mana_bonus_op = class({})
LinkLuaModifier("modifier_basic_mana_bonus_op","abilities/basic_mana_bonus_op.lua",LUA_MODIFIER_MOTION_NONE)

function basic_mana_bonus_op:GetIntrinsicModifierName()
 return "modifier_basic_mana_bonus_op"
end

function modifier_basic_mana_bonus_op:IsPermanent() return true end
function modifier_basic_mana_bonus_op:IsHidden() return true end

function modifier_basic_mana_bonus_op:DeclareFunctions() 
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_basic_mana_bonus_op:GetModifierManaBonus()
	if self:GetCaster():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor("mana_bonus")
end