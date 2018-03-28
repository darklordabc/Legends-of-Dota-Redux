ability_wards = class({})

LinkLuaModifier("modifier_ability_wards_observer_cooldown","abilities/ability_wards.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_wards_sentry_cooldown","abilities/ability_wards.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_wards_type","abilities/ability_wards.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_ability_wards_type_op","abilities/ability_wards.lua",LUA_MODIFIER_MOTION_NONE)

modifier_ability_wards_observer_cooldown = class({})
modifier_ability_wards_sentry_cooldown = class({})
modifier_ability_wards_type = class({})
--modifier_ability_wards_type_op = class({})

function modifier_ability_wards_type:IsPermanent() return true end
function modifier_ability_wards_type:IsHidden() return true end

function ability_wards:OnUpgrade()
  if self:GetLevel() == 1 then
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_type",{})
    modifier:SetStackCount(0)
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_observer_cooldown",{})
    modifier:SetStackCount(1)
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_sentry_cooldown",{})
    modifier:SetStackCount(1)
  end
end

function ability_wards:GetAOERadius()
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
    return self:GetSpecialValueFor("observer_ward_radius")
  else
    return self:GetSpecialValueFor("sentry_ward_radius")
  end
end

function ability_wards:GetAbilityTextureName()
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
    return "custom/ability_wards"
  else
    return "custom/ability_wards_2"
  end
end
function ability_wards:CastFilterResultLocation(vLocation)
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 and self:GetCaster():GetModifierStackCount("modifier_ability_wards_observer_cooldown",self:GetCaster()) <= 0 then
    return UF_FAIL_CUSTOM
  end
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 1 and self:GetCaster():GetModifierStackCount("modifier_ability_wards_sentry_cooldown",self:GetCaster()) <= 0 then
    return UF_FAIL_CUSTOM
  end
end

function ability_wards:CastFilterResultTarget(target)
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end

function ability_wards:GetCustomCastErrorLocation()
  if not self.sentryMode and self:GetCaster():GetModifierStackCount("modifier_ability_wards_observer_cooldown",self:GetCaster()) <= 0 then
    return "#wards_cooldown"
  end
  if self.sentryMode and self:GetCaster():GetModifierStackCount("modifier_ability_wards_sentry_cooldown",self:GetCaster()) <= 0 then
    return "#wards_cooldown"
  end
end

function ability_wards:OnSpellStart()
  if self:GetCursorTarget() then
    if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
      self:GetCaster():SetModifierStackCount("modifier_ability_wards_type",self:GetCaster(),1)
    else
      self:GetCaster():SetModifierStackCount("modifier_ability_wards_type",self:GetCaster(),0)
    end
  else
    if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
      local ward = CreateUnitByName("npc_dota_observer_wards",self:GetCursorPosition(),false,self:GetCaster(),self:GetCaster():GetPlayerOwner(),self:GetCaster():GetTeamNumber())
      ward:AddNewModifier(self:GetCaster(),self,"modifier_kill",{duration = self:GetSpecialValueFor("observer_ward_duration")})
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_buff_ward",{})
      self:GetCaster():FindModifierByName("modifier_ability_wards_observer_cooldown"):DecrementStackCount()
      ward:EmitSound("DOTA_Item.ObserverWard.Activate")
    else
      local ward =  CreateUnitByName("npc_dota_sentry_wards",self:GetCursorPosition(),false,self:GetCaster(),self:GetCaster():GetPlayerOwner(),self:GetCaster():GetTeamNumber())
      ward:AddNewModifier(self:GetCaster(),self,"modifier_kill",{duration = self:GetSpecialValueFor("sentry_ward_duration")})
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_buff_ward",{})
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_ward_true_sight",{true_sight_range=self:GetSpecialValueFor("sentry_ward_radius")})
      self:GetCaster():FindModifierByName("modifier_ability_wards_sentry_cooldown"):DecrementStackCount()
      ward:EmitSound("DOTA_Item.SentryWard.Activate")
    end
  end
end

ability_wards_op = class({})

function ability_wards_op:OnUpgrade()
  if self:GetLevel() == 1 then
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_type",{})
    modifier:SetStackCount(0)
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_observer_cooldown",{})
    modifier:SetStackCount(1)
    local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_wards_sentry_cooldown",{})
    modifier:SetStackCount(1)

  end
end

function ability_wards_op:GetAOERadius()
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
    return self:GetSpecialValueFor("observer_ward_radius")
  else
    return self:GetSpecialValueFor("sentry_ward_radius")
  end
end

function ability_wards_op:GetAbilityTextureName()
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
    return "custom/ability_wards_op"
  else
    return "custom/ability_wards_op_2"
  end
end
function ability_wards_op:CastFilterResultLocation(vLocation)
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 and self:GetCaster():GetModifierStackCount("modifier_ability_wards_observer_cooldown",self:GetCaster()) <= 0 then
    return UF_FAIL_CUSTOM
  end
  if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 1 and self:GetCaster():GetModifierStackCount("modifier_ability_wards_sentry_cooldown",self:GetCaster()) <= 0 then
    return UF_FAIL_CUSTOM
  end
end

function ability_wards_op:CastFilterResultTarget(target)
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end

function ability_wards_op:GetCustomCastErrorLocation()
  if not self.sentryMode and self:GetCaster():GetModifierStackCount("modifier_ability_wards_observer_cooldown",self:GetCaster()) <= 0 then
    return "#wards_cooldown"
  end
  if self.sentryMode and self:GetCaster():GetModifierStackCount("modifier_ability_wards_sentry_cooldown",self:GetCaster()) <= 0 then
    return "#wards_cooldown"
  end
end

function ability_wards_op:OnSpellStart()
  if self:GetCursorTarget() then
    if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
      self:GetCaster():SetModifierStackCount("modifier_ability_wards_type",self:GetCaster(),1)
    else
      self:GetCaster():SetModifierStackCount("modifier_ability_wards_type",self:GetCaster(),0)
    end
  else
    if self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) == 0 then
      local ward = CreateUnitByName("npc_dota_observer_wards",self:GetCursorPosition(),false,self:GetCaster(),self:GetCaster():GetPlayerOwner(),self:GetCaster():GetTeamNumber())
      ward:AddNewModifier(self:GetCaster(),self,"modifier_kill",{duration = self:GetSpecialValueFor("observer_ward_duration")}) 
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_buff_ward",{})
      self:GetCaster():FindModifierByName("modifier_ability_wards_observer_cooldown"):DecrementStackCount()
      ward:EmitSound("DOTA_Item.ObserverWard.Activate")
    else
      local ward =  CreateUnitByName("npc_dota_sentry_wards",self:GetCursorPosition(),false,self:GetCaster(),self:GetCaster():GetPlayerOwner(),self:GetCaster():GetTeamNumber())
      ward:AddNewModifier(self:GetCaster(),self,"modifier_kill",{duration = self:GetSpecialValueFor("sentry_ward_duration")})
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_buff_ward",{})
      ward:AddNewModifier(self:GetCaster(),self,"modifier_item_ward_true_sight",{true_sight_range=self:GetSpecialValueFor("sentry_ward_radius")})
      self:GetCaster():FindModifierByName("modifier_ability_wards_sentry_cooldown"):DecrementStackCount()
      ward:EmitSound("DOTA_Item.SentryWard.Activate")
    end
  end
end


function modifier_ability_wards_observer_cooldown:IsPermanent() return true end
function modifier_ability_wards_observer_cooldown:DestroyOnExpire() return false end
function modifier_ability_wards_observer_cooldown:IsHidden() 
  return self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) ~= 0
end

function modifier_ability_wards_observer_cooldown:GetTexture()
  return "custom/ability_wards"
end

function modifier_ability_wards_observer_cooldown:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1)
  end
end
function modifier_ability_wards_observer_cooldown:OnIntervalThink()
  if not self:GetAbility() then self:Destroy() return end
  local cooldown = math.ceil(self:GetAbility():GetSpecialValueFor("observer_ward_cooldown") * (1-self:GetCaster():GetCooldownReduction()))
  if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("observer_ward_max_stack") then
    if self:GetRemainingTime() < 0 then
      self:IncrementStackCount()
      self:SetDuration(-1,true)
      self:SetDuration(cooldown,true)
      return
    else
      if self:GetRemainingTime() > cooldown then
        local count = self:GetStackCount()
        local caster = self:GetCaster()
        local ab = self:GetAbility()
        local name = self:GetName()
        self:Destroy()
        local modifier = caster:AddNewModifier(caster,ab,name,{duration = cooldown})
        modifier:SetStackCount(count)

        return
      end
    end
  end
  
  if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("observer_ward_max_stack") then
    self:SetDuration(9999,true)
  end
end

function modifier_ability_wards_sentry_cooldown:IsPermanent() return true end
function modifier_ability_wards_sentry_cooldown:DestroyOnExpire() return false end
function modifier_ability_wards_sentry_cooldown:IsHidden() 
  return self:GetCaster():GetModifierStackCount("modifier_ability_wards_type",self:GetCaster()) ~= 1
end

function modifier_ability_wards_sentry_cooldown:GetTexture()
  return "custom/ability_wards_2"
end

function modifier_ability_wards_sentry_cooldown:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1)
  end
end
function modifier_ability_wards_sentry_cooldown:OnIntervalThink()
  if not self:GetAbility() then self:Destroy() return end
  local cooldown = math.ceil(self:GetAbility():GetSpecialValueFor("sentry_ward_cooldown") * (1-self:GetCaster():GetCooldownReduction()))
  if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("sentry_ward_max_stack") then
    if self:GetRemainingTime() < 0 then
      self:IncrementStackCount()
      self:SetDuration(-1,true)
      self:SetDuration(cooldown,true)
      return
    else
      if self:GetRemainingTime() > cooldown then
        local count = self:GetStackCount()
        local caster = self:GetCaster()
        local ab = self:GetAbility()
        local name = self:GetName()
        self:Destroy()
        local modifier = caster:AddNewModifier(caster,ab,name,{duration = cooldown})
        modifier:SetStackCount(count)

        return
      end
    end
  end
  
  if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("sentry_ward_max_stack") then
    self:SetDuration(-1,true)
    self:SetDuration(9999,true)
  end
end
  
