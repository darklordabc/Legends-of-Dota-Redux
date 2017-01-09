function CDOTA_BaseNPC_Hero:GetItemByName(item_name)
  for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
    local item = self:GetItemInSlot(i)
    if item and item:GetAbilityName() == item_name then
      return item
    end
  end
end

function CDOTA_BaseNPC_Hero:GetItemByNameFromStash(item_name)
  for i=DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
    local item = self:GetItemInSlot(i)
    if item and item:GetAbilityName() == item_name then
      return item
    end
  end
end

function CDOTA_BaseNPC_Hero:GetItemSlot(item)
  for i=0,5 do 
    if self:GetItemInSlot(i) == item then
      return i
    end
  end
end

function OnBottleUsed(keys)
    local ingame = require('ingame')
    local caster = keys.caster
    local target = keys.target
    if not target then
      target = caster
    end
    local ability = keys.ability
    local bottleName = ability:GetAbilityName()
    local bottleDuration = ability:GetSpecialValueFor("duration")

    if bottleName == "item_bottle_3" then
      local nOldSlot = caster:GetItemSlot(ability)
      caster:RemoveItem(ability)
      local ability = caster:AddItemByName("item_bottle_2")
      target:AddNewModifier(caster,ability,"modifier_bottle_regeneration",{duration = bottleDuration, health_restore = ability:GetSpecialValueFor("health_restore"), mana_restore =  ability:GetSpecialValueFor("mana_restore")})
      ability:StartCooldown(1)
      local nNewSlot = caster:GetItemSlot(ability)
      if nNewSlot ~= nOldSlot then
        caster:SwapItems(nOldSlot,nNewSlot)
      end
      
    elseif bottleName == "item_bottle_2" then
      local nOldSlot = caster:GetItemSlot(ability)
      caster:RemoveItem(ability)
      local ability = caster:AddItemByName("item_bottle_1")
      target:AddNewModifier(caster,ability,"modifier_bottle_regeneration",{duration = bottleDuration, health_restore = ability:GetSpecialValueFor("health_restore"), mana_restore =  ability:GetSpecialValueFor("mana_restore")})
      ability:StartCooldown(1)
      local nNewSlot = caster:GetItemSlot(ability)
      if nNewSlot ~= nOldSlot then
        caster:SwapItems(nOldSlot,nNewSlot)
      end
      
    elseif bottleName == "item_bottle_1" then
      local nOldSlot = caster:GetItemSlot(ability)
      caster:RemoveItem(ability)
      local ability = caster:AddItemByName("item_bottle_0")
      target:AddNewModifier(caster,ability,"modifier_bottle_regeneration",{duration = bottleDuration, health_restore = ability:GetSpecialValueFor("health_restore"), mana_restore =  ability:GetSpecialValueFor("mana_restore")})
      ability:StartCooldown(1)
      local nNewSlot = caster:GetItemSlot(ability)
      if nNewSlot ~= nOldSlot then
        caster:SwapItems(nOldSlot,nNewSlot)
      end
      
    elseif bottleName == "item_bottle_0" then
      caster:GetItemByName("item_bottle_0"):StartCooldown(1)
    elseif bottleName == "item_bottle_bounty" then
      local nOldSlot = caster:GetItemSlot(ability)
      caster:RemoveItem(caster:GetItemByName("item_bottle_bounty"))
      local ability = caster:AddItemByName("item_bottle_2")
      Ingame:UseBountyRune(caster)
      local nNewSlot = caster:GetItemSlot(ability)
      if nNewSlot ~= nOldSlot then
        caster:SwapItems(nOldSlot,nNewSlot)
      end
    else
    -- We know we got a special rune
      if bottleName ~= "item_bottle_illusion" then
        local modifierName = "modifier_rune_".. string.sub(bottleName, 13)
        local modifier =caster:AddNewModifier(caster,ability,modifierName,{duration = bottleDuration, fade_time = ability:GetSpecialValueFor("fade_time") or 0 })
      else -- Make 2 illusions
        local illusionOne = CreateUnitByName(caster:GetUnitName(),caster:GetAbsOrigin() + RandomVector(75),true,caster,caster:GetOwner(),caster:GetTeamNumber())
        local player = caster:GetPlayerID() 
        illusionOne:MakeIllusion()
        illusionOne:SetControllableByPlayer(player,true) 
        illusionOne:SetPlayerID(player)
        illusionOne:SetHealth(caster:GetHealth())
        illusionOne:SetMana(caster:GetMana())
        local incoming_damage
        if caster:IsRangedAttacker() then
          incoming_damage = ability:GetSpecialValueFor("incoming_damage_ranged")
        else
          incoming_damage = ability:GetSpecialValueFor("incoming_damage_melee")
        end
        illusionOne:AddNewModifier(caster, ability, "modifier_illusion", {duration = ability:GetSpecialValueFor("duration"), outgoing_damage = ability:GetSpecialValueFor("outgoing_damage"), incoming_damage = incoming_damage})

        local illusionTwo = CreateUnitByName(caster:GetUnitName(),caster:GetAbsOrigin() + RandomVector(75),true,caster,caster:GetOwner(),caster:GetTeamNumber())
        illusionTwo:MakeIllusion()
        illusionTwo:SetControllableByPlayer(player,true) 
        illusionTwo:SetPlayerID(player)
        illusionTwo:SetHealth(caster:GetHealth())
        illusionTwo:SetMana(caster:GetMana())
        illusionTwo:AddNewModifier(caster, ability, "modifier_illusion", {duration = ability:GetSpecialValueFor("duration"), outgoing_damage = ability:GetSpecialValueFor("outgoing_damage"), incoming_damage = incoming_damage})
      end
      local nOldSlot = caster:GetItemSlot(ability)
      caster:RemoveItem(ability)
      caster:AddItemByName("item_bottle_3")
      caster:GetItemByName("item_bottle_3"):StartCooldown(1)
      local nNewSlot = caster:GetItemSlot(ability)
      if nNewSlot ~= nOldSlot then
        caster:SwapItems(nOldSlot,nNewSlot)
      end
    end
  end

  function CheckRefillFountain(keys)
    if keys.caster:HasModifier("modifier_fountain_aura_buff") then
      keys.caster:RemoveItem(keys.ability)
      keys.caster:AddItemByName("item_bottle_3")
    end
  end
