basic_stat_gain_bonus=class({})
basic_stat_gain_bonus_op=class({})

modifier_basic_stat_gain_bonus = class({})
modifier_basic_stat_gain_bonus_op = class({})

LinkLuaModifier("modifier_basic_stat_gain_bonus","abilities/basic_stat_gain_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_stat_gain_bonus_op","abilities/basic_stat_gain_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_stat_gain_bonus:GetIntrinsicModifierName()
 return "modifier_basic_stat_gain_bonus"
end

function basic_stat_gain_bonus_op:GetIntrinsicModifierName()
 return "modifier_basic_stat_gain_bonus_op"
end

function modifier_basic_stat_gain_bonus:IsPermanent() return true end
function modifier_basic_stat_gain_bonus:IsHidden() return true end

function modifier_basic_stat_gain_bonus:DeclareFunctions() 
  return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_basic_stat_gain_bonus:GetModifierBonusStats_Strength()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_STRENGTH +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end

function modifier_basic_stat_gain_bonus:GetModifierBonusStats_Agility()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_AGILITY +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end

function modifier_basic_stat_gain_bonus:GetModifierBonusStats_Intellect()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_INTELLECT +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end

function modifier_basic_stat_gain_bonus_op:IsPermanent() return true end
function modifier_basic_stat_gain_bonus_op:IsHidden() return true end

function modifier_basic_stat_gain_bonus_op:DeclareFunctions() 
  return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_basic_stat_gain_bonus_op:GetModifierBonusStats_Strength()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_STRENGTH +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end

function modifier_basic_stat_gain_bonus_op:GetModifierBonusStats_Agility()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_AGILITY +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end

function modifier_basic_stat_gain_bonus_op:GetModifierBonusStats_Intellect()
  if self:GetCaster():PassivesDisabled() then return 0 end
  if IsServer() then
    self:SetStackCount(self:GetCaster():GetPrimaryAttribute() + 1)
  end
  if self:GetStackCount() == DOTA_ATTRIBUTE_INTELLECT +1 then
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * 2 * self:GetCaster():GetLevel()
  else
    return self:GetAbility():GetSpecialValueFor("stat_gain_bonus") * self:GetCaster():GetLevel()
  end
end