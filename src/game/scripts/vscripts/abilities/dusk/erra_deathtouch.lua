erra_deathtouch = class({})

LinkLuaModifier("modifier_deathtouch_dot","abilities/dusk/erra_deathtouch",LUA_MODIFIER_MOTION_NONE)

function erra_deathtouch:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Erra.DeathtouchPrecast")
	return true
end

function erra_deathtouch:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetAbilityDamage()
	local dtype = self:GetAbilityDamageType()
	local duration = self:GetSpecialValueFor("dot_duration")

	caster:EmitSound("Erra.Deathtouch")

	InflictDamage(target,caster,self,damage,dtype)

	target:AddNewModifier(caster, self, "modifier_deathtouch_dot", {Duration=duration}) --[[Returns:void
	No Description Set
	]]

	ParticleManager:CreateParticle("particles/units/heroes/hero_erra/deathtouch.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
end

modifier_deathtouch_dot = class({})

function modifier_deathtouch_dot:OnCreated(table)
	local tick = 0.25
	self.damage = self:GetAbility():GetSpecialValueFor("dot_amount") * tick
	self:StartIntervalThink(tick)
end

function modifier_deathtouch_dot:OnIntervalThink()
	if IsServer() then
		InflictDamage(self:GetParent(), self:GetCaster(), self:GetAbility(), self.damage, self:GetAbility():GetAbilityDamageType())
	end
end

function modifier_deathtouch_dot:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_deathtouch_dot:GetEffectName()
	return "particles/units/heroes/hero_erra/deathtouch_unit.vpcf"
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