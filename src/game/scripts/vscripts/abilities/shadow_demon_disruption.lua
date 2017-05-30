LinkLuaModifier("modifier_shadow_demon_disruption_redux","abilities/shadow_demon_disruption",LUA_MODIFIER_MOTION_NONE)
shadow_demon_disruption_redux = class({})

function shadow_demon_disruption_redux:OnSpellStart()
  self:GetCursorTarget():AddNewModifier(self:GetCaster(),self,"modifier_shadow_demon_disruption_redux",{duration = self:GetSpecialValueFor("disruption_duration")})
end

modifier_shadow_demon_disruption_redux = class({})

function modifier_shadow_demon_disruption_redux:OnDestroy()
  if IsServer() then
    local ability = self:GetAbility()
    local illusions = ability:CreateIllusions(self:GetParent(),ability:GetSpecialValueFor("illusion_count"),ability:GetSpecialValueFor("illusion_duration"),ability:GetSpecialValueFor("illusion_incoming_damage"),ability:GetSpecialValueFor("illusion_outgoing_damage"),50)
    for k,v in pairs(illusions) do
      v:MoveToTargetToAttack(self:GetParent())
    end
  end
end

function modifier_shadow_demon_disruption_redux:DeclareFunctions()
  local funcs =
  {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  } 
  return funcs
end

function modifier_shadow_demon_disruption_redux:GetModifierModelChange()
  return "models/development/invisiblebox.vmdl"
end

function modifier_shadow_demon_disruption_redux:GetEffectName()
  return "particles/units/heroes/hero_shadow_demon/shadow_demon_disruption.vpcf"
end

function modifier_shadow_demon_disruption_redux:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shadow_demon_disruption_redux:CheckState()
  local states =
  {
    [MODIFIER_STATE_OUT_OF_GAME] = true,
    [MODIFIER_STATE_STUNNED] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_INVISIBLE] = true,
  }
  return states
end

