alexander_godfall = class({})

LinkLuaModifier("modifier_godfall","abilities/dusk/alexander_godfall",LUA_MODIFIER_MOTION_NONE)

function alexander_godfall:OnSpellStart()
	self:GetCaster():EmitSound("Alexander.Godfall.Charge")
	local p = "particles/units/heroes/hero_alexander/godfall_start.vpcf"
	self.p_index = ParticleManager:CreateParticle(p, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster()) --[[Returns:int
		Creates a new particle effect
		]]
	ParticleManager:SetParticleControlEnt(self.p_index,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_hitloc",self:GetCaster():GetCenter(),true)

end

function alexander_godfall:OnChannelFinish(interrupted)
	local caster = self:GetCaster()
	
	if interrupted then
		ParticleManager:DestroyParticle(self.p_index,false)
		caster:StopSound("Alexander.Godfall.Charge") --[[Returns:void
		Stops a named sound playing from this entity.
		]]
		return
	end

	local duration = self:GetSpecialValueFor("duration") --[[Returns:table
	No Description Set
	]]

	caster:EmitSound("Alexander.Godfall.Charged")

	local ps = "particles/units/heroes/hero_alexander/godfall_success.vpcf"
	local p = ParticleManager:CreateParticle(ps, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster()) --[[Returns:int
	Creates a new particle effect
	]]
	ParticleManager:SetParticleControlEnt(p,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_hitloc",self:GetCaster():GetCenter(),true)

	caster:AddNewModifier(caster, self, "modifier_godfall", {Duration = duration}) --[[Returns:void
	No Description Set
	]]
end

-- Modifiers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_godfall = class({})

function modifier_godfall:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_godfall:GetEffectName()
	return "particles/units/heroes/hero_alexander/godfall_charged.vpcf"
end

function modifier_godfall:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if attacker ~= parent then return end

		local damage = attacker:GetAverageTrueAttackDamage(attacker)

		local m = self:GetAbility():GetSpecialValueFor("damage") / 100

		damage = damage * m

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alexander/godfall_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) --[[Returns:void
		No Description Set
		]]

		target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=0.5}) --[[Returns:void
		No Description Set
		]]

		target:Purge(true,false,false,false,false)

		InflictDamage(target,caster,self:GetAbility(),damage,DAMAGE_TYPE_PURE)

		target:EmitSound("Alexander.Godfall")

		if target:IsRealHero() then attacker:Heal(damage, caster) end

		self:Destroy()
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
	    ability = self
  	})
end