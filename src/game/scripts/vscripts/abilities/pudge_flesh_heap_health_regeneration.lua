pudge_flesh_heap_health_regeneration = class({})

LinkLuaModifier("modifier_flesh_heap_health_regeneration", "abilities/pudge_flesh_heap_health_regeneration.lua" ,LUA_MODIFIER_MOTION_NONE )


function pudge_flesh_heap_health_regeneration:GetIntrinsicModifierName()
  return "modifier_flesh_heap_health_regeneration"
end

modifier_flesh_heap_health_regeneration = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_health_regeneration:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_health_regeneration:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_flesh_heap_health_regeneration:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_health_regeneration:IsPassive()
    return true
end

function modifier_flesh_heap_health_regeneration:IsPurgable()
    return false
end

function modifier_flesh_heap_health_regeneration:GetFleshHeapKills()
  if self.nKills == nil then
    self.nKills = 0
  end
  return self.nKills
end
 
--------------------------------------------------------------------------------

function modifier_flesh_heap_health_regeneration:OnCreated( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_health_regeneration")
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

function modifier_flesh_heap_health_regeneration:OnRefresh( kv )
  if not self:GetAbility() then
    self:GetParent():RemoveModifierByName("modifier_flesh_heap_health_regeneration")
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

function modifier_flesh_heap_health_regeneration:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_flesh_heap_health_regeneration:OnDeath(keys)


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

      local hBuff = self:GetCaster():FindModifierByName( "modifier_flesh_heap_health_regeneration" )
      if hBuff ~= nil then
        hBuff:SetStackCount( self.nKills )
        self:GetCaster():CalculateStatBonus()
      else
        self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_flesh_heap_health_regeneration" , {} )
      end

      local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
      ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
  end
end

function modifier_flesh_heap_health_regeneration:GetModifierConstantHealthRegen()
  return self.flesh_heap_value_buff_amount * self:GetStackCount()
end


