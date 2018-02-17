lich_deep_freeze = class({})

LinkLuaModifier("modifier_deep_freeze","abilities/dusk/lich_deep_freeze",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_deep_freeze_stun","abilities/dusk/lich_deep_freeze",LUA_MODIFIER_MOTION_NONE)

function lich_deep_freeze:GetIntrinsicModifierName()
	return "modifier_deep_freeze"
end

modifier_deep_freeze = class({})

function modifier_deep_freeze:DeclareFunctions()
	local func = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return func
end

function modifier_deep_freeze:AllowIllusionDuplicate()
	return false
end

function modifier_deep_freeze:OnAttackLanded(params)
	local attacker = params.attacker
	local target = params.unit or params.target

	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local stun = self:GetAbility():GetSpecialValueFor("stun")

	if attacker == self:GetParent() then
		if attacker:IsIllusion() then return end
		if target:IsBuilding() then return end
		if not target:IsAlive() then return end
		if target:IsMagicImmune() then return end
		if self:GetAbility():IsCooldownReady() then
			ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
			Creates a new particle effect
			]]
			target:EmitSound("Lich.DeepFreeze")

			InflictDamage(target,attacker,self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_deep_freeze_stun", {Duration=stun})
			self:GetAbility():UseResources(true, true, true)
		end
	end
end

modifier_deep_freeze_stun = class({})

function modifier_deep_freeze_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}
	return state
end

function modifier_deep_freeze_stun:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
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