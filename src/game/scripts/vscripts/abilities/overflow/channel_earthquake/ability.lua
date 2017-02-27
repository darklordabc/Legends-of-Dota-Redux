if channel_earthquake == nil then
	channel_earthquake = class({})
end

LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )
 function channel_earthquake:OnSpellStart()
	 self.point = self:GetCursorPosition() 
	 local randPos = RandomVector(RandomInt(0, self:GetSpecialValueFor("radius"))) + self.point
	 self:Explosion(randPos)
	 self.start_time = GameRules:GetGameTime()
	 self.cc_interval = self:GetSpecialValueFor("think_interval")
	 self.cc_timer = 0
 end

 function channel_earthquake:GetAOERadius()
	 return self:GetSpecialValueFor("radius")
 end

 function channel_earthquake:GetBehavior() 
	 local behav = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_AOE
	 return behav
 end

 function channel_earthquake:OnChannelThink(flInterval)
	self.cc_timer = self.cc_timer + flInterval
	 if self.cc_timer >= self.cc_interval then
		self.cc_timer = self.cc_timer - self.cc_interval
		 self:CustomChannelThink()
	 end
 end

 function channel_earthquake:CustomChannelThink()
	 local randPos = RandomVector(RandomInt(9, self:GetSpecialValueFor("radius"))) + self.point
	 self:Explosion(randPos)
 end

 function channel_earthquake:OnChannelFinish( bInterrupted )
	 self.point = nil
 end
 
 function channel_earthquake:Explosion(vPos)
	 local hCaster = self:GetCaster()
	 local particleName = "particles/units/heroes/hero_earth_spirit/espirit_spawn.vpcf"
	 local stun_dur = self:GetSpecialValueFor("stun_duration")
	local aoe = self:GetSpecialValueFor("spot_radius")
	 --silly field of view
	 AddFOWViewer(hCaster:GetTeamNumber(), vPos, aoe, stun_dur, false)
	 local expl = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, hCaster )
	 ParticleManager:SetParticleControl( expl, 0, vPos )
	 ParticleManager:SetParticleControl( expl, 1, vPos )
	EmitSoundOnLocationWithCaster(self.point, "Hero_EarthShaker.Gravelmaw.Cast", hCaster )
		local damage = {
			attacker = self:GetCaster(),
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
				
					enemy:AddNewModifier( self:GetCaster(), self, "generic_lua_stun", { duration = stun_dur , stacking = 1 } )
					damage.victim = enemy
					ApplyDamage( damage )
				end
			end
		end
 end