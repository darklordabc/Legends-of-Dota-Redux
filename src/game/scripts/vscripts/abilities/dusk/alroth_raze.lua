alroth_raze = class({})

LinkLuaModifier("modifier_raze_thinker","abilities/dusk/alroth_raze",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raze_aura","abilities/dusk/alroth_raze",LUA_MODIFIER_MOTION_NONE)

function alroth_raze:GetCooldown(level)
	local base_cooldown = self.BaseClass.GetCooldown(self, level)
	return base_cooldown
end

function alroth_raze:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = self:GetSpecialValueFor("duration") --[[Returns:table
	No Description Set
	]]

	CreateModifierThinker( caster, self, "modifier_raze_thinker", {Duration=duration+0.45}, point, caster:GetTeamNumber(), false )
end

modifier_raze_thinker = class({})

if IsServer() then

	function modifier_raze_thinker:OnCreated()
		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_alroth/raze.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
		Creates a new particle effect
		]]
		local radius = self:GetAbility():GetSpecialValueFor("radius") --[[Returns:table
		No Description Set
		]]
		local duration = self:GetAbility():GetSpecialValueFor("duration") --[[Returns:table
		No Description Set
		]]
		ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		ParticleManager:SetParticleControl(p, 2, Vector(duration,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		self:AddParticle( p, false, false, 10, false, false )

		self:GetParent():EmitSound("Alroth.Raze")
	end

	function modifier_raze_thinker:IsAura()
		return true
	end

	function modifier_raze_thinker:GetAuraRadius()
		return self:GetAbility():GetSpecialValueFor("radius") --[[Returns:table
		No Description Set
		]]
	end

	function modifier_raze_thinker:GetAuraDuration()
		return 0.5
	end

	function modifier_raze_thinker:GetAuraSearchFlags()
		return 0
	end

	function modifier_raze_thinker:GetAuraSearchTeam()
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	function modifier_raze_thinker:GetAuraSearchType()
		return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	end

	function modifier_raze_thinker:GetModifierAura()
		return "modifier_raze_aura"
	end
end

modifier_raze_aura = class({})

if IsServer() then

	function modifier_raze_aura:OnCreated()
		self:StartIntervalThink(0.5)
	end

	function modifier_raze_aura:OnIntervalThink()
		local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") * 0.5 --[[Returns:table
		No Description Set
		]]

		local mhp = self:GetParent():GetMaxHealth()

		local damage_bonus = mhp*0.5

		damage = damage + damage_bonus

		InflictDamage(self:GetParent(),self:GetAbility():GetCaster(),self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
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