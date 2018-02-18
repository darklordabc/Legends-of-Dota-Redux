alexander_elandras_blessing = class({})

LinkLuaModifier("modifier_elandras_blessing","abilities/dusk/alexander_elandras_blessing",LUA_MODIFIER_MOTION_NONE)

function alexander_elandras_blessing:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	if target then
		target:AddNewModifier(caster, self, "modifier_elandras_blessing", {Duration=duration}) --[[Returns:void
		No Description Set
		]]
		target:EmitSound("Hero_Lich.FrostArmor") --[[Returns:void
		 
		]]
	end
end

modifier_elandras_blessing = class({})

function modifier_elandras_blessing:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function modifier_elandras_blessing:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_elandras_blessing:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_elandras_blessing:OnAttacked(params)
	local attacker = params.attacker
	local target = params.target
	if IsServer() then
		if target ~= self:GetParent() then return end

		local perc = self:GetAbility():GetSpecialValueFor("reflect_damage")/100
		local stat = self:GetParent():GetPrimaryAttribute()
		local damage = 0
		local str = self:GetParent():GetStrength()
		local agi = self:GetParent():GetAgility()
		local int = self:GetParent():GetIntellect()

		if stat == 0 then damage = str * perc end
		if stat == 1 then damage = agi * perc end
		if stat == 2 then damage = int * perc end

		DealDamage(attacker,self:GetParent(),damage,DAMAGE_TYPE_MAGICAL)

		attacker:EmitSound("LoneDruid_SpiritBear.Return")

		ParticleManager:CreateParticle("particles/units/heroes/hero_alexander/greater_vitality_damage.vpcf", PATTACH_POINT_FOLLOW, attacker)
	end
end

function modifier_elandras_blessing:OnAbilityFullyCast(params)
	if IsServer() then
		local attacker = params.unit
		local target = params.target
		if not target then return end
		if target:GetTeam() == attacker:GetTeam() then return end
		if target ~= self:GetParent() then return end

		local perc = self:GetAbility():GetSpecialValueFor("reflect_damage_spell")/100
		local stat = self:GetParent():GetPrimaryAttribute()
		local damage = 0
		local str = self:GetParent():GetStrength()
		local agi = self:GetParent():GetAgility()
		local int = self:GetParent():GetIntellect()

		if stat == 0 then damage = str * perc end
		if stat == 1 then damage = agi * perc end
		if stat == 2 then damage = int * perc end

		DealDamage(attacker,self:GetParent(),damage,DAMAGE_TYPE_MAGICAL)

		attacker:EmitSound("LoneDruid_SpiritBear.Return")

		ParticleManager:CreateParticle("particles/units/heroes/hero_alexander/greater_vitality_damage.vpcf", PATTACH_POINT_FOLLOW, attacker)
	end
end

function modifier_elandras_blessing:GetEffectName()
	return "particles/units/heroes/hero_alexander/greater_vitality.vpcf"
end

function modifier_elandras_blessing:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_elandras_blessing:IsPurgable()
	return true
end

function modifier_elandras_blessing:IsDebuff()
	return false
end

function DealDamage(target,attacker,damageAmount,damageType,ability,damageFlags)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local dtype = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  local ability = ability or nil
  if not IsValidEntity(target) and type(target) == "table" then
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = dtype,
          damage_flags = flags,
          ability = ability
        })
      end
    end
    return
  end
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = dtype,
    damage_flags = flags,
    ability = ability
  })
end