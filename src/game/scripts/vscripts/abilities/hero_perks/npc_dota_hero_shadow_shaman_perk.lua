--------------------------------------------------------------------------------------------------------
--
--    Hero: Shadow Shaman
--    Perk: Casting targeted spells have 5% chance of hexing the target.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shadow_shaman_perk", "abilities/hero_perks/npc_dota_hero_shadow_shaman_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shadow_shaman_perk ~= "" then npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_shadow_shaman_perk
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shadow_shaman_perk ~= "" then modifier_npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:OnCreated()
  if IsServer() then
--    local cooldownPercentReduction = 20
    local hexChance = 5
--    self.cooldownReduction = 1 - (cooldownPercentReduction / 100)
    self.hexChance = 1 - (hexChance / 100)
    self.aoeEnabled = false;
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_shadow_shaman_perk:DeclareFunctions()
  local funcs = {
  --  MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    MODIFIER_EVENT_ON_ABILITY_EXECUTED
  }
  return funcs
end
function modifier_npc_dota_hero_shadow_shaman_perk:OnAbilityExecuted(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability

    if hero == keys.unit and ability and not ability:HasAbilityFlag("hex") then
      if self.aoeEnabled and bit.band(ability:GetBehavior(),DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_AOE then
        local aoe_flags = DOTA_UNIT_TARGET_ALL
        local radius = 150
        if ability.GetAOERadius then radius = ability:GetAOERadius() end
        local teamNumber = hero:GetTeamNumber()
      --  local position = keys.point
        local tTargets = FindUnitsInRadius(teamNumber, ability:GetCursorPosition(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, aoe_flags, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,false)
        if #tTargets > 0 then
          for i = 1, #tTargets do
            self:HexTarget(tTargets[i],ability)
          end
        end
      elseif target and target:GetTeamNumber() ~= hero:GetTeamNumber() and math.random() < self.hexChance then
        target:AddNewModifier(hero, ability, "modifier_shadow_shaman_voodoo", {duration = 3})
      end
      --[[

      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
      ]]--

    end
  end
end

function modifier_npc_dota_hero_shadow_shaman_perk:HexTarget(target,ability)
  if IsServer() then
    target:AddNewModifier(self:GetParent(), ability, "modifier_shadow_shaman_voodoo", {duration = 3})
  end
end
--[[
function modifier_npc_dota_hero_shadow_shaman_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("hex") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
]]--
