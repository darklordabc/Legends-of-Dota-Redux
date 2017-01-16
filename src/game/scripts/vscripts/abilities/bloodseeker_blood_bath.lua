bloodseeker_blood_bath2 = class({})

LinkLuaModifier( "modifier_bloodseeker_blood_bath_t", "abilities/bloodseeker_blood_bath.lua" ,LUA_MODIFIER_MOTION_NONE )

function bloodseeker_blood_bath2:GetIntrinsicModifierName()
  if self:GetLevel() == 0 then
    return "modifier_bloodseeker_blood_bath_t"
  end
  return "modifier_bloodseeker_blood_bath_t"
end



------------------------------------------------------------------------
modifier_bloodseeker_blood_bath_t = class({})

function modifier_bloodseeker_blood_bath_t:IsHidden()
    return true
end
function modifier_bloodseeker_blood_bath_t:IsPurgable()
    return false
end
function modifier_bloodseeker_blood_bath_t:RemoveOnDeath()
    return false
end
function modifier_bloodseeker_blood_bath_t:IsPassive()
  return true
end

function modifier_bloodseeker_blood_bath_t:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_bloodseeker_blood_bath_t:OnDeath(keys)
  if IsServer() and keys.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
    local attacker = keys.attacker
    local victim = keys.unit
    local unit = self:GetParent()

    if unit:PassivesDisabled() or victim:IsBuilding() or unit:IsIllusion() then
      return 
    end


    local healRadius = self:GetAbility():GetSpecialValueFor("heal_radius")
    local heal
    if unit:GetRangeToUnit(victim) <= healRadius or attacker == unit then
      if victim:IsRealHero() then
        local percentOfMaxHealth = self:GetAbility():GetSpecialValueFor("hero_max_hp_heal") * 0.01
        heal = percentOfMaxHealth * victim:GetMaxHealth()
      else
        local percentOfMaxHealth = self:GetAbility():GetSpecialValueFor("non_hero_max_hp_heal") * 0.01
        heal = percentOfMaxHealth * victim:GetMaxHealth()
      end
      unit:Heal(heal,unit)
      SendOverheadEventMessage(unit,OVERHEAD_ALERT_HEAL,unit,heal,nil)
      local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
      ParticleManager:SetParticleControl(healParticle, 1, Vector(radius, radius, radius))
      ParticleManager:ReleaseParticleIndex(healParticle)
    end
  end
end
