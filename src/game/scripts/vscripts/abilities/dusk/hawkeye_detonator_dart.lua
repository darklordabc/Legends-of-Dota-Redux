hawkeye_detonator_dart = class({})

LinkLuaModifier("modifier_detonator_dart","abilities/dusk/hawkeye_detonator_dart",LUA_MODIFIER_MOTION_NONE)

function hawkeye_detonator_dart:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	local c = self:GetCaster()
	local spawn_origin = c
	local info = 
	  {
	  Target = t,
	  Source = spawn_origin,
	  Ability = self,  
	  EffectName = "particles/units/heroes/hero_hawkeye/det_dart_tag.vpcf",
	  vSpawnOrigin = spawn_origin:GetAbsOrigin(),
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
	  iMoveSpeed = 3000,
	  bProvidesVision = false,
	  iVisionRadius = 0,
	  iVisionTeamNumber = c:GetTeamNumber(),
	  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	  }
  
  	local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function hawkeye_detonator_dart:OnProjectileHit(t, l)
	local c = self:GetCaster()
	local damage = self:GetSpecialValueFor("initial_damage")

	if t:TriggerSpellAbsorb(self) then return end
	t:TriggerSpellReflect(self)

	if not t then return end

	InflictDamage(t,c,self,damage,DAMAGE_TYPE_MAGICAL)

	t:AddNewModifier(c, self, "modifier_detonator_dart", {}) --[[Returns:void
	No Description Set
	]]
end

modifier_detonator_dart = class({})

function modifier_detonator_dart:OnCreated()
	if IsServer() then
		local tick_time = self:GetAbility():GetSpecialValueFor("tick_time")
		local stack = self:GetAbility():GetSpecialValueFor("ticks")

		self:SetStackCount(stack)
		self:StartIntervalThink(tick_time)

		self:GetParent():EmitSound("Hawkeye.DetBeep")
	end
end

function modifier_detonator_dart:OnIntervalThink()
	local stack = self:GetStackCount()
	local c = self:GetAbility():GetCaster()
	local damage = self:GetAbility():GetSpecialValueFor("damage")

	self:SetStackCount(stack-1)

	if stack > 1 then
		self:GetParent():EmitSound("Hawkeye.DetBeep")
	else
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local enemy_found = FindUnitsInRadius( c:GetTeamNumber(),
                              self:GetParent():GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_CLOSEST,
                                false)
	    for k,v in pairs(enemy_found) do
	      InflictDamage(v,c,self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
	    end

	    ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
	    Creates a new particle effect
	    ]]
	    self:GetParent():EmitSound("Hero_Gyrocopter.CallDown.Damage")

	    self:GetParent():AddNewModifier(c, nil, "modifier_stunned", {Duration=0.5}) --[[Returns:void
	    No Description Set
	    ]]
	    self:GetParent():RemoveModifierByName("modifier_detonator_dart")
	end
end

function modifier_detonator_dart:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT+MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE+MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_detonator_dart:IsPurgable()
	return false
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