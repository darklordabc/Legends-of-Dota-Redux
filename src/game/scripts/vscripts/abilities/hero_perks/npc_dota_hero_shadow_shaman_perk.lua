--------------------------------------------------------------------------------------------------------
--
--    Hero: Shadow Shaman
--    Perk: When targeted by a spell, Hex the caster for 3 seconds. Has 60 second cooldown.
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
    self.cooldownTime = 40
    self.hexDuration = 3

    self.cooldownReady = true
  end
  return true
end

function modifier_npc_dota_hero_shadow_shaman_perk:DestroyOnExpire ()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_shadow_shaman_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_ABSORB_SPELL
  }
  return funcs
end

function modifier_npc_dota_hero_shadow_shaman_perk:GetAbsorbSpell(keys)
  if IsServer() then
    if self.cooldownReady and keys.ability:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
      self:HexCaster(keys.ability:GetCaster(),keys.ability)
    end
  end
  return 0
end

function modifier_npc_dota_hero_shadow_shaman_perk:HexCaster (target,ability)
  target:AddNewModifier(self:GetParent(),ability,"modifier_shadow_shaman_voodoo",{duration = self.hexDuration})
  self:SetDuration(self.cooldownTime, true)
  self:StartIntervalThink(self.cooldownTime)
  self.cooldownReady = false
end

function modifier_npc_dota_hero_shadow_shaman_perk:OnIntervalThink ()
  if IsServer() then
    self.cooldownReady = true
    self:SetDuration(-1,true)
    self:StartIntervalThink(-1)
  end
end
