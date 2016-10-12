  --------------------------------------------------------------------------------------------------------
  --
  --    Hero: Chen
  --    Perk: When Chen sends creeps home to the fountain by casting Test of Faith (Teleport) they will receive an extra ability.
  --
  --------------------------------------------------------------------------------------------------------
  LinkLuaModifier( "modifier_npc_dota_hero_chen_perk", "abilities/hero_perks/npc_dota_hero_chen_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
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
      MODIFIER_EVENT_ON_ABILITY_START,
    }
    return funcs
  end

  function modifier_npc_dota_hero_chen_perk:OnAbilityStart(keys)
    if IsServer() then
      local hero = self:GetCaster()
      local target = keys.target
      local ability = keys.ability
      
          
      if ability:GetAbilityName() == "chen_test_of_faith_teleport" and target:IsCreep() then
        local boolMana = false -- To check mana costs
        local boolAllowActive = false -- To check if we should allow an active
        if not target.chenAbilityCount then target.chenAbilityCount = 0 end
        if not target.chenAbilityTable then target.chenAbilityTable = {} end

        if target:GetAbilityCount() == 1 or (target.chenAbilityCount ~= 6 and RandomInt(1,2) == 1) then -- 50% chance to get a new one
          target.chenAbilityCount = target.chenAbilityCount +1
          while boolMana == false and boolAllowActive == false do
            ::LoopAgain::
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
            end  
            
          end
        else -- Pick a random ability to upgrade
          local random = RandomInt(1,target.chenAbilityCount)
          local boolMaxedOut = false

          for i=i,6 do
            if target.chenAbilityTable[i]:GetLevel() ~= target.chenAbilityTable[i]:GetMaxLevel() then
              local boolMaxedOut = false
              break
            else
              local boolMaxedOut = true
            end
          end

          local tempAbility = target.chenAbilityTable[random]
          while tempAbility:GetLevel() >= tempAbility:GetMaxLevel() and boolMaxedOut == false do
            local random = RandomInt(1,target.chenAbilityCount)
          end
          tempAbility:UpgradeAbility(true)
        end
      end
    end
  end
    
