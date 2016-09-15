--------------------------------------------------------------------------------------------------------
--
--		Hero: chen
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_chen_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_chen_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_chen_perk == nil then npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_chen_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_chen_perk == nil then modifier_npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--
--    Hero: chen
--    Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_chen_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_chen_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_chen_perk == nil then npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_chen_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_chen_perk == nil then modifier_npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsHidden()
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_chen_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if not hero.randomPassiveAbilityTable then
      hero.randomPassiveAbilityTable = {
        "ursa_fury_swipes",
        "omniknight_degen_aura",
        "slardar_bash",
        "razor_unstable_current",
        "visage_gravekeepers_cloak",
        "weaver_geminate_attack",
        "tiny_craggy_exterior",
        "antimage_mana_break",
      }
    end

    if ability:GetAbilityName() == "chen_holy_persuasion" then
      local randomAbilityNumber = RandomInt(1,#hero.randomPassiveAbilityTable)
      local randomAbilityTemp = hero.randomPassiveAbilityTable[randomAbilityNumber]                    
      target:AddAbility(randomAbilityTemp)                    
      target:FindAbilityByName(randomAbilityTemp):UpgradeAbility(true)                    
      target.extraAbility = randomAbilityTemp
    elseif ability:GetAbilityName() == "chen_test_of_faith_teleport" then
      if target:FindAbilityByName(target.extraAbility):GetLevel() < 4 then
        target:FindAbilityByName(target.extraAbility):UpgradeAbility(true)
      else
        if target:GetAbilityCount() < 4 then -- 6 seems to crash the 2nd unit
          local randomAbilityNumber = RandomInt(1,#hero.randomPassiveAbilityTable)
          local randomAbilityTemp = hero.randomPassiveAbilityTable[randomAbilityNumber]
          while target:HasAbility(randomAbilityTemp) do
            local randomAbilityNumber = RandomInt(1,#hero.randomPassiveAbilityTable)
            local randomAbilityTemp = hero.randomPassiveAbilityTable[randomAbilityNumber]
          end
          target:AddAbility(randomAbilityTemp)
          target:FindAbilityByName(randomAbilityTemp):UpgradeAbility(true)
          target.extraAbility = randomAbilityTemp
        end
      end
    end
  end
end                    


