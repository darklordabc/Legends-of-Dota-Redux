item_assault_consumable = class({})

function item_assault_consumable:GetIntrinsicModifierName()
  return "modifier_item_assault_consumable"
end

function item_assault_consumable:OnSpellStart()
  self:ConsumeItem(self:GetCaster())
end

function item_assault_consumable:CastFilterResultTarget(target)
  -- Check if its the caster thats targetted
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  -- Check if the ability exists/can be given
  if IsServer() then
    local name = self:GetIntrinsicModifierName()
    if not self:GetCaster():HasAbility("ability_consumable_item_container") then
      local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
      ab:SetLevel(1)
      ab:SetHidden(true)
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
    if not ab or ab[name] then
      return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
  end
  return UF_SUCCESS
end

function item_assault_consumable:GetCustomCastErrorTarget(target)
  if self:GetCaster() ~= target then
    return "#consumable_items_only_self"
  end
  local ab  = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if not ab then
    return "#consumable_items_no_available_slot"
  end
  local name = self:GetIntrinsicModifierName()
  if ab[name] then
    return "#consumable_items_already_consumed"
  end
end


function item_assault_consumable:ConsumeItem(hCaster)
  
  local name = self:GetIntrinsicModifierName()
  if not self:GetCaster():HasAbility("ability_consumable_item_container") then
    local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
    ab:SetLevel(1)
    ab:SetHidden(true)
  end
  local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if ab and not ab[name] then
    hCaster:RemoveItem(self)
    hCaster:RemoveModifierByName(name)
    local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
    ab[name] = true
  end
end

LinkLuaModifier("modifier_item_assault_consumable","abilities/items/assault.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_assault_consumable = class({})

function modifier_item_assault_consumable:GetTexture()
  return "item_assault"
end
function modifier_item_assault_consumable:IsPassive()
  return true
end
function modifier_item_assault_consumable:RemoveOnDeath()
  return false
end
function modifier_item_assault_consumable:IsPurgable()
  return false
end
function modifier_item_assault_consumable:IsPermanent()
  return true
end
function modifier_item_assault_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility().IsItem
end

function modifier_item_assault_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_assault_consumable:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("assault_aura_radius")
end
function modifier_item_assault_consumable:IsAura()
  return true
end

function modifier_item_assault_consumable:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_assault_consumable:GetAuraSearchType()
  return {DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_CREEP,DOTA_UNIT_TARGET_BUILDING}
end

function modifier_item_assault_consumable:GetModifierAura()
  return "modifier_item_assault_consumable_aura"
end

function modifier_item_assault_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end

function modifier_item_assault_consumable:GetModifierPhysicalArmorBonus()
  if not self:GetAbility() then
    self:Destroy()
  end
  return self:GetAbility():GetSpecialValueFor("assault_bonus_armor")
end

function modifier_item_assault_consumable:GetModifierAttackSpeedBonus_Constant()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("assault_bonus_attack_speed")
end

-- Create enemy aura
function modifier_item_assault_consumable:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/30)
  end
end

function modifier_item_assault_consumable:OnIntervalThink()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  local caster = self:GetCaster()
  local radius = self:GetAbility():GetSpecialValueFor("assault_aura_radius")
  local units = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_BUILDING,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
  for k,v in pairs(units) do
    if not v:HasModifier("modifier_item_assault_consumable_aura_enemies") then
      local modifier = v:AddNewModifier(caster,self:GetAbility(),"modifier_item_assault_consumable_aura_enemies",{})
      modifier:SetDuration(-1,true)
      modifier:SetDuration(0.5,false)
    else
      v:FindModifierByName("modifier_item_assault_consumable_aura_enemies"):SetDuration(-1,true)
      v:FindModifierByName("modifier_item_assault_consumable_aura_enemies"):SetDuration(0.5,false)
    end
  end
end



LinkLuaModifier("modifier_item_assault_consumable_aura","abilities/items/assault.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_assault_consumable_aura = class({})

function modifier_item_assault_consumable_aura:GetTexture()
  return "item_assault"
end

function modifier_item_assault_consumable_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end 

function modifier_item_assault_consumable_aura:GetModifierPhysicalArmorBonus()
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("assault_aura_armor") then self:Destroy() return end
  if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
    if not self:GetParent():IsBuilding() then
      return self:GetAbility():GetSpecialValueFor("assault_aura_armor")
    else
      return 0
    end
  else
    return -self:GetAbility():GetSpecialValueFor("assault_aura_armor")
  end
end

function modifier_item_assault_consumable_aura:GetModifierAttackSpeedBonus_Constant()
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("assault_aura_attack_speed") then self:Destroy() return end
  if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
    if not self:GetParent():IsBuilding() then
      return self:GetAbility():GetSpecialValueFor("assault_aura_attack_speed")
    else
      return 0
    end
  else
    return 0
  end
end

function modifier_item_assault_consumable_aura:IsDebuff()
  return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()
end

function modifier_item_assault_consumable_aura:IsHidden()
  return self:GetCaster() == self:GetParent()
end

LinkLuaModifier("modifier_item_assault_consumable_aura_enemies","abilities/items/assault.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_assault_consumable_aura_enemies = class({})

function modifier_item_assault_consumable_aura_enemies:GetTexture()
  return "item_assault"
end

function modifier_item_assault_consumable_aura_enemies:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
  return funcs
end 

function modifier_item_assault_consumable_aura_enemies:GetModifierPhysicalArmorBonus()
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("assault_aura_armor") then self:Destroy() return end
  return -self:GetAbility():GetSpecialValueFor("assault_aura_armor")
end



function modifier_item_assault_consumable_aura_enemies:IsDebuff()
  return true
end
function modifier_item_assault_consumable_aura_enemies:OnCreated()
  self:StartIntervalThink(1/30)
end

function modifier_item_assault_consumable_aura_enemies:OnIntervalThink()
  if IsServer() then
    if self:GetParent():CanEntityBeSeenByMyTeam(self:GetCaster()) then
      self:SetStackCount(0)
    else
      self:SetStackCount(1)
    end
  end
end
function modifier_item_assault_consumable_aura_enemies:IsHidden()
  return self:GetStackCount() == 1
end






-- Look for line 35 for the special values
-- Search for self.parentName if you are making an aura, give it the name of the parent modifier
-- Also change texture, and obviously properties
--[[
item_assault_consumable = class({})

function item_assault_consumable:GetIntrinsicModifierName()
  return "modifier_item_assault_consumable"
end

function item_assault_consumable:OnSpellStart()

  if self:GetCursorTarget() == self:GetCaster() then
    self:ConsumeItem(self:GetCaster())
  end
end


function item_assault_consumable:ConsumeItem(hCaster)
  
  local name = self:GetIntrinsicModifierName()
  local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
  ab:SetHidden(true)
  hCaster:RemoveItem(self)
  hCaster:RemoveModifierByName(name)
  local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
end

LinkLuaModifier("modifier_item_assault_consumable","abilities/items/assault.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_assault_consumable = class({})

function modifier_item_assault_consumable:OnCreated()
  -- Check if the ability is an item, if so use those values
  if self:GetAbility().IsDisassemblable then


    -----------------------------------------------------------------------
    --Change values here, search those values and change them in the document (ctrl+h)
    -----------------------------------------------------------------------
    self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.aura_armor = self:GetAbility():GetSpecialValueFor("aura_armor")
    self.aura_attack_speed = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
    -- Store in the container ability to use when consumed
    if IsServer() then
      if not self:GetCaster():HasAbility("ability_consumable_item_container") then
        local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
        if not ab[self:GetName()] then ab[self:GetName()] = {} end

        -----------------------------------------------------------------------
        --Change values here
        -----------------------------------------------------------------------
        ab[self:GetName()].aura_radius = self.aura_radius
        ab[self:GetName()].bonus_armor = self.bonus_armor
        ab[self:GetName()].bonus_attack_speed = self.bonus_attack_speed
        ab[self:GetName()].aura_armor = self.aura_armor
        ab[self:GetName()].aura_attack_speed = self.aura_attack_speed

        ab:SetHidden(true)
      end
    end

  else -- The container ability is providing, sync to client
    -- Doesn't get synced instantly
    self:StartIntervalThink(1/2)
  end
end

function modifier_item_assault_consumable:GetTexture()
  return "item_assault"
end
function modifier_item_assault_consumable:OnIntervalThink()
  -- Uneven thinks are setting stack, uneven are for getting
  if not self.think then 
    self.think = 1
  else
    self.think = self.think + 1
  end

  -- Setting stacks to sync them with client
  -- Aura radius
  if self.think == 1 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[self:GetName()].aura_radius)
    end
  elseif self.think == 2 then
    self.aura_radius = self:GetStackCount()
  ---------------------------------------------------------------
  elseif self.think == 3 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[self:GetName()].bonus_armor)
    end
  elseif self.think == 4 then
    self.bonus_armor = self:GetStackCount()
  ---------------------------------------------------------------
  elseif self.think == 5 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[self:GetName()].bonus_attack_speed)
    end
  elseif self.think == 6 then
    self.bonus_attack_speed = self:GetStackCount()
  ---------------------------------------------------------------
  elseif self.think == 7 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[self:GetName()].aura_attack_speed)
    end
  elseif self.think == 8 then
    self.aura_attack_speed = self:GetStackCount()
  ---------------------------------------------------------------
  elseif self.think == 9 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[self:GetName()].aura_armor)
    end
  elseif self.think == 10 then
    self.aura_armor = self:GetStackCount()  
  ---------------------------------------------------------------
  else 
    if IsServer() then
      self:SetStackCount(0)
    end
    self:StartIntervalThink(-1)
    self.think = nil
  end
end


function modifier_item_assault_consumable:IsPassive()
  return true
end
function modifier_item_assault_consumable:RemoveOnDeath()
  return false
end
function modifier_item_assault_consumable:IsPurgable()
  return false
end
function modifier_item_assault_consumable:IsPermanent()
  return true
end

function modifier_item_assault_consumable:GetAuraRadius()
  return self.aura_radius
end
function modifier_item_assault_consumable:IsAura()
  return true
end

function modifier_item_assault_consumable:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_assault_consumable:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO
end

function modifier_item_assault_consumable:GetModifierAura()
  return "modifier_item_assault_consumable_aura"
end

function modifier_item_assault_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end 

function modifier_item_assault_consumable:GetModifierPhysicalArmorBonus()
  return self.bonus_armor
end
function modifier_item_assault_consumable:GetModifierAttackSpeedBonus_Constant()
  return self.bonus_attack_speed
end

LinkLuaModifier("modifier_item_assault_consumable_aura","abilities/items/assault.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_assault_consumable_aura = class({})
function modifier_item_assault_consumable_aura:GetTexture()
  return "item_assault"
end

function modifier_item_assault_consumable_aura:OnCreated()
  -- Check if the ability is an item, if so use those values
  if self:GetAbility().IsDisassemblable then
    -----------------------------------------------------------------------
    --Change values here
    -----------------------------------------------------------------------
    self.aura_armor = self:GetAbility():GetSpecialValueFor("aura_armor")
    self.aura_attack_speed = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
  else 
    self.parentName = "modifier_item_assault_consumable"
    self:StartIntervalThink(1/2)
  end
end

function modifier_item_assault_consumable_aura:OnIntervalThink()
  local parentName = self.parentName
  -- Uneven thinks are setting stack, uneven are for getting
  if not self.think then 
    self.think = 1
  else
    self.think = self.think + 1
  end
  -- Setting stacks to sync them with client
  if self.think == 1 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[parentName].aura_attack_speed)
    end
  elseif self.think == 2 then
    self.aura_attack_speed = self:GetStackCount()
  ---------------------------------------------------------------
  elseif self.think == 3 then
    if IsServer() then
      local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
      self:SetStackCount(ab[parentName].aura_armor)
    end
  elseif self.think == 4 then
    self.aura_armor = self:GetStackCount()
  ---------------------------------------------------------------
  else 
    if IsServer() then
      self:SetStackCount(0)
    end
    self:StartIntervalThink(-1)
    self.think = nil
  end
end

function modifier_item_assault_consumable_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end 

function modifier_item_assault_consumable_aura:GetModifierPhysicalArmorBonus()
  if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
    return self.aura_armor
  else
    return -self.aura_armor
  end
end

function modifier_item_assault_consumable_aura:GetModifierAttackSpeedBonus_Constant()
  if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
    return self.aura_attack_speed
  else
    return 0
  end
end


function modifier_item_assault_consumable_aura:IsDebuff()
  return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()
end

function modifier_item_assault_consumable_aura:IsHidden()
  if IsServer() and (self:GetStackCount == 0 or self:GetStackCount == 1)  then
    if self:GetCaster():CanEntityBeSeenByMyTeam(self:GetParent()) then
      self:SetStackCount(0)
    else
      self:SetStackCount(1)
    end
  end
  return not self:GetStackCount() == 0
end
]]
