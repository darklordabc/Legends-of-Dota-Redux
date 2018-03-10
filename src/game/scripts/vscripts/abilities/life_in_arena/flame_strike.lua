LinkLuaModifier("modifier_flame_strike_thinker", "abilities/life_in_arena/flame_strike.lua", LUA_MODIFIER_MOTION_NONE)

firelord_flame_strike = class({})

function firelord_flame_strike:OnSpellStart()
	local target = self:GetCursorPosition()

	EmitSoundOn("Hero_Invoker.SunStrike.Charge", self:GetCaster())

	self.p = ParticleManager:CreateParticleForTeam("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_line_ground.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.p, 0, GetGroundPosition(target, self:GetCaster()))
	self.f = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.f, 0, GetGroundPosition(target, self:GetCaster()))
	ParticleManager:SetParticleControl(self.f, 1, Vector(200, 0, 0))
end

function firelord_flame_strike:OnChannelFinish(bInterrupted)
	if bInterrupted then
		StopSoundOn("Hero_Invoker.SunStrike.Charge", self:GetCaster())
		ParticleManager:DestroyParticle(self.p, true)
		ParticleManager:DestroyParticle(self.f, true)
	else
		CreateModifierThinker(self:GetCaster(), self, "modifier_flame_strike_thinker", {duration = self:GetSpecialValueFor("duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	end
	ParticleManager:ReleaseParticleIndex(self.p)
	ParticleManager:ReleaseParticleIndex(self.f)
	self.p = nil self.f = nil
end

modifier_flame_strike_thinker = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,

	OnCreated = function(self)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("delay"))
		self.particleRadius = 200
	end,

	OnIntervalThink = function(self)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))

		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Ability.LightStrikeArray", self:GetParent())

		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		local f = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(f, 0, GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetCaster()))
		ParticleManager:SetParticleControl(f, 1, Vector(self.particleRadius, 0, 0))
		ParticleManager:ReleaseParticleIndex(p)
		ParticleManager:ReleaseParticleIndex(f)

		self.particleRadius = self.particleRadius - 25

		local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for k,v in pairs(units) do
			ApplyDamage({victim = v, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = self:GetAbility():GetAbilityDamageType()})
		end
	end,
})