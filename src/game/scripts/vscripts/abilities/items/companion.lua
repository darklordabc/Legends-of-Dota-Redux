LinkLuaModifier("modifier_companion_reincarnation", "abilities/items/companion.lua", LUA_MODIFIER_MOTION_NONE)

item_companion_consumable = class({})

function item_companion_consumable:SecondLife( OnDeathKeys, BuffInfo )
	local unit = OnDeathKeys.unit

	unit:SetHealth(unit:GetMaxHealth())
	unit:SetMana(unit:GetMaxMana())
	for i=0,16 do
		local ab = unit:GetAbilityByIndex(i)
		if IsValidEntity(ab) and ab.EndCooldown then ab:EndCooldown() end
		ab = unit:GetItemInSlot(i)
		if IsValidEntity(ab) and ab.EndCooldown then ab:EndCooldown() end
	end

	EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Wisp.Spirits.Target", unit)

	-- Add particle effects
	local particle_death_fx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_death_ti7_model_heart_redux.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(particle_death_fx, 0, unit:GetAbsOrigin() + Vector(0,0,180))
	ParticleManager:ReleaseParticleIndex(particle_death_fx)

	-- particle_death_fx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_overcharge_ti7_hearts.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	-- ParticleManager:SetParticleControl(particle_death_fx, 0, unit:GetAbsOrigin() + Vector(0,0,64))
	-- Timers:CreateTimer(2.0, function()
	-- 	ParticleManager:DestroyParticle(particle_death_fx, false)
	-- end)

	-- Wait for the caster to reincarnate, then play its sound
	local modifier = unit:FindModifierByName("modifier_companion_reincarnation")
	modifier:DecrementStackCount()
	unit:AddNewModifier(unit, nil, "modifier_invulnerable", {duration = 1.0})
	unit:Purge(false, true, false, true, false)
	if modifier:GetStackCount() == 0 then modifier:Destroy() end
end

function item_companion_consumable:OnSpellStart(keys)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local modifier
	if target:HasModifier("modifier_companion_reincarnation") then
		modifier = target:FindModifierByName("modifier_companion_reincarnation")
	else
		modifier = target:AddNewModifier(caster,caster,"modifier_companion_reincarnation",{})
	end
	modifier:SetStackCount(modifier:GetStackCount() + 1)
	-- modifier.reincarnate_delay = self:GetSpecialValueFor("reincarnate_delay")

	local particle_death_fx = ParticleManager:CreateParticle("particles/neutral_fx/roshan_valentines_attack_right_hearts_redux.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(particle_death_fx)

	for i=1,2 do
		particle_death_fx = ParticleManager:CreateParticle("particles/neutral_fx/roshan_valentines_attack_right_hearts_redux.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(particle_death_fx)
	end

	if self:GetCurrentCharges() == 1 then
		caster:RemoveItem(self)
	else
		self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	end
	

	caster:EmitSound("Hero_Wisp.Tether.Stun")
end

function item_companion_consumable:CastFilterResultTarget(target)
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
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_REINCARNATION, MODIFIER_PROPERTY_MIN_HEALTH}
	return decFuncs
end

function modifier_companion_reincarnation:GetMinHealth()
	return 1.0
end

function modifier_companion_reincarnation:ReincarnateTime()
	if IsServer() then
		if self.caster:IsRealHero() then
			return 5.0
		end

		return nil
	end
end

function modifier_companion_reincarnation:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetParent()
		if keys.unit:entindex() == caster:entindex() then
			if caster:GetHealth() == 1.0 then
				item_companion_consumable:SecondLife( keys, self )
			end
		end
	end
end