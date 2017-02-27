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

function modifier_night_stalker_innate_redux:IsHidden()
  if caster:HasScepter() and caster:IsAlive() and not GameRules:IsDaytime() then
    return false
  else
    return true
  end
end

function modifier_night_stalker_innate_redux:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_night_stalker_innate_redux:OnIntervalThink()
  local caster = self:GetParent()
  local ability = self:GetAbility()
  if caster:HasScepter() and caster:IsRealHero() and caster:IsAlive() and not GameRules:IsDaytime() then
    AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin(),ability:GetSpecialValueFor("vision_radius"),2/32,false)
  end
end
