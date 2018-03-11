if blink_support_passive_modifier == nil then
	blink_support_passive_modifier = class({})
end

function blink_support_passive_modifier:IsHidden()
	return true --we want item's passive abilities to be hidden most of the times
end

function blink_support_passive_modifier:DeclareFunctions() --we want to use these functions in this item
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
 
	return funcs
end

function blink_support_passive_modifier:OnTakeDamage( params ) --When ever the unit takes damage this is called
	if IsServer() then --this should be only run on server.
		local hAbility = self:GetAbility() --we get the ability where this modifier is from
		if params.attacker ~= self:GetParent() and params.unit == self:GetParent() and not self:GetParent():HasScepter() then
		hAbility:StartCooldown(hAbility:GetSpecialValueFor( "hurt_cooldown" )) --we start the cooldown
		end
	end
end

function blink_support_passive_modifier:GetModifierBonusStats_Intellect()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_int" )
end

function blink_support_passive_modifier:GetModifierAttackSpeedBonus_Constant()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_attack_speed" )
end

function blink_support_passive_modifier:GetModifierPreAttack_BonusDamage()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_damage" )
end