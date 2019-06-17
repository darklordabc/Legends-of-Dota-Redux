summon_zombie = class ({})
LinkLuaModifier( "summon_zombie_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function summon_zombie:GetIntrinsicModifierName()
	return "summon_zombie_modifier"
end

--------------------------------------------------------------------------------

function summon_zombie:OnSpellStart()	
	local info = {
			EffectName = "particles/econ/courier/courier_polycount_01/courier_trail_polycount_01.vpcf",
			Ability = self,
			iMoveSpeed = 800,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_Pugna.Decrepify", self:GetCaster() )
end

--------------------------------------------------------------------------------

function summon_zombie:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		EmitSoundOn( "Hero_Visage.SummonFamiliars.Cast", hTarget )
		
		self.level = self:GetCaster():GetLevel()
		
		local zombie = CreateUnitByName("custom_creature_zombie_large", vLocation, true, nil, nil, self:GetCaster():GetTeamNumber())
		
		zombie:CreatureLevelUp(self.level)
	end
end	