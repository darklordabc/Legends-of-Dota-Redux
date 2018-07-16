lightning_spark = class({})

LinkLuaModifier("modifier_spark","abilities/dusk/lightning_spark",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spark_slow","abilities/dusk/lightning_spark",LUA_MODIFIER_MOTION_NONE)

function lightning_spark:GetIntrinsicModifierName()
	return "modifier_spark"
end

modifier_spark = class({})

function modifier_spark:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function modifier_spark:OnAbilityExecuted(params)
	if IsServer() then
		local p = self:GetParent()
		if self:GetParent():PassivesDisabled() then return end
		if p == params.unit then
			local ability = params.ability
			local cost = params.cost
			local manacost = ability:GetManaCost(ability:GetLevel()) --[[Returns:int
			No Description Set
			]]
			if manacost <= 0 then return end

			if ability:IsItem() then return end

			local radius = self:GetAbility():GetSpecialValueFor("radius")
			local damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
			local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")

			local en = FindEnemies(p,p:GetAbsOrigin(),radius)

			p:EmitSound("Hero_Zuus.StaticField")

			for k,v in pairs(en) do
				ParticleManager:CreateParticle("particles/units/heroes/hero_lightning/spark.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
				self:GetAbility():InflictDamage(v,p,damage,DAMAGE_TYPE_MAGICAL)
				v:AddNewModifier(p, self:GetAbility(), "modifier_spark_slow", {Duration=slow_duration}) --[[Returns:void
				No Description Set
				]]
			end
		end
	end
end

function modifier_spark:IsHidden()
	return true
end

modifier_spark_slow = class({})

function modifier_spark_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_spark_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
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