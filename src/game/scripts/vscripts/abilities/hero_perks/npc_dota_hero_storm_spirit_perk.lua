--------------------------------------------------------------------------------------------------------
--
--    Hero: Storm Spirit
--    Perk: Restores mana when Storm Spirit travels at high speeds. 
--    Function: Compares position every 0.1 second between the previous position, after the initial 50 units the unit will get its unit moved/10 mana
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_storm_spirit_perk", "abilities/hero_perks/npc_dota_hero_storm_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
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
  if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_storm_spirit_perk:OnIntervalThink()
  local manaGiven = 10
  local maxRange = 4000
  local startPenalty = 50

  if IsServer() then
    local currTime = GameRules:GetGameTime()
    if not self:GetCaster().position then self:GetCaster().position = {} end
    if not self:GetCaster().position[(math.floor(currTime*10)/10)-0.1] then self:GetCaster().position[(math.floor(currTime*10)/10)-0.1] = self:GetCaster():GetAbsOrigin() end
    
    self:GetCaster().position[math.floor(currTime*10)/10] = self:GetCaster():GetAbsOrigin()
    --print("OldPosition")
    --print(self:GetCaster().position[(math.floor(currTime*10)/10)-0.1])
    --print("NewPosition")
    --print(self:GetCaster():GetAbsOrigin())
    if (self:GetCaster():GetAbsOrigin() - self:GetCaster().position[(math.floor(currTime*10)/10)-0.1]):Length2D() > maxRange then
      self.distanceMoved = 0
    else
      self.distanceMoved =  ((self:GetCaster():GetAbsOrigin() - self:GetCaster().position[(math.floor(currTime*10)/10)-0.1]):Length2D() -startPenalty)
    end

    if self.distanceMoved < 0 then
      self.distanceMoved = 0
    end
    self:GetCaster():GiveMana(self.distanceMoved/manaGiven)

    --print(self.distanceMoved.." "..(self.distanceMoved/manaGiven))
    for t, pos in pairs(self:GetCaster().position) do
      if (currTime-t) > 1 then
        self:GetCaster().position[t] = nil
      else
        break
      end
    end
  end
end


