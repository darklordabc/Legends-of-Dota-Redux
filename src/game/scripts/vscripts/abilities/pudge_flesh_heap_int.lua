pudge_flesh_heap_int = class({})

LinkLuaModifier( "modifier_flesh_heap_int", "abilities/pudge_flesh_heap_int.lua" ,LUA_MODIFIER_MOTION_NONE )


function pudge_flesh_heap_int:GetIntrinsicModifierName()
  return "modifier_flesh_heap_int"
end

--------------------------------------------------------------------------------

--[[function pudge_flesh_heap_int:OnHeroDiedNearby( hVictim, hKiller, kv )
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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_int" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_int" , {} )
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

modifier_flesh_heap_int = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_int:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:IsPassive()
    return true
end

function modifier_flesh_heap_int:IsPurgable()
    return true
end

function modifier_flesh_heap_int:GetFleshHeapKills()
  if self.nKills == nil then
    self.nKills = 0
  end
  return self.nKills
end
 
--------------------------------------------------------------------------------

function modifier_flesh_heap_int:OnCreated( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_int")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_int_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_intelligence_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:OnRefresh( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_int")
    self:GetParent():CalculateStatBonus()
    return
  end
  self.flesh_heap_int_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_intelligence_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus()
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_flesh_heap_int:OnDeath(keys)


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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_int" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_int" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end


function modifier_flesh_heap_int:GetModifierBonusStats_Intellect()
  return self:GetStackCount() * self.flesh_heap_int_buff_amount
end
