ptomely_mirror_blade = class({})

function ptomely_mirror_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local origin = caster:GetAbsOrigin()

	local blades = self:GetSpecialValueFor("blades")
	local speed = self:GetSpecialValueFor("projectile_speed")
	local range = self:GetSpecialValueFor("range")
	local radius = self:GetSpecialValueFor("radius")
	local vision_radius = self:GetSpecialValueFor("vision_radius")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local n = 0

	local unit = CreateModifierThinker(caster, self, "modifier_truesight",{Duration=0.20*blades+0.10}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)

	Timers:CreateTimer(0.20,function()
		local rv = RandomVector(RandomInt(-0.1,0.1))
		local info = 
		  {
		  Ability = self,
		  EffectName = "particles/units/heroes/hero_ptomely/mirror_blade.vpcf",
		  vSpawnOrigin = origin,
		  fDistance = range,
		  fStartRadius = radius,
		  fEndRadius = radius,
		  Source = caster,
		  bHasFrontalCone = false,
		  bReplaceExisting = false,
		  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		  iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
		  fExpireTime = GameRules:GetGameTime() + 10.0,
		  vVelocity = (direction+rv) * speed,
		  bProvidesVision = true,
		  iVisionRadius = vision_radius,
		  iVisionTeamNumber = caster:GetTeamNumber()
		  }
		unit:EmitSound("Ptomely.MirrorBlade")
		ProjectileManager:CreateLinearProjectile(info) --[[Returns:int
		Creates a linear projectile and returns the projectile ID
		]]
		n = n+1
		if n < blades then
			return 0.20
		end
	end)
end

function ptomely_mirror_blade:OnProjectileHit(t, l)
	if t then
		local damage = self:GetSpecialValueFor("damage") * self:GetCaster():GetIntellect()
		t:EmitSound("Ptomely.MirrorBladeHit")
		ParticleManager:CreateParticle("particles/units/heroes/hero_ptomely/mirror_blade_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, t)
		InflictDamage(t,self:GetCaster(),self,damage,DAMAGE_TYPE_PHYSICAL)
	end
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