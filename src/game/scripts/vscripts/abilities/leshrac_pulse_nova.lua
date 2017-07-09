leshrac_pulse_nova_redux = class({})
modifier_leshrac_pulse_nova_redux = class({})
modifier_leshrac_pulse_nova_lighting_redux = class({})
LinkLuaModifier("modifier_leshrac_pulse_nova_redux","abilities/leshrac_pulse_nova",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leshrac_pulse_nova_lighting_redux","abilities/leshrac_pulse_nova",LUA_MODIFIER_MOTION_NONE)

function leshrac_pulse_nova_redux:OnToggle()
  -- Determine if the toggle is on or off and act on it
  if self:GetToggleState() then
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_leshrac_pulse_nova_redux",{})
    EmitSoundOn("Hero_Leshrac.Pulse_Nova", self:GetCaster())
    if self:GetCaster():HasAbility("leshrac_lightning_storm") and self:GetCaster():HasScepter() then
      self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_leshrac_pulse_nova_lighting_redux",{})
    end
  else
    StopSoundOn("Hero_Leshrac.Pulse_Nova", self:GetCaster())
    self:GetCaster():RemoveModifierByName("modifier_leshrac_pulse_nova_redux")
    self:GetCaster():RemoveModifierByName("modifier_leshrac_pulse_nova_lighting_redux")
  end
end

function modifier_leshrac_pulse_nova_lighting_redux:IsPurgable() return false end

function modifier_leshrac_pulse_nova_lighting_redux:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    StoreSpecialKeyValues(self,caster:FindAbilityByName("leshrac_lightning_storm"),"leshrac_lightning_storm")
    self:StartIntervalThink(self.interval_scepter)
  end
end

function modifier_leshrac_pulse_nova_lighting_redux:OnIntervalThink()
  local caster = self:GetCaster()
  local ability = caster:FindAbilityByName("leshrac_lightning_storm")
  local radius = self.radius_scepter

  local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,self.radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
  if units and #units >= 1 then
    caster:SetCursorCastTarget(units[1])
    ability:OnSpellStart()
  end
end

function modifier_leshrac_pulse_nova_redux:IsPurgable() return false end

function modifier_leshrac_pulse_nova_redux:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    StoreSpecialKeyValues(self,ability,"leshrac_pulse_nova")
    self:StartIntervalThink(1)
    self:OnIntervalThink()

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle,0,self:GetCaster(),PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),false)
    ParticleManager:SetParticleControlEnt(self.particle,1,self:GetCaster(),PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(self.radius,0,0),false)
  end
end
function modifier_leshrac_pulse_nova_redux:OnDestroy()
  if IsServer() then
    ParticleManager:DestroyParticle(self.particle,true)
    ParticleManager:ReleaseParticleIndex(self.particle)
  end
end

function modifier_leshrac_pulse_nova_redux:OnIntervalThink()
  local ability = self:GetAbility()
  local caster = self:GetCaster()

  if not caster:IsAlive() then
    ability:ToggleAbility()
    return 
  end

  caster:SpendMana(self.mana_cost_per_second,ability)
  local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,self.radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
  for _,unit in pairs(units) do
    local damageTable = 
    {
      victim = unit,
      attacker = caster,
      damage = self.damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = ability,
    }
 
    ApplyDamage(damageTable)

    EmitSoundOn("Hero_Leshrac.Pulse_Nova_Strike", caster)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
    ParticleManager:ReleaseParticleIndex(particle)
  end
  -- Check if the caster has mana
  if caster:GetMana() < self.mana_cost_per_second then
    ability:ToggleAbility()
    return
  end
end

