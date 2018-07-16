lightning_overload = class({})

LinkLuaModifier("modifier_overload_slow","abilities/dusk/lightning_overload",LUA_MODIFIER_MOTION_NONE)

function lightning_overload:OnSpellStart()
	local c = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local dtype = self:GetAbilityDamageType()

	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_POINT_FOLLOW, c) --[[Returns:int
	Creates a new particle effect
	]]

	c:EmitSound("Hero_StormSpirit.Overload") --[[Returns:void
	 
	]]

	local en = FindEnemies(c,c:GetAbsOrigin(),radius)

	for k,v in pairs(en) do
		InflictDamage(v,c,self,damage,dtype)
		v:AddNewModifier(c, self, "modifier_overload_slow", {Duration=duration}) --[[Returns:void
		No Description Set
		]]
	end
end

modifier_overload_slow = class({})

function modifier_overload_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_overload_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow")
end

function modifier_overload_slow:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_slow")
end

function FindEnemies(caster,point,radius,targets,flags)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            targets,
                            flags,
                            FIND_CLOSEST,
                            false)
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end