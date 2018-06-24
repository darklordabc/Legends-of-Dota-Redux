LinkLuaModifier("modifier_redux_tower_permanent", "items/pocket_tower_permanent.lua", LUA_MODIFIER_MOTION_NONE)

item_redux_pocket_tower_permanent = item_redux_pocket_tower_permanent or class({})

item_redux_pocket_tower_permanent_60 = item_redux_pocket_tower_permanent
item_redux_pocket_tower_permanent_120 = item_redux_pocket_tower_permanent
item_redux_pocket_tower_permanent_180 = item_redux_pocket_tower_permanent
item_redux_pocket_tower_permanent_240 = item_redux_pocket_tower_permanent
item_redux_pocket_tower_permanent_300 = item_redux_pocket_tower_permanent

function item_redux_pocket_tower_permanent:CastFilterResultLocation(location)
  if IsClient() then
    return UF_SUCCESS -- the client can't use the GridNav, but the server will correct it anyway, you can't cheat that.
  end
  if (not GridNav:IsTraversable(location)) or #FindUnitsInRadius(self:GetCaster():GetTeam(), location, nil, 144, DOTA_UNIT_TARGET_TEAM_BOTH + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false) > 0 or
    self:GetCaster():IsPositionInRange(location, 144 + self:GetCaster():GetHullRadius())
  then
    return UF_FAIL_CUSTOM
  else
    return UF_SUCCESS
  end
end
function item_redux_pocket_tower_permanent:GetCustomCastErrorLocation(location)
  return "#dota_hud_error_no_buildings_here"
end

function item_redux_pocket_tower_permanent:OnSpellStart()
  local caster = self:GetCaster()
  local location = self:GetCursorPosition()
  local building
  if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
    building = CreateUnitByName("npc_dota_goodguys_tower4", location, true, caster, caster:GetOwner(), caster:GetTeam())
  else
    building = CreateUnitByName("npc_dota_badguys_tower4", location, true, caster, caster:GetOwner(), caster:GetTeam())
    building:SetRenderColor(65, 78, 63)
  end
  building:SetOwner(caster)
  GridNav:DestroyTreesAroundPoint(location, building:GetHullRadius(), true)
  building:SetOrigin(location)
  building:RemoveModifierByName("modifier_invulnerable")
  building:AddNewModifier(caster, self, "modifier_redux_tower_permanent", {})
  building:RemoveAbility("backdoor_protection_in_base")

  -- Particle
  local dust_pfx = ParticleManager:CreateParticle("particles/dev/library/base_dust_hit_detail.vpcf", PATTACH_CUSTOMORIGIN, nil)
  ParticleManager:SetParticleControl(dust_pfx, 0, location)
  ParticleManager:ReleaseParticleIndex(dust_pfx)

  -- Sound
  building:EmitSound("Redux.PocketTower")

  Timers:CreateTimer(0.01, function()
    ResolveNPCPositions(location, 144)
  end)

  if OptionManager:GetOption('strongTowers') then
    ingame:updateStrongTowers(building)
  end
end


--------------------------------------------------------------------------

modifier_redux_tower_permanent = modifier_redux_tower_permanent or class({})

function modifier_redux_tower_permanent:IsHidden() return true end
function modifier_redux_tower_permanent:IsDebuff() return false end
function modifier_redux_tower_permanent:IsPurgable() return false end

function modifier_redux_tower_permanent:OnCreated()
  if IsServer() then
    self:StartIntervalThink(0.03)
  end
end

function modifier_redux_tower_permanent:OnIntervalThink()
  if IsServer() then
    local tower = self:GetParent()
    local enemies = FindUnitsInRadius(tower:GetTeam(), tower:GetAbsOrigin(), nil, tower:GetAttackRange() + 144, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
    if enemies[1] then
      tower:MoveToTargetToAttack(enemies[1])
    end
  end
end

function modifier_redux_tower_permanent:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH
  }
end

function modifier_redux_tower_permanent:OnDeath(keys)
  if IsServer() then
    if keys.unit == self:GetParent() then
      if keys.unit:GetTeam() == DOTA_TEAM_GOODGUYS then
        keys.unit:SetOriginalModel("models/props_structures/radiant_tower002_destruction.vmdl")
      else
        keys.unit:SetOriginalModel("models/props_structures/dire_tower002_destruction.vmdl")
      end
      keys.unit:ManageModelChanges()
    end
  end
end