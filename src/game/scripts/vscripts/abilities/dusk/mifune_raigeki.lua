mifune_raigeki = class({})

LinkLuaModifier("modifier_raigeki","abilities/dusk/mifune_raigeki",LUA_MODIFIER_MOTION_NONE)

function mifune_raigeki:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local range = self:GetSpecialValueFor("range")

	local cpos = caster:GetAbsOrigin()

	local tpos = self:GetCursorPosition()

	if tpos == cpos then
		tpos = cpos + caster:GetForwardVector()
	end

	local direction = (tpos-cpos):Normalized()

	local endpos = cpos + direction * range

	local particle = "particles/units/heroes/hero_mifune/mifune_shockwave.vpcf"

	local proj = {
		Ability = self,
    	EffectName = particle,
    	vSpawnOrigin = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1),
    	fDistance = range,
    	fStartRadius = 100,
    	fEndRadius = 100,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction*range*4,
		bProvidesVision = false,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(proj)
	caster:EmitSound("Hero_Magnataur.ShockWave.Particle")

	local unit = CreateModifierThinker(caster, self, "modifier_kill", {Duration=delay*3}, endpos, caster:GetTeamNumber(), false)

	Timers:CreateTimer(delay*0.30,function()
		unit:EmitSound("Hero_Magnataur.Empower.Target")
	end)

	Timers:CreateTimer(delay*0.95,function()
		unit:EmitSound("Hero_Magnataur.ReversePolarity.Anim")
		unit:EmitSound("Hero_Magnataur.ShockWave.Target")
	end)

	Timers:CreateTimer(delay,function()
		proj.vVelocity = direction*-range*4
		proj.vSpawnOrigin = unit:GetAbsOrigin()

		ProjectileManager:CreateLinearProjectile(proj)
		unit:EmitSound("Hero_Magnataur.ShockWave.Particle")
	end)
end

function mifune_raigeki:OnProjectileHit(t,l)
	if t then
		local c = self:GetCaster()
		local duration = self:GetSpecialValueFor("slow_duration")
		local damage = self:GetSpecialValueFor("initial_damage")
		InflictDamage(t,c,self,damage,DAMAGE_TYPE_MAGICAL)
		t:AddNewModifier(c, self, "modifier_raigeki", {Duration=duration})
	end
end

modifier_raigeki = class({})

function modifier_raigeki:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return func
end

function modifier_raigeki:GetModifierMoveSpeedBonus_Percentage()
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