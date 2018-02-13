lightning_lightning_dagger = class({})

LinkLuaModifier("modifier_lightning_dagger_slow","abilities/dusk/lightning_lightning_dagger",LUA_MODIFIER_MOTION_NONE)

function lightning_lightning_dagger:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()
	local s = 2000
	local bounces = self:GetSpecialValueFor("bounces")

	c:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

	self:FireDagger(t,{		
		bounces_left = bounces,
		-- [tostring(t:GetEntityIndex())] = 1
	})

end

function lightning_lightning_dagger:FireDagger(t,extradata,spawn_origin)
	local c = self:GetCaster()
	local spawn_origin = spawn_origin or c
	local info = 
	  {
	  Target = t,
	  Source = spawn_origin,
	  Ability = self,  
	  EffectName = "particles/units/heroes/hero_lightning/lightning_dagger_arcana.vpcf",
	  vSpawnOrigin = spawn_origin,
	  fDistance = 10000,
	  fStartRadius = 64,
	  fEndRadius = 64,
	  bHasFrontalCone = false,
	  bReplaceExisting = false,
	  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	  iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
	  fExpireTime = GameRules:GetGameTime() + 10.0,
	  bDeleteOnHit = true,
	  iMoveSpeed = 1600,
	  bProvidesVision = false,
	  iVisionRadius = 0,
	  iVisionTeamNumber = c:GetTeamNumber(),
	  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	  ExtraData = extradata
	  }
  
  	local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function lightning_lightning_dagger:OnProjectileHit_ExtraData(target,location,extradata)
	if not target then return end

	if target:TriggerSpellAbsorb(self) then return end
	target:TriggerSpellReflect(self)

	local damage = self:GetAbilityDamage()
	local jump_radius = 600

	local duration = self:GetSpecialValueFor("duration")

	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")

	InflictDamage(target,self:GetCaster(),self,damage,DAMAGE_TYPE_MAGICAL)

	target:AddNewModifier(self:GetCaster(), self, "modifier_lightning_dagger_slow", {Duration=duration}) --[[Returns:void
	No Description Set
	]]

	local en = FindEnemiesRandom(self:GetCaster(),target:GetAbsOrigin(),jump_radius)

	local chosen

	for k,v in pairs(en) do
		if v ~= target then
        	chosen = v
        	break
    	end
	end

	extradata.bounces_left = extradata.bounces_left - 1

	if chosen and extradata.bounces_left > 0 then
		Timers:CreateTimer(0.1,function() self:FireDagger(chosen,extradata,target) end)
	end
end

modifier_lightning_dagger_slow = class({})

function modifier_lightning_dagger_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_lightning_dagger_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
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