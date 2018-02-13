erra_to_dust = class({})

LinkLuaModifier("modifier_to_dust_damage","abilities/dusk/erra_to_dust",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_to_dust_show","abilities/dusk/erra_to_dust",LUA_MODIFIER_MOTION_NONE)

if IsServer() then

	function erra_to_dust:OnSpellStart()
		local caster = self:GetCaster()

		local damage = self:GetSpecialValueFor("hp_to_bonus_damage")/100

		local creep_damage = self:GetSpecialValueFor("creep_hp_to_bonus_damage")/100

		local radius = self:GetSpecialValueFor("radius")

		local duration = self:GetSpecialValueFor("duration")

		local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
	                  caster:GetCenter(),
	                  nil,
	                    radius,
	                    DOTA_UNIT_TARGET_TEAM_ENEMY,
	                    DOTA_UNIT_TARGET_HERO,
	                    DOTA_UNIT_TARGET_FLAG_NONE,
	                    FIND_CLOSEST,
	                    false)

		local enemy_creep = FindUnitsInRadius( caster:GetTeamNumber(),
	                  caster:GetCenter(),
	                  nil,
	                    radius,
	                    DOTA_UNIT_TARGET_TEAM_ENEMY,
	                    DOTA_UNIT_TARGET_CREEP,
	                    DOTA_UNIT_TARGET_FLAG_NONE,
	                    FIND_CLOSEST,
	                    false)

		local total_damage_bonus = 0

		for k,v in pairs(enemy_found) do
			total_damage_bonus = total_damage_bonus + v:GetHealthDeficit() * damage
			ParticleManager:CreateParticle("particles/units/heroes/hero_erra/to_dust_affected_unit.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
			Creates a new particle effect
			]]
		end

		for k,v in pairs(enemy_creep) do
			total_damage_bonus = total_damage_bonus + v:GetHealthDeficit() * creep_damage
			ParticleManager:CreateParticle("particles/units/heroes/hero_erra/to_dust_affected_unit.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
			Creates a new particle effect
			]]
		end

		total_damage_bonus = math.floor(total_damage_bonus)

		if total_damage_bonus > 0 then
			caster:EmitSound("Erra.ToDust")
			caster:AddNewModifier(caster, self, "modifier_to_dust_damage", {Duration=duration,stack=total_damage_bonus}) --[[Returns:void
			No Description Set
			]]

			caster:AddNewModifier(caster, self, "modifier_to_dust_show", {Duration=duration}) --[[Returns:void
			No Description Set
			]]
		end
	end

end

modifier_to_dust_damage = class({})

if IsServer() then

	function modifier_to_dust_damage:OnCreated(kv)
		if kv then
			if kv.stack then
				self:SetStackCount(kv.stack)
			end
		end
	end

end

function modifier_to_dust_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_to_dust_damage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_to_dust_damage:IsHidden()
	return true
end

modifier_to_dust_show = class({})