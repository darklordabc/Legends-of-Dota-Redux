LinkLuaModifier("modifier_redux_tower", "items/pocket_tower.lua", LUA_MODIFIER_MOTION_NONE)

item_redux_pocket_tower = item_redux_pocket_tower or class({})

function item_redux_pocket_tower:CastFilterResultLocation(location)
  if IsClient() then
    return UF_SUCCESS -- the client can't use the GridNav, but the server will correct it anyway, you can't cheat that.
  end
  if (not GridNav:IsTraversable(location)) or #FindUnitsInRadius(DOTA_TEAM_NEUTRALS, location, nil, 144, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false) > 0 or
    self:GetCaster():IsPositionInRange(location, 144 + self:GetCaster():GetHullRadius())
  then
    return UF_FAIL_CUSTOM
  else
    return UF_SUCCESS
  end
end
function item_redux_pocket_tower:GetCustomCastErrorLocation(location)
  return "#dota_hud_error_no_buildings_here"
end

function item_redux_pocket_tower:OnSpellStart()
  local caster = self:GetCaster()
  local location = self:GetCursorPosition()
  local building
  if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
    building = CreateUnitByName("npc_dota_goodguys_tower4", location, true, caster, caster:GetOwner(), caster:GetTeam())
  else
    building = CreateUnitByName("npc_dota_badguys_tower4", location, true, caster, caster:GetOwner(), caster:GetTeam())
  end
  building:SetOwner(caster)
  GridNav:DestroyTreesAroundPoint(location, building:GetHullRadius(), true)
  building:SetOrigin(location)
  building:RemoveModifierByName("modifier_invulnerable")
  building:AddNewModifier(caster, self, "modifier_redux_tower", {})
  building:RemoveAbility("backdoor_protection_in_base")
  local charges = self:GetCurrentCharges() - 1
  if charges < 1 then
    caster:RemoveItem(self)
  else
    self:SetCurrentCharges(charges)
  end
end


--------------------------------------------------------------------------

modifier_redux_tower = modifier_redux_tower or class({})

function modifier_redux_tower:IsHidden() return true end
function modifier_redux_tower:IsDebuff() return false end
function modifier_redux_tower:IsPurgable() return false end

function modifier_redux_tower:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH
  }
end

function modifier_redux_tower:OnDeath(keys)
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