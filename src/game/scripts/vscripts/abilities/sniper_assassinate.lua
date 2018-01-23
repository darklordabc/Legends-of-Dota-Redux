sniper_assassinate_redux = class({})

LinkLuaModifier("modifier_sniper_assassinate_caster_redux","abilities/sniper_assassinate.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sniper_assassinate_target_redux","abilities/sniper_assassinate.lua",LUA_MODIFIER_MOTION_NONE)

function sniper_assassinate_redux:GetBehavior()
  if not self:GetCaster():HasScepter() then 
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
  else
    local behaviour = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    return behaviour
  end
end

function sniper_assassinate_redux:GetAbilityDamageType()
  if not self:GetCaster():HasScepter() then 
    return DAMAGE_TYPE_MAGICAL
  else
    return DAMAGE_TYPE_PHYSICAL
  end
end

function sniper_assassinate_redux:GetAOERadius()
  if not self:GetCaster():HasScepter() then 
    return 0
  else
    return self:GetSpecialValueFor("scepter_radius")
  end
end

function sniper_assassinate_redux:GetAbilityDamage()
  if not self:GetCaster():HasScepter() then 
    return self:GetSpecialValueFor("damage")
  else
    return 0
  end
end

function sniper_assassinate_redux:ProcsMagicStick()
  return true
end
function sniper_assassinate_redux:GetBackswingTime()
  local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sniper_4")
  if talent then
    if talent:GetLevel() > 0 then
      return 0.5
    end
  end

  return 2.87
end
function sniper_assassinate_redux:GetCastPoint()
  local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sniper_4")
  if talent then
    if talent:GetLevel() > 0 then
      return 0.5
    end
  end

  return 2.0 
end

-------------------------------------------------------------------------------------------
function sniper_assassinate_redux:OnAbilityPhaseStart(keys)
  local caster = self:GetCaster()
  caster:EmitSound("Ability.AssassinateLoad")
  self.storedTarget = {}
  caster:AddNewModifier(caster,self,"modifier_sniper_assassinate_caster_redux",{})
  if not caster:HasScepter() then
    self.storedTarget[1] = self:GetCursorTarget()
    self.storedTarget[1]:AddNewModifier(caster,self,"modifier_sniper_assassinate_target_redux",{duration = self:GetSpecialValueFor("debuff_duration")}) -- Make this
  else
    local point = self:GetCursorPosition()
    self.storedTarget = FindUnitsInRadius(caster:GetTeamNumber(),point,caster,self:GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
    for k,v in pairs(self.storedTarget) do
      v:AddNewModifier(caster,self,"modifier_sniper_assassinate_target_redux",{duration = self:GetSpecialValueFor("debuff_duration")})
    end
  end
  return true
end

function sniper_assassinate_redux:OnSpellStart(keys)
  self:GetCaster():EmitSound("Ability.Assassinate")
  
  if not self.storedTarget then 
    return 
  end
  for k,v in pairs(self.storedTarget) do
    --print(v:GetUnitName())
    local projTable = {
      EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
      Ability = self,
      Target = v,
      Source = self:GetCaster(),
      bDodgeable = true,
      bProvidesVision = true,
      vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
      iMoveSpeed = self:GetSpecialValueFor("projectile_speed"), --
      iVisionRadius = 100,--
      iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile(projTable)
  end
end

function sniper_assassinate_redux:OnProjectileHit(hTarget,vLocation)
  local caster = self:GetCaster()
  local ability = self
  local target = hTarget
  
  if not target then
    return 
  end

  if not self:GetCaster():HasScepter() then 
    if target:TriggerSpellAbsorb(self) then
     return 
    end
  end

  target:EmitSound("Hero_Sniper.AssassinateDamage")
  if not caster:HasScepter() then
    --print(self:GetSpecialValueFor("damage"))
    local damageTable = {
      victim = target,
      attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
    }
    ApplyDamage(damageTable)
  else
    local oldLocation =  caster:GetAbsOrigin()
    caster:SetAbsOrigin(target:GetAbsOrigin())
    --SendOverheadEventMessage(caster,OVERHEAD_ALERT_CRITICAL,target,caster:GetAttackDamage() *self:GetSpecialValueFor("scepter_crit_bonus") * 0.01 ,nil)
    caster:PerformAttack(target,true,true,true,true,false, false, true)
    caster:SetAbsOrigin(oldLocation)
  end
  target:RemoveModifierByName("modifier_sniper_assassinate_target_redux")
end

modifier_sniper_assassinate_target_redux = class({})

function modifier_sniper_assassinate_target_redux:IsHidden()
  return true
end
function modifier_sniper_assassinate_target_redux:IsPurgable()
  return false
end
function modifier_sniper_assassinate_target_redux:IsDebuff()
  return true
end
function modifier_sniper_assassinate_target_redux:GetEffectName()
  return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
end
function modifier_sniper_assassinate_target_redux:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sniper_assassinate_target_redux:CheckStates()
  local state = {
    [MODIFIER_STATE_INVISIBLE] = false,
    --[MODIFIER_STATE_PROVIDES_VISION] = true,
  }
  return state
end

--[[function modifier_sniper_assassinate_target_redux:DeclareFunctions()
  local funcs = { 
    MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
  }
end
function modifier_sniper_assassinate_target_redux:GetModifierProvidesFOWVision()
  return 1
end]]

function modifier_sniper_assassinate_target_redux:OnCreated()
  self:StartIntervalThink(0.1)
end
function modifier_sniper_assassinate_target_redux:OnIntervalThink()
  if IsServer() then 
    AddFOWViewer(self:GetCaster():GetTeamNumber(),self:GetParent():GetAbsOrigin(),10,0.1,true)
  end
end

modifier_sniper_assassinate_caster_redux = class({})

function modifier_sniper_assassinate_caster_redux:IsHidden()
  return true
end
function modifier_sniper_assassinate_caster_redux:IsPurgable()
  return false
end

function modifier_sniper_assassinate_caster_redux:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ORDER,
    MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
  }
  return funcs 
end

function modifier_sniper_assassinate_caster_redux:OnOrder(keys)
  if self:GetCaster() == keys.unit and IsServer() then
    if self.storedTarget then
      for k,v in pairs(self.storedTarget) do
        v:RemoveModifierByName("modifier_sniper_assassinate_target_redux")
      end
    end
    self:GetAbility().storedTarget = nil
    self:GetCaster():RemoveModifierByName("modifier_sniper_assassinate_caster_redux")
  end
end

function modifier_sniper_assassinate_caster_redux:GetModifierPreAttack_CriticalStrike()
  if IsServer() then
    return self:GetAbility():GetSpecialValueFor("scepter_crit_bonus")
  end
end
