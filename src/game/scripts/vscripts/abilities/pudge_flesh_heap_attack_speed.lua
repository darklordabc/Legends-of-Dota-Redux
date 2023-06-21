pudge_flesh_heap_attack_speed = class({})

LinkLuaModifier( "modifier_flesh_heap_attack_speed", "abilities/pudge_flesh_heap_attack_speed.lua" ,LUA_MODIFIER_MOTION_NONE )


function pudge_flesh_heap_attack_speed:GetIntrinsicModifierName()
  return "modifier_flesh_heap_attack_speed"
end

--------------------------------------------------------------------------------

function pudge_flesh_heap_attack_speed:OnHeroDiedNearby( hVictim, hKiller, kv )
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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_attack_speed" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus(true)
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_attack_speed" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end
--------------------------------------------------------------------------------



--Taken from the spelllibrary, credits go to valve

modifier_flesh_heap_attack_speed = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_flesh_heap_attack_speed:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:IsPassive()
    return true
end

function modifier_flesh_heap_attack_speed:IsPurgable()
    return true
end

function modifier_flesh_heap_attack_speed:GetFleshHeapKills()
  if self.nKills == nil then
    self.nKills = 0
  end
  return self.nKills
end
 
--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:OnCreated( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_attack_speed")
    self:GetParent():CalculateStatBonus(true)
    return
  end
  self.flesh_heap_attack_speed_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_attack_speed_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus(true)
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:OnRefresh( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_attack_speed")
    self:GetParent():CalculateStatBonus(true)
    return
  end
  self.flesh_heap_attack_speed_buff_amount = self:GetAbility():GetSpecialValueFor( "flesh_heap_attack_speed_buff_amount" ) or 0
  if IsServer() then
    self:SetStackCount( self:GetFleshHeapKills() )
    self:GetParent():CalculateStatBonus(true)
  end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_attack_speed:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_ATTACK_SPEED_BONUS,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_flesh_heap_attack_speed:OnDeath(keys)


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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_attack_speed" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus(true)
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_attack_speed" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end



function modifier_flesh_heap_attack_speed:GetModifierAttackSpeedBonus()
  return self:GetStackCount() * self.flesh_heap_attack_speed_buff_amount
end
