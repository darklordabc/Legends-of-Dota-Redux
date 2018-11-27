LinkLuaModifier("modifier_item_vladimir_consumable", "abilities/items/vladimir.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_vladimir_consumable_aura", "abilities/items/vladimir.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vlads_info", "abilities/items/vladimir.lua", LUA_MODIFIER_MOTION_NONE)

item_vladimir_consumable = class({})

function item_vladimir_consumable:GetIntrinsicModifierName()
  return "modifier_item_vladimir_consumable"
end

function item_vladimir_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_vladimir_consumable:CastFilterResultTarget(target)
  -- Check if its the caster thats targetted
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  -- Check if the ability exists/can be given
  if IsServer() then
    local name = self:GetIntrinsicModifierName()
    if not self:GetCaster():HasAbility("ability_consumable_item_container") then
      local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
      ab:SetLevel(1)
      ab:SetHidden(true)
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
    if not ab or ab[name] then
      return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
  end
  return UF_SUCCESS
end

function item_vladimir_consumable:GetCustomCastErrorTarget(target)
  if self:GetCaster() ~= target then
    return "#consumable_items_only_self"
  end
  local ab  = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if not ab then
    return "#consumable_items_no_available_slot"
  end
  local name = self:GetIntrinsicModifierName()
  if ab[name] then
    return "#consumable_items_already_consumed"
  end
end

function item_vladimir_consumable:ConsumeItem(hCaster)
  local name = self:GetIntrinsicModifierName()
  -- Learn the ability container if needed
  if not self:GetCaster():HasAbility("ability_consumable_item_container") then
    local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
    ab:SetLevel(1)
    ab:SetHidden(true)
  end
  -- Double check everything works, then remove the item and add the modifier from the container ability
  local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if ab and not ab[name] then
    hCaster:RemoveItem(self)
    hCaster:RemoveModifierByName(name)
    local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
    ab[name] = true
  end
end


modifier_item_vladimir_consumable = class({
  IsHidden = function(self) 
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility().IsItem
  end,
  IsPurgable = function() return false end,
  IsPassive = function() return true end,
  IsPermanent = function() return true end,
  RemoveOnDeath = function() return false end,
  GetTexture = function() return "item_vladmir" end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,

  IsAura = function() return true end,
  GetAuraSearchTeam = function() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
  GetAuraSearchType = function() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
  GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end,
  GetModifierAura = function() return "modifier_item_vladimir_consumable_aura" end,
  GetAuraRadius = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_aura_radius")
  end,

  DeclareFunctions = function() 
    return {
      MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
      MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
      MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
      MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
  end,

  GetModifierBonusStats_Strength = function(self)    
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_bonus_all_stats")
  end,
  GetModifierBonusStats_Agility = function(self)    
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_bonus_all_stats")
  end,
  GetModifierBonusStats_Intellect = function(self)    
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_bonus_all_stats")
  end,
  GetModifierConstantHealthRegen = function(self)    
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_hp_regen")
  end,
})

modifier_item_vladimir_consumable_aura = class({
  IsHidden = function() return false end,
  IsPurgable = function() return false end,
  GetTexture = function() return "item_vladmir" end,

  DeclareFunctions = function() 
    return {
      MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
      MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
      MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
      MODIFIER_EVENT_ON_ATTACK_LANDED,
      MODIFIER_PROPERTY_TOOLTIP,
    }
  end,

  OnTooltip = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetParent():IsRangedAttacker() and self:GetAbility():GetSpecialValueFor("vlads_vampiric_aura_ranged") or self:GetAbility():GetSpecialValueFor("vlads_vampiric_aura")
  end,

  GetModifierConstantManaRegen = function(self)     
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_mana_regen_aura")
  end,

  GetModifierPhysicalArmorBonus = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("vlads_armor_aura")
  end,

  GetModifierPreAttack_BonusDamage = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    if IsServer() then
      local average = (self:GetParent():GetBaseDamageMin() + self:GetParent():GetBaseDamageMax()) / 2
      self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_vlads_info", {})
      self:GetParent():SetModifierStackCount("modifier_vlads_info", self:GetCaster(), average)
    end
    local damage = self:GetParent():GetModifierStackCount("modifier_vlads_info", self:GetCaster()) or 0
    return damage * self:GetAbility():GetSpecialValueFor("vlads_damage_aura") * 0.01
  end,

  OnAttackLanded = function(self, keys)
    if self:GetParent() == keys.attacker then
      if keys.target:IsAlive() then
        if not keys.target:IsOther() and not keys.target:IsBuilding() then
          local lifesteal = self:GetParent():IsRangedAttacker() and self:GetAbility():GetSpecialValueFor("vampiric_aura_ranged") or self:GetAbility():GetSpecialValueFor("vampiric_aura")
          self:GetParent():Heal(lifesteal * keys.damage * 0.01, self:GetParent())

          local p = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
          --ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
          ParticleManager:ReleaseParticleIndex(p)
        end
      end
    end
  end,
})

modifier_vlads_info = class({
  IsHidden = function(self) 
    if IsServer() then
      if not self:GetParent():HasModifier("modifier_item_vladimir_consumable_aura") then
        self:Destroy()
        return
      end
    end
    return true 
  end,
  IsPurgable = function() return false end,
})
