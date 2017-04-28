pudge_flesh_heap_spell_amp = class({})

LinkLuaModifier( "modifier_flesh_heap_spell_amp", "abilities/pudge_flesh_heap_spell_amp.lua" ,LUA_MODIFIER_MOTION_NONE )


function pudge_flesh_heap_spell_amp:GetIntrinsicModifierName()
  return "modifier_flesh_heap_spell_amp"
end

--------------------------------------------------------------------------------

--[[function pudge_flesh_heap_spell_amp:OnHeroDiedNearby( hVictim, hKiller, kv )
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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_spell_amp" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_spell_amp" , {} )
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

modifier_flesh_heap_spell_amp = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_flesh_heap_spell_amp:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:IsPassive()
    return true
end

function modifier_flesh_heap_spell_amp:IsPurgable()
    return true
end

function modifier_flesh_heap_spell_amp:GetFleshHeapKills()
  if self.nKills == nil then
    self.nKills = 0
  end
  return self.nKills
end
 
--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:OnCreated( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_spell_amp")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_spell_amp_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_spell_amp_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:OnRefresh( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_spell_amp")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_spell_amp_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_spell_amp_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_spell_amp:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_flesh_heap_spell_amp:OnDeath(keys)


  if not keys.unit or not keys.attacker then 
    return 
  end

  if not keys.unit:IsRealHero() then
    return 
  end

  if not IsServer() then 
    return 
  end
  -----------------------------------------------------------------------------
  local hKiller = keys.attacker
  local hVictim = keys.unit


  if self:GetCaster():GetTeamNumber() ~= hVictim:GetTeamNumber() then
    self.fleshHeapRange = self:GetAbility():GetSpecialValueFor( "flesh_heap_range")
    local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
    local flDistance = vToCaster:Length2D() - (self:GetCaster():GetCollisionPadding() + hVictim:GetCollisionPadding())
    
    if hKiller == self:GetCaster() or self.fleshHeapRange >= flDistance then
      if self.nKills == nil then
        self.nKills = 0
      end

      self.nKills = self.nKills + 1

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_spell_amp" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_spell_amp" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end


function modifier_flesh_heap_spell_amp:GetModifierTotalDamageOutgoing_Percentage(keys)
  local attacker = keys.attacker -- Unit dealing damage
  local target = keys.target  -- Unit Taking Damage
  local ability = keys.inflictor -- The ability if exists
  local damage = keys.damage
  if not attacker or not ability or ability:GetLevel() == 0 then 
    return  0
  end

  if IsServer() and attacker == self:GetParent() then
    if damage > 100 and self:GetAbility():GetLevel() > 0 then
      local displayNumber = self:GetStackCount() * self.flesh_heap_spell_amp_buff_amount * damage * 0.01
      SendOverheadEventMessage(nil,4, attacker, displayNumber, nil)
    end
    return self:GetStackCount() * self.flesh_heap_spell_amp_buff_amount
  end
end

