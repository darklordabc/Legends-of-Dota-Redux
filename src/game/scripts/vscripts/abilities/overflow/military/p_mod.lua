if military_mod == nil then
	military_mod = class({})
end

function military_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
 
	return funcs
end

function military_mod:IsHidden()
	return true
end

function military_mod:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

