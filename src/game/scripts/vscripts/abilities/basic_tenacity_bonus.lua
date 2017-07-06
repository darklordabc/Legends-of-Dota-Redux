basic_tenacity_bonus=class({})
basic_tenacity_bonus_op=class({})
modifier_basic_tenacity_bonus = class({})
modifier_basic_tenacity_bonus_op = class({})
LinkLuaModifier("modifier_basic_tenacity_bonus","abilities/basic_tenacity_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_tenacity_bonus_op","abilities/basic_tenacity_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_tenacity_bonus:GetIntrinsicModifierName()
  return "modifier_basic_tenacity_bonus"
end

function modifier_basic_tenacity_bonus:IsPermanent() return true end
function modifier_basic_tenacity_bonus:IsHidden() return true end

function modifier_basic_tenacity_bonus:GetTenacity()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("tenacity_bonus")
end

function basic_tenacity_bonus_op:OnUpgrade()
 self:GetCaster():RemoveModifierByName("modifier_basic_tenacity_bonus_op")
 self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_basic_tenacity_bonus_op",{})
end

function modifier_basic_tenacity_bonus_op:IsPermanent() return true end
function modifier_basic_tenacity_bonus_op:IsHidden() return true end

function modifier_basic_tenacity_bonus_op:GetTenacity()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("tenacity_bonus")
end

