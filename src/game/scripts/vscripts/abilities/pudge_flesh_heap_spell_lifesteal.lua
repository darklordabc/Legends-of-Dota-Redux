pudge_flesh_heap_spell_lifesteal = class({})

LinkLuaModifier( "modifier_flesh_heap_spell_lifesteal", "abilities/pudge_flesh_heap_spell_lifesteal.lua" ,LUA_MODIFIER_MOTION_NONE )


function pudge_flesh_heap_spell_lifesteal:GetIntrinsicModifierName()
  return "modifier_flesh_heap_spell_lifesteal"
end

--------------------------------------------------------------------------------

--[[function pudge_flesh_heap_spell_lifesteal:OnHeroDiedNearby( hVictim, hKiller, kv )
  if hVictim == nil or hKiller == nil then
    return  
  end
  if hVictim:IsIllusion() then
    return
  end

  if hVictim:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():IsAlive() then
    self.fleshHeapRange = self:GetLevelSpecialValueFor( "flesh_heap_range", 0 )
    local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
    local flDistance = vToCaster:Length2D() - (self:GetCaster():GetCollisionPadding() + hVictim:GetCollisionPadding())
    if hKiller == self:GetCaster() or self.fleshHeapRange >= flDistance then
      if self.nKills == nil then
        self.nKills = 0
      end

      self.nKills = self.nKills + 1

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_spell_lifesteal" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_spell_lifesteal" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end
]]
--------------------------------------------------------------------------------



--Taken from the spelllibrary, credits go to valve

modifier_flesh_heap_spell_lifesteal = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_flesh_heap_spell_lifesteal:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:IsPassive()
    return true
end

function modifier_flesh_heap_spell_lifesteal:IsPurgable()
    return true
end

function modifier_flesh_heap_spell_lifesteal:GetFleshHeapKills()
  if self.nKills == nil then
    self.nKills = 0
  end
  return self.nKills
end
 
--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:OnCreated( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_spell_lifesteal")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_value_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_value_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:OnRefresh( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_spell_lifesteal")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_value_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_value_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_lifesteal:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_flesh_heap_spell_lifesteal:OnDeath(keys)


  if not keys.unit or not keys.attacker then 
    return 
  end

  if not keys.unit:IsRealHero() then
    return 
  end

  if keys.unit:IsTempestDouble() then
    return
  end

  if keys.unit:IsReincarnating() then
    return
  end

  if not IsServer() then 
    return 
  end
  -----------------------------------------------------------------------------
  local hKiller = keys.attacker:GetPlayerOwner()
  local hVictim = keys.unit

  if self:GetCaster():GetTeamNumber() ~= hVictim:GetTeamNumber() then
    self.fleshHeapRange = self:GetAbility():GetSpecialValueFor( "flesh_heap_range")
    local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
    local flDistance = vToCaster:Length2D() - (self:GetCaster():GetCollisionPadding() + hVictim:GetCollisionPadding())
    if hKiller == self:GetCaster():GetPlayerOwner() or self.fleshHeapRange >= flDistance then
      if self.nKills == nil then
        self.nKills = 0
      end

      self.nKills = self.nKills + 1

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_spell_lifesteal" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_spell_lifesteal" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end


function modifier_flesh_heap_spell_lifesteal:GetModifierTotalDamageOutgoing_Percentage(keys)
  local attacker = keys.attacker -- Unit dealing damage
  local target = keys.target  -- Unit Taking Damage
  local ability = keys.inflictor -- The ability if exists
  local damage = keys.damage
  if not attacker or not ability or ability:GetLevel() == 0 then 
    return  0
  end

  if keys.inflictor:GetAbilityName() == "item_blademail" then return 0 end

  if IsServer() and attacker == self:GetParent() then
    local healFactor = self:GetStackCount() * self.flesh_heap_value_buff_amount * 0.01
    if not keys.target:IsHero() then
      healFactor = healFactor/5
    end
    local heal = healFactor * keys.damage
    self:GetCaster():Heal(heal,self:GetAbility())
    ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
  end
  return 0
end

