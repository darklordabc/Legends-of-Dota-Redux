lich_traveling_frost = class({})

LinkLuaModifier("modifier_traveling_frost","abilities/dusk/lich_traveling_frost",LUA_MODIFIER_MOTION_NONE)

function lich_traveling_frost:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local cpos = caster:GetAbsOrigin()
		local tpos = self:GetCursorPosition()

		local range = self:GetSpecialValueFor("range")
		local speed = self:GetSpecialValueFor("speed")

		local dir = (tpos - cpos):Normalized()

		self:IceProjectile(caster,range,dir,speed)
	end
end

function lich_traveling_frost:OnProjectileHit_ExtraData(t,l,ed)
	if IsServer() then
		local stun = self:GetSpecialValueFor("stun")
		local damage = self:GetSpecialValueFor("damage")
		local speed = self:GetSpecialValueFor("speed")
		local max_hits = 1

		if self:GetCaster():HasScepter() then
			max_hits = self:GetSpecialValueFor("scepter_units")
		end

		if t then
			if ( t:HasModifier("modifier_traveling_frost") ) then return false end
			t:EmitSound("Hero_Tusk.IceShards.Target") --[[Returns:void
			 
			]]
			InflictDamage(t,self:GetCaster(),self,damage,DAMAGE_TYPE_MAGICAL)
			t:AddNewModifier(self:GetCaster(), self, "modifier_traveling_frost", {Duration=stun}) --[[Returns:void
			No Description Set
			]]
			if ( self:GetCaster():HasScepter() and not ed.donotproc ) then
				local n = max_hits
				repeat 
					local proj_pos = l
					local rpos = proj_pos+RandomVector(15)

					local dir = (rpos - proj_pos):Normalized()
					self:IceProjectile(self:GetCaster(),self:GetSpecialValueFor("range"),dir,speed,{soundsource=t,loc=proj_pos,donotproc=true})
					n = n-1
				until n == 0
			end
			return true
		end
	end
end

function lich_traveling_frost:IceProjectile(source,range,dir,speed,extradata)
	if IsServer() then
		local sourcepos = source:GetAbsOrigin()
		local soundsource = source
		local radius = 80
		local scepter_radius = self:GetSpecialValueFor("scepter_radius")
		if self:GetCaster():HasScepter() then
			radius = scepter_radius
		end
		if extradata then
			if extradata.loc then
				sourcepos = extradata.loc
			end
			if extradata.soundsource then
				soundsource = extradata.soundsource
			end
		end

		soundsource:EmitSound("Hero_Tusk.IceShards.Cast")

		local info = 
		{
			Ability = self,
			EffectName = "particles/units/heroes/hero_tusk/tusk_ice_shards_projectile.vpcf",
	    	vSpawnOrigin = sourcepos,
	    	fDistance = range,
	    	fStartRadius = radius,
	    	fEndRadius = radius,
	    	Source = source,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = true,
			vVelocity = dir * speed,
			bProvidesVision = true,
			iVisionRadius = 250,
			iVisionTeamNumber = source:GetTeamNumber(),
			ExtraData = extradata
		}
		ProjectileManager:CreateLinearProjectile(info) --[[Returns:int
		Creates a linear projectile and returns the projectile ID
		]]
	end
end

modifier_traveling_frost = class({})

function modifier_traveling_frost:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}
	return state
end

function modifier_traveling_frost:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
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