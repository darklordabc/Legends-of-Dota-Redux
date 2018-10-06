basic_willpower_bonus=class({})
basic_willpower_bonus_op=class({})
modifier_basic_willpower_bonus = class({})
LinkLuaModifier("modifier_basic_willpower_bonus","abilities/basic_willpower_bonus.lua",LUA_MODIFIER_MOTION_NONE)


function basic_willpower_bonus:GetIntrinsicModifierName()
  return "modifier_basic_willpower_bonus"
end

function modifier_basic_willpower_bonus:IsPermanent() return true end
function modifier_basic_willpower_bonus:IsHidden() return true end

function modifier_basic_willpower_bonus:Getwillpower()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("willpower_bonus")
end

