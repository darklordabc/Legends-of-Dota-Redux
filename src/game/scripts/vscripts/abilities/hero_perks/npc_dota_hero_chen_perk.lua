  --------------------------------------------------------------------------------------------------------
  --
  --    Hero: Chen
  --    Perk: When Chen sends creeps home to the fountain by casting Test of Faith (Teleport) they will receive an extra ability.
  --
  --------------------------------------------------------------------------------------------------------
  LinkLuaModifier( "modifier_npc_dota_hero_chen_perk", "abilities/hero_perks/npc_dota_hero_chen_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
  --------------------------------------------------------------------------------------------------------
  if npc_dota_hero_chen_perk ~= "" then npc_dota_hero_chen_perk = class({}) end
  --------------------------------------------------------------------------------------------------------
  --    Modifier: modifier_npc_dota_hero_chen_perk        
  --------------------------------------------------------------------------------------------------------
  if modifier_npc_dota_hero_chen_perk ~= "" then modifier_npc_dota_hero_chen_perk = class({}) end
  --------------------------------------------------------------------------------------------------------
  function modifier_npc_dota_hero_chen_perk:IsPassive()
    return true
  end
  --------------------------------------------------------------------------------------------------------
  function modifier_npc_dota_hero_chen_perk:IsHidden()
    return false
  end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPurgable()
	return false
end

  function modifier_npc_dota_hero_chen_perk:RemoveOnDeath()
    return false
  end
  --------------------------------------------------------------------------------------------------------
  -- Add additional functions
  --------------------------------------------------------------------------------------------------------
  function modifier_npc_dota_hero_chen_perk:DeclareFunctions()
    local funcs = {
      MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
    return funcs
  end

  function modifier_npc_dota_hero_chen_perk:OnAbilityFullyCast(keys)
    --if IsServer() then
      local hero = self:GetCaster()
      local target = keys.target
      local ability = keys.ability
      
          
      if ability:GetAbilityName() == "chen_test_of_faith_teleport" and target:IsCreep() then
        local boolMana = false -- To check mana costs
        local boolAllowActive = false -- To check if we should allow an active
        if not target.chenAbilityCount then target.chenAbilityCount = 0 end
        if not target.chenAbilityTable then target.chenAbilityTable = {} end

        if target.chenAbilityCount == 0 or (target:GetAbilityCount() ~= 6 and RandomInt(1,2) == 1) then -- 50% chance to get a new one
          target.chenAbilityCount = target.chenAbilityCount +1
          
          while boolMana == false or boolAllowActive == false do
            ::LoopAgain::
            boolMana = false
            boolAllowActive = false
            --print("ChenPerkIFWhile")
            local randomability = GetRandomAbilityFromListForPerk("chen_creep_abilities")

            if target:HasAbility(randomability) then
              goto LoopAgain
            end 
            target.chenAbilityTable[target.chenAbilityCount] = target:AddAbility(randomability)
            target.chenAbilityTable[target.chenAbilityCount]:UpgradeAbility(true)
            
            local manaCost = target.chenAbilityTable[target.chenAbilityCount]:GetManaCost(target.chenAbilityTable[target.chenAbilityCount]:GetMaxLevel()-1) or 0
            
            if  manaCost <= target:GetMaxMana() then
              boolMana = true
            else
              target:RemoveAbility(target.chenAbilityTable[target.chenAbilityCount]:GetAbilityName())
              goto LoopAgain
            end

            if target.chenAbilityTable[target.chenAbilityCount]:IsPassive() or target:GetPlayerOwnerID() ~= -1 then 
              boolAllowActive = true
            else
              target:RemoveAbility(target.chenAbilityTable[target.chenAbilityCount]:GetAbilityName())
              --goto LoopAgain
            end  
            
          end
        else -- Pick a random ability to upgrade

         
          local boolMaxedOut = false -- Check if there is an ability to upgrade
          local tempAbilityTable = target.chenAbilityTable
          for k,v in pairs(tempAbilityTable) do
              if v:GetLevel() ~= v:GetMaxLevel() then
                boolMaxedOut = false
                break
              else
                boolMaxedOut = true
              end
          end

          
          
          if boolMaxedOut == false then
            local random = RandomInt(1,#tempAbilityTable)
            local tempAbility = tempAbilityTable[random]
            while tempAbility:GetLevel() >= tempAbility:GetMaxLevel() do
              local random = RandomInt(1,#tempAbilityTable)
              tempAbility = tempAbilityTable[random]
            end
            tempAbility:UpgradeAbility(true)
          end
        end
      end
    --end
  end
    
