LinkLuaModifier("modifier_chaos_knight_phantasm_invul","abilities/chaos_knight_phantasm",LUA_MODIFIER_MOTION_NONE)
chaos_knight_phantasm_redux = class({})

function chaos_knight_phantasm_redux:GetBehavior()
  if self:GetCaster():HasScepter() then 
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
  else
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
  end
end



function chaos_knight_phantasm_redux:OnSpellStart()
  local unit = self:GetCursorTarget()
  if not unit then unit = self:GetCaster() end

  self:GetCaster():EmitSound("Hero_ChaosKnight.Phantasm")

  if self:GetCaster():HasScepter() then
    local cooldown = self:GetCooldownTimeRemaining() + self:GetSpecialValueFor("cooldown_scepter")
    self:EndCooldown()
    self:StartCooldown(cooldown)
  end


  unit:AddNewModifier(self:GetCaster(),self,"modifier_chaos_knight_phantasm_invul",{duration = self:GetSpecialValueFor("invuln_duration")})
  ProjectileManager:ProjectileDodge(unit)

    
end



modifier_chaos_knight_phantasm_invul = class({})

function modifier_chaos_knight_phantasm_invul:OnRemoved()
  if IsServer() then
    local ability = self:GetAbility()
    local images_count = ability:GetSpecialValueFor("images_count")
    if RollPercentage(ability:GetSpecialValueFor("extra_phantasm_chance_pct_tooltip")) then
      images_count = images_count +1
    end
    
    ability:CreateIllusions(self:GetParent(),images_count,ability:GetSpecialValueFor("illusion_duration"),ability:GetSpecialValueFor("illusion_incoming_damage"),ability:GetSpecialValueFor("illusion_outgoing_damage"),50)
    self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin()+RandomVector(50))
  end
end

function modifier_chaos_knight_phantasm_invul:DeclareFunctions()
  local funcs =
  {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  } 
  return funcs
end

function modifier_chaos_knight_phantasm_invul:GetModifierModelChange()
  return "models/development/invisiblebox.vmdl"
end

function modifier_chaos_knight_phantasm_invul:CheckState()
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

