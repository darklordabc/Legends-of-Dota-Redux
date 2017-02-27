keeper_of_the_light_innate_redux = class({})
LinkLuaModifier("modifier_keeper_of_the_light_innate_redux","abilities/keeper_of_the_light_innate.lua",LUA_MODIFIER_MOTION_NONE)
modifier_keeper_of_the_light_innate_redux = class({})

function keeper_of_the_light_innate_redux:GetIntrinsicModifierName()
  return "modifier_keeper_of_the_light_innate_redux"
end

function modifier_keeper_of_the_light_innate_redux:IsPassive() 
  return true
end

function modifier_keeper_of_the_light_innate_redux:IsPurgable()
  return false
end

function modifier_keeper_of_the_light_innate_redux:RemoveOnDeath()
  return false
end

function modifier_keeper_of_the_light_innate_redux:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_keeper_of_the_light_innate_redux:OnIntervalThink()
  local caster = self:GetParent()
  local ability = self:GetAbility()
  if caster:HasScepter() and caster:IsRealHero() and caster:IsAlive() and GameRules:IsDaytime() then
    AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin(),ability:GetSpecialValueFor("vision_radius"),2/32,false)
  end
end
