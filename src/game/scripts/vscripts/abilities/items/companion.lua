LinkLuaModifier("modifier_companion_reincarnation", "abilities/items/companion.lua", LUA_MODIFIER_MOTION_NONE)

item_companion_consumable = class({})

function item_companion_consumable:SecondLife( OnDeathKeys, BuffInfo )
	local unit = OnDeathKeys.unit
	local reincarnate = OnDeathKeys.reincarnate
	-- Check if it was a reincarnation death
	if reincarnate then
		BuffInfo.reincarnation_death = true

		EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Wisp.Spirits.Target", unit)

		-- Add particle effects
		local particle_death_fx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_death_ti7_model_heart.vpcf", PATTACH_CUSTOMORIGIN, unit)
		ParticleManager:SetParticleControl(particle_death_fx, 0, unit:GetAbsOrigin() + Vector(0,0,160))
		ParticleManager:ReleaseParticleIndex(particle_death_fx)

		particle_death_fx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_overcharge_ti7_hearts.vpcf", PATTACH_CUSTOMORIGIN, unit)
		ParticleManager:SetParticleControl(particle_death_fx, 0, unit:GetAbsOrigin() + Vector(0,0,64))
		Timers:CreateTimer(5.0, function()
			ParticleManager:DestroyParticle(particle_death_fx, false)
		end)

		-- Add a FOW Viewer, depending on if it is a day or night
		if IsDaytime() then
			AddFOWViewer(BuffInfo.caster:GetTeamNumber(), unit:GetAbsOrigin(), unit:GetDayTimeVisionRange(), 5.0, true)
		else
			AddFOWViewer(BuffInfo.caster:GetTeamNumber(), unit:GetAbsOrigin(), unit:GetNightTimeVisionRange(), 5.0, true)
		end

		-- Wait for the caster to reincarnate, then play its sound
		Timers:CreateTimer(5.0, function()
			unit:RemoveModifierByName("modifier_companion_reincarnation")
		end)
	else
		BuffInfo.reincarnation_death = false
	end
end

function item_companion_consumable:OnSpellStart(keys)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local modifier = target:AddNewModifier(caster,caster,"modifier_companion_reincarnation",{})
	-- modifier.reincarnate_delay = self:GetSpecialValueFor("reincarnate_delay")

	caster:RemoveItem(self)

	caster:EmitSound("Hero_Wisp.Tether.Stun")
end

function item_companion_consumable:CastFilterResultTarget(target)
  if IsServer() then
  	if not target:HasModifier("modifier_companion_reincarnation") then
  		return UF_SUCCESS
  	else
  		return UF_FAIL_CUSTOM
  	end
  end
  return UF_SUCCESS
end

modifier_companion_reincarnation = class({})

function modifier_companion_reincarnation:GetTexture()
	return "custom/modifier_companion"
end

function modifier_companion_reincarnation:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
end

function modifier_companion_reincarnation:RemoveOnDeath()
	return false
end

function modifier_companion_reincarnation:IsHidden()
	return false
end
function modifier_companion_reincarnation:IsPurgable() return false end
function modifier_companion_reincarnation:IsDebuff() return false end

function modifier_companion_reincarnation:OnRefresh()
	self:OnCreated()
end

function modifier_companion_reincarnation:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_EVENT_ON_DEATH}
	return decFuncs
end

function modifier_companion_reincarnation:ReincarnateTime()
	if IsServer() then
		if self.caster:IsRealHero() then
			return 5.0
		end

		return nil
	end
end

function modifier_companion_reincarnation:OnDeath(keys)
	if IsServer() then
		local unit = keys.unit
		local reincarnate = keys.reincarnate

		if self:GetParent() == unit then
			item_companion_consumable:SecondLife( keys, self )
		end
	end
end