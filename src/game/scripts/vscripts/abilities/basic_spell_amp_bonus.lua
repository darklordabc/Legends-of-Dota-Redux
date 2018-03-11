basic_spell_amp_bonus=class({})
basic_spell_amp_bonus_op=class({})

modifier_basic_spell_amp_bonus = class({})
modifier_basic_spell_amp_bonus_op = class({})

LinkLuaModifier("modifier_basic_spell_amp_bonus","abilities/basic_spell_amp_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_spell_amp_bonus_op","abilities/basic_spell_amp_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_spell_amp_bonus:GetIntrinsicModifierName()
 return "modifier_basic_spell_amp_bonus"
end

function basic_spell_amp_bonus_op:GetIntrinsicModifierName()
 return "modifier_basic_spell_amp_bonus_op"
end

function modifier_basic_spell_amp_bonus:IsPermanent() return true end
function modifier_basic_spell_amp_bonus:IsHidden() return true end

function modifier_basic_spell_amp_bonus:DeclareFunctions() 
  return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_basic_spell_amp_bonus:GetModifierSpellAmplify_Percentage()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("spell_amp_bonus")
end

function modifier_basic_spell_amp_bonus_op:IsPermanent() return true end
function modifier_basic_spell_amp_bonus_op:IsHidden() return true end

function modifier_basic_spell_amp_bonus_op:DeclareFunctions() 
  return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_basic_spell_amp_bonus_op:GetModifierSpellAmplify_Percentage()
  if self:GetCaster():PassivesDisabled() then return 0 end
  return self:GetAbility():GetSpecialValueFor("spell_amp_bonus")
end
