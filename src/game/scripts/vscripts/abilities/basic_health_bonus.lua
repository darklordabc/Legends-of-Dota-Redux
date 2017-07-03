basic_health_bonus=class({})
basic_health_bonus_op=class({})

modifier_basic_health_bonus = class({})
modifier_basic_health_bonus_op = class({})

LinkLuaModifier("modifier_basic_health_bonus","abilities/basic_health_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_health_bonus_op","abilities/basic_health_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_health_bonus:GetIntrinsicModifierName()
 return "modifier_basic_health_bonus"
end

function basic_health_bonus_op:GetIntrinsicModifierName()
 return "modifier_basic_health_bonus_op"
end

function modifier_basic_health_bonus:IsPermanent() return true end
function modifier_basic_health_bonus:IsHidden() return true end

function modifier_basic_health_bonus:DeclareFunctions() 
  return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_basic_health_bonus:GetModifierHealthBonus()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("health_bonus")
end

function modifier_basic_health_bonus_op:IsPermanent() return true end
function modifier_basic_health_bonus_op:IsHidden() return true end

function modifier_basic_health_bonus_op:DeclareFunctions() 
  return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_basic_health_bonus_op:GetModifierHealthBonus()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("health_bonus")
end
