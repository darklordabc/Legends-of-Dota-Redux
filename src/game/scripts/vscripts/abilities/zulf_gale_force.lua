
zulf_gale_force = class({})
LinkLuaModifier("modifier_gale_force", "abilities/zulf_gale_force.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gale_force_disarm", "abilities/zulf_gale_force.lua", LUA_MODIFIER_MOTION_NONE)


function zulf_gale_force:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local sound_cast = "Hero_Invoker.Tornado.Target"
		local modifier_aura = "modifier_gale_force"

		local duration = ability:GetSpecialValueFor("duration")
		local delay = ability:GetSpecialValueFor("delay")

		EmitSoundOn(sound_cast, caster)

		caster:AddNewModifier(caster, ability, modifier_aura, {duration = duration})

		Timers:CreateTimer(delay, function()
			EmitSoundOn(sound_cast, caster)
		end)
	end
end

-- Disarm Aura
modifier_gale_force = class({})

function modifier_gale_force:GetAuraRadius()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")		

	return radius
end

function modifier_gale_force:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_gale_force:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_gale_force:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_gale_force:GetModifierAura()
	return "modifier_gale_force_disarm"
end

function modifier_gale_force:IsAura()
	return true
end

function modifier_gale_force:IsHidden()
	return false
end

function modifier_gale_force:IsDebuff()
	return true
end

function modifier_gale_force:GetAuraEntityReject( target )
	if IsServer() then
		local caster = self:GetCaster()

		-- Only apply on the caster or enemies of the caster
		if target == caster or target:GetTeamNumber() ~= caster:GetTeamNumber() then
			return false
		else
			return true
		end
	end
end


-- Disarm modifier
modifier_gale_force_disarm = class({})

function modifier_gale_force_disarm:CheckState()
	local state = {[MODIFIER_STATE_DISARMED] = true}
	return state
end

function modifier_gale_force_disarm:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()	
	
	local interval = ability:GetSpecialValueFor("interval")

	self:StartIntervalThink(interval)
end

function modifier_gale_force_disarm:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		local damage_per_agility = ability:GetSpecialValueFor("damage_per_agility")
		local interval = ability:GetSpecialValueFor("interval")

		local damage = caster:GetAgility() * damage_per_agility / (1/interval)

		-- Don't damage caster
		if parent == caster then
			return nil
		end

		local damageTable = {
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = ability,
			damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
		}
										
		ApplyDamage(damageTable)
	end
end

function modifier_gale_force_disarm:IsPurgable()
	return true
end

function modifier_gale_force_disarm:IsHidden()
	return false
end

function modifier_gale_force_disarm:IsDebuff()
	return true
end

function modifier_gale_force_disarm:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"	
end

function modifier_gale_force_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW	
end

