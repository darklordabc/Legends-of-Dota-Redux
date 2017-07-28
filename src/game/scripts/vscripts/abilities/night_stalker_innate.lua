night_stalker_innate_redux = class({})
LinkLuaModifier("modifier_night_stalker_innate_redux","abilities/night_stalker_innate.lua",LUA_MODIFIER_MOTION_NONE)
modifier_night_stalker_innate_redux = class({})

function night_stalker_innate_redux:GetIntrinsicModifierName()
  return "modifier_night_stalker_innate_redux"
end

function modifier_night_stalker_innate_redux:IsPassive() 
  return true
end

function modifier_night_stalker_innate_redux:IsPurgable()
  return false
end

function modifier_night_stalker_innate_redux:RemoveOnDeath()
  return false
end

function modifier_night_stalker_innate_redux:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_night_stalker_innate_redux:IsHidden()
  return self:GetStackCount() == 1
end

function modifier_night_stalker_innate_redux:OnIntervalThink()
  local caster = self:GetParent()
  local ability = self:GetAbility()
  local vision = ability:GetSpecialValueFor("vision_radius")
  local scepterBonus = ability:GetSpecialValueFor("scepter_bonus")

  if caster:HasScepter() then
    vision = vision + scepterBonus
  end

  if caster:IsAlive() and not GameRules:IsDaytime() then
    self:SetStackCount(0)
    AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin(),vision,2/32,false)
  else
    self:SetStackCount(1)
  end
end