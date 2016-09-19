--------------------------------------------------------------------------------------------------------
--
--		Hero: Wisp
--		Perk: On spells that target a position wisp targets that same spell on another position.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_wisp_perk", "abilities/hero_perks/npc_dota_hero_wisp_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_wisp_perk == nil then npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_wisp_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_wisp_perk == nil then modifier_npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    --MODIFIER_EVENT_ON_ABILITY_EXECUTED,
  }
  return funcs
end

function modifier_npc_dota_hero_wisp_perk:OnAbilityFullyCast(keys)
  if IsServer() then 
    local caster = self:GetParent()
    local ability = keys.ability
    local abilityTargetType = ability:GetBehavior()
    local abilityTargetTypeOne = abilityTargetType
    local abilityTargetTypeTwo = abilityTargetType
    if not ability:IsItem() then
    
      -- Stuff for getting the correct behaviour
      if abilityTargetTypeOne > math.pow(2, 27) then -- There is an issue with the ignore backswing behaviour, this removes that value
        abilityTargetTypeOne = abilityTargetTypeOne - math.pow(2, 27)
      end
      for i=1,30 do -- When 2 behaviours are true they are added, so we want the highest number lower than the value we got
        if abilityTargetTypeOne < math.pow(2, i) then
          abilityTargetTypeOne = math.pow(2, i)/2
          break
        end
      end

      for i=30,1,-1 do -- When 2 behaviours are true they are added, but the lowest is the one we need.
        if math.fmod(math.log(abilityTargetTypeTwo)/math.log(2),1) ~= 0 then -- Checking if the number is 2^x
          if abilityTargetTypeTwo > math.pow(2, i)  then  -- Removing any bigger number
            abilityTargetTypeTwo = abilityTargetTypeTwo - math.pow(2, i)
          end
        end 
      end

      -- Checking if the behaviour warrants a second cast
      if abilityTargetTypeOne == DOTA_ABILITY_BEHAVIOR_POINT 
        or abilityTargetTypeOne == DOTA_ABILITY_BEHAVIOR_AOE
        or abilityTargetTypeOne == DOTA_ABILITY_BEHAVIOR_DIRECTIONAL 
        or abilityTargetTypeOne == DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
        or abilityTargetTypeOne == DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT

        or abilityTargetTypeTwo == DOTA_ABILITY_BEHAVIOR_POINT 
        or abilityTargetTypeTwo == DOTA_ABILITY_BEHAVIOR_AOE
        or abilityTargetTypeTwo == DOTA_ABILITY_BEHAVIOR_DIRECTIONAL 
        or abilityTargetTypeTwo == DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
        or abilityTargetTypeTwo == DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT then


        if not self.counter then self.counter = 1 end

        if math.fmod(self.counter, 2) == 1 then --Comparing the issuer doesn't seem to work, so I'm using a counter and check whether I can divide by 2.
          
          ability:RefundManaCost()
          ability:EndCooldown()

          local abilityCastRange = ability:GetCastRange()
          local randomOffset = RandomVector(RandomInt(0,abilityCastRange)) 
          local casterPosition = caster:GetAbsOrigin()
          local targetLocation = casterPosition + randomOffset
          local order = 
          {
            UnitIndex = caster:entindex(), 
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            TargetIndex = nil,
            AbilityIndex = ability:entindex(), 
            Position = targetLocation, 
            Queue = 0
          }
          ExecuteOrderFromTable(order)

        end
      self.counter = self.counter +1
      end
    end
  end
  
end
