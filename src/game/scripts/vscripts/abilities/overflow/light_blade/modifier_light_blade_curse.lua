modifier_light_blade_curse = class ({})

--------------------------------------------------------------------------------

function modifier_light_blade_curse:IsDebuff()
	return true
end

function modifier_light_blade_curse:OnCreated( kv )
	
end
--------------------------------------------------------------------------------

function modifier_light_blade_curse:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_light_blade_curse:IsPurgable()
	return true
end

function modifier_light_blade_curse:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_light_blade_curse:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_light_blade_curse:GetModifierMagicalResistanceBonus()
	local nStack = self:GetStackCount() 
	local hAbility = self:GetAbility()
	local nMResist = hAbility:GetSpecialValueFor( "magic_armor" )
	return nStack*nMResist
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
