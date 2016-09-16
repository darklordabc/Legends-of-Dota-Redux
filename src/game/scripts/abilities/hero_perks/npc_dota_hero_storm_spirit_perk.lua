--------------------------------------------------------------------------------------------------------
--
--    Hero: storm
--    Perk: Gives 1 mana everytime the OnUnitMoved event triggers
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_storm_spirit_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_storm_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_storm_spirit_perk == nil then npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_storm_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_storm_spirit_perk == nil then modifier_npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsHidden()
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:OnCreated()
  self:StartIntervalThink(1)
end

function modifier_npc_dota_hero_storm_spirit_perk:OnIntervalThink()
  local manaGiven = (1/25)
  local maxRange = 3000

  if IsServer() then
    local currTime = GameRules:GetGameTime()
    if not self:GetCaster().position then self:GetCaster().position = {} end
    if not self:GetCaster().position[math.floor(currTime)-1] then self:GetCaster().position[math.floor(currTime)-1] = self:GetCaster():GetAbsOrigin() end
    self:GetCaster().position[math.floor(currTime)] = self:GetCaster():GetAbsOrigin()

    if (self:GetCaster().position[math.floor(currTime)] - self:GetCaster().position[math.floor(currTime)-1]):Length2D() > maxRange then
      self.distanceMoved = 0
    else
      self.distanceMoved =  (self:GetCaster().position[math.floor(currTime)] - self:GetCaster().position[math.floor(currTime)-1]):Length2D()
    end
    self:GetCaster():GiveMana(self.distanceMoved/manaGiven)
    for t, pos in pairs(self:GetCaster().position) do
      if (currTime-t) > 1 then
        self:GetCaster().position[t] = nil
      else
        break
      end
    end
  end
end


