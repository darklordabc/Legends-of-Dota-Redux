morph_int_str_redux = class({})
LinkLuaModifier("modifier_morph_int_str","abilities/morphling_morph_str_int",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morph_int_str_passive","abilities/morphling_morph_str_int",LUA_MODIFIER_MOTION_NONE)

--[[function morph_int_str_redux:OnUpgrade()
  if self:GetCaster():HasAbility("morph_str_int_redux") and not self:GetCaster():FindAbilityByName("morph_str_int_redux"):GetLevel() == self:GetLevel() then
    self:GetCaster():FindAbilityByName("morph_str_int_redux"):SetLevel(self:GetLevel())
  end
end]]

function morph_int_str_redux:OnToggle()
  -- Determine if the toggle is on or off and act on it
  if self:GetToggleState() then
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_morph_int_str",{})
    self:GetCaster():EmitSound("Hero_Morphling.MorphStrength")
  else
    self:GetCaster():RemoveModifierByName("modifier_morph_int_str")
    self:GetCaster():StopSound("Hero_Morphling.MorphStrength")
  end

  -- Toggle the oppositie off
  if self:GetCaster():HasAbility("morph_str_int_redux") and self:GetCaster():FindAbilityByName("morph_str_int_redux"):GetToggleState() then
    self:GetCaster():FindAbilityByName("morph_str_int_redux"):ToggleAbility()
  end
end

function morph_int_str_redux:GetIntrinsicModifierName()
  return "modifier_morph_int_str_passive"
end

modifier_morph_int_str_passive= class({})

function modifier_morph_int_str_passive:IsPermanent()
  return true
end
function modifier_morph_int_str_passive:IsHidden()
  return true
end


function modifier_morph_int_str_passive:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
  }
  return funcs
end

function modifier_morph_int_str_passive:GetModifierBonusStats_Strength()
  return self:GetAbility():GetSpecialValueFor("bonus_str")
end

modifier_morph_int_str = class({})

function modifier_morph_int_str:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    local interval = ability:GetSpecialValueFor("stats_per_second")

    self:StartIntervalThink(interval)
  end
end

function modifier_morph_int_str:OnIntervalThink()
  -- Cancel if dead
  if not self:GetCaster():IsAlive() then
    self:GetAbility():ToggleAbility()
    return 
  end

  local mana_per_tick = self:GetAbility():GetSpecialValueFor("mana_per_second") * self:GetAbility():GetSpecialValueFor("stats_per_second")

  -- Check if the caster has mana
  if self:GetCaster():GetMana() < mana_per_tick then
    --self:GetAbility():ToggleAbility()
    return
  end

  -- Check if base stats are bigger than 1
  if self:GetCaster():GetBaseIntellect() <= 1 then
    --self:GetAbility():ToggleAbility() -- In the game it doesn't go off
    return
  end
  local ability = self:GetAbility()
  local interval = ability:GetSpecialValueFor("stats_per_second")
  self:GetCaster():SpendMana(mana_per_tick,self:GetAbility())
  self:GetCaster():ModifyIntellect(-1)
  self:GetCaster():ModifyStrength(1)
  --self:GetCaster():ReduceMana(12) -- Reduce 12 mana ( Not sure if the % from the int reduction should be refunded)
end

function modifier_morph_int_str:GetEffectName()
  return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end

function modifier_morph_int_str:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end


morph_str_int_redux = class({})
LinkLuaModifier("modifier_morph_str_int","abilities/morphling_morph_str_int",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morph_str_int_passive","abilities/morphling_morph_str_int",LUA_MODIFIER_MOTION_NONE)

--[[function morph_str_int_redux:OnUpgrade()
  if self:GetCaster():HasAbility("morph_int_str_redux") then
    self:GetCaster():FindAbilityByName("morph_int_str_redux"):SetLevel(self:GetLevel())
  end
end]]

function morph_str_int_redux:OnToggle()
  -- Determine if the toggle is on or off and act on it
  if self:GetToggleState() then
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_morph_str_int",{})
    self:GetCaster():EmitSound("Hero_Morphling.MorphAgility")
  else
    self:GetCaster():RemoveModifierByName("modifier_morph_str_int")
    self:GetCaster():StopSound("Hero_Morphling.MorphAgility")
  end

  -- Toggle the oppositie off
  if self:GetCaster():HasAbility("morph_int_str_redux") and self:GetCaster():FindAbilityByName("morph_int_str_redux"):GetToggleState() then
    self:GetCaster():FindAbilityByName("morph_int_str_redux"):ToggleAbility()
  end
end

function morph_str_int_redux:GetIntrinsicModifierName()
  return "modifier_morph_str_int_passive"
end

modifier_morph_str_int_passive= class({})

function modifier_morph_str_int_passive:IsPermanent()
  return true
end
function modifier_morph_str_int_passive:IsHidden()
  return true
end

function modifier_morph_str_int_passive:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_morph_str_int_passive:GetModifierBonusStats_Intellect()
  return self:GetAbility():GetSpecialValueFor("bonus_int")
end

modifier_morph_str_int = class({})

function modifier_morph_str_int:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    local interval = ability:GetSpecialValueFor("stats_per_second")

    self:StartIntervalThink(interval)
  end
end

function modifier_morph_str_int:OnIntervalThink()
  -- Cancel if dead
  if not self:GetCaster():IsAlive() then
    self:GetAbility():ToggleAbility()
    return 
  end

  local mana_per_tick = self:GetAbility():GetSpecialValueFor("mana_per_second") * self:GetAbility():GetSpecialValueFor("stats_per_second")

  -- Check if the caster has mana
  if self:GetCaster():GetMana() < mana_per_tick then
    --self:GetAbility():ToggleAbility()
    return
  end

  -- Check if base stats are bigger than 1
  if self:GetCaster():GetBaseStrength() <= 1 then
    --self:GetAbility():ToggleAbility() -- In the game it doesn't go off
    return
  end
  local ability = self:GetAbility()
  local interval = ability:GetSpecialValueFor("stats_per_second")
  self:GetCaster():SpendMana(mana_per_tick,self:GetAbility())
  self:GetCaster():ModifyIntellect(1)
  self:GetCaster():ModifyStrength(-1)

  -- Not sure if needed to check if hp <= 0

  if self:GetCaster():GetHealth() <= 0 then
    self:GetCaster():SetHealth(1)
  end
  --self:GetCaster():GiveMana(12) -- Add 12 mana ( Not sure if the % from the int addition should be refunded)
end

function modifier_morph_str_int:GetEffectName()
  return "particles/morphling_morph_int.vpcf"
end

function modifier_morph_str_int:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end
