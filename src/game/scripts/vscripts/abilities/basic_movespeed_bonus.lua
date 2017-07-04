basic_movespeed_bonus=class({})
basic_movespeed_bonus_op=class({})

modifier_basic_movespeed_bonus = class({})
modifier_basic_movespeed_bonus_op = class({})

LinkLuaModifier("modifier_basic_movespeed_bonus","abilities/basic_movespeed_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_movespeed_bonus_op","abilities/basic_movespeed_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_movespeed_bonus:GetIntrinsicModifierName()
 return "modifier_basic_movespeed_bonus"
end

function basic_movespeed_bonus_op:GetIntrinsicModifierName()
 return "modifier_basic_movespeed_bonus_op"
end

function modifier_basic_movespeed_bonus:IsPermanent() return true end
function modifier_basic_movespeed_bonus:IsHidden() return true end

function modifier_basic_movespeed_bonus:DeclareFunctions() 
  return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_basic_movespeed_bonus:GetModifierMoveSpeedBonus_Constant()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("speed_bonus")
end

function modifier_basic_movespeed_bonus_op:IsPermanent() return true end
function modifier_basic_movespeed_bonus_op:IsHidden() return true end

function modifier_basic_movespeed_bonus_op:DeclareFunctions() 
  return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_basic_movespeed_bonus_op:GetModifierMoveSpeedBonus_Constant()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("speed_bonus")
end
