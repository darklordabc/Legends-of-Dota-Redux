morph_int_agi_redux = class({})
LinkLuaModifier("modifier_morph_int_agi","abilities/morphling_morph_agi_int",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morph_int_agi_passive","abilities/morphling_morph_agi_int",LUA_MODIFIER_MOTION_NONE)

-- Don't think this is needed in redux, also it needs to compare levels because in this state it keeps setting levels for their counterparts 

--[[function morph_int_agi_redux:OnUpgrade()
  if self:GetCaster():HasAbility("morph_agi_int_redux") then
    self:GetCaster():FindAbilityByName("morph_agi_int_redux"):SetLevel(self:GetLevel())
  end
end]]

function morph_int_agi_redux:OnToggle()
  -- Determine if the toggle is on or off and act on it
  if self:GetToggleState() then
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_morph_int_agi",{})
    self:GetCaster():EmitSound("Hero_Morphling.MorphAgility")
  else
    self:GetCaster():RemoveModifierByName("modifier_morph_int_agi")
    self:GetCaster():StopSound("Hero_Morphling.MorphAgility")
  end

  -- Toggle the oppositie off
  if self:GetCaster():HasAbility("morph_agi_int_redux") and self:GetCaster():FindAbilityByName("morph_agi_int_redux"):GetToggleState() then
    self:GetCaster():FindAbilityByName("morph_agi_int_redux"):ToggleAbility()
  end
end

function morph_int_agi_redux:GetIntrinsicModifierName()
  return "modifier_morph_int_agi_passive"
end

modifier_morph_int_agi_passive= class({})

function modifier_morph_int_agi_passive:IsPermanent()
  return true
end
function modifier_morph_int_agi_passive:IsHidden()
  return true
end

function modifier_morph_int_agi_passive:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_STATS_AGILITY_BONUS
  }
  return funcs
end

function modifier_morph_int_agi_passive:GetModifierBonusStats_Agility()
  return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

modifier_morph_int_agi = class({})

function modifier_morph_int_agi:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    local interval = ability:GetSpecialValueFor("stats_per_second")

    self:StartIntervalThink(interval)
  end
end

function modifier_morph_int_agi:OnIntervalThink()
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
  self:GetCaster():ModifyAgility(1)
  --self:GetCaster():ReduceMana(12) -- Reduce 12 mana ( Not sure if the % from the int reduction should be refunded)
end

function modifier_morph_int_agi:GetEffectName()
  return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end

function modifier_morph_int_agi:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end



morph_agi_int_redux = class({})
LinkLuaModifier("modifier_morph_agi_int","abilities/morphling_morph_agi_int",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morph_agi_int_passive","abilities/morphling_morph_agi_int",LUA_MODIFIER_MOTION_NONE)

--[[function morph_agi_int_redux:OnUpgrade()
  if self:GetCaster():HasAbility("morph_int_agi_redux") then
    self:GetCaster():FindAbilityByName("morph_int_agi_redux"):SetLevel(self:GetLevel())
  end
end]]

function morph_agi_int_redux:OnToggle()
  -- Determine if the toggle is on or off and act on it
  if self:GetToggleState() then
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_morph_agi_int",{})
    self:GetCaster():EmitSound("Hero_Morphling.MorphStrength")
  else
    self:GetCaster():RemoveModifierByName("modifier_morph_agi_int")
    self:GetCaster():StopSound("Hero_Morphling.MorphStrength")
  end

  -- Toggle the oppositie off
  if self:GetCaster():HasAbility("morph_int_agi_redux") and self:GetCaster():FindAbilityByName("morph_int_agi_redux"):GetToggleState() then
    self:GetCaster():FindAbilityByName("morph_int_agi_redux"):ToggleAbility()
  end
end

function morph_agi_int_redux:GetIntrinsicModifierName()
  return "modifier_morph_agi_int_passive"
end

modifier_morph_agi_int_passive= class({})

function modifier_morph_agi_int_passive:IsPermanent()
  return true
end
function modifier_morph_agi_int_passive:IsHidden()
  return true
end


function modifier_morph_agi_int_passive:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
  }
  return funcs
end

function modifier_morph_agi_int_passive:GetModifierBonusStats_Intellect()
  return self:GetAbility():GetSpecialValueFor("bonus_int")
end

modifier_morph_agi_int = class({})

function modifier_morph_agi_int:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    local interval = ability:GetSpecialValueFor("stats_per_second")

    self:StartIntervalThink(interval)
  end
end

function modifier_morph_agi_int:OnIntervalThink()
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
  if self:GetCaster():GetBaseAgility() <= 1 then
    --self:GetAbility():ToggleAbility() -- In the game it doesn't go off
    return
  end

  local ability = self:GetAbility()
  local interval = ability:GetSpecialValueFor("stats_per_second")
  self:GetCaster():SpendMana(mana_per_tick,self:GetAbility())
  self:GetCaster():ModifyIntellect(1)
  self:GetCaster():ModifyAgility(-1)
  --self:GetCaster():GiveMana(12) -- Add 12 mana ( Not sure if the % from the int addition should be refunded)
end

function modifier_morph_agi_int:GetEffectName()
  return "particles/morphling_morph_int.vpcf"
end

function modifier_morph_agi_int:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end
