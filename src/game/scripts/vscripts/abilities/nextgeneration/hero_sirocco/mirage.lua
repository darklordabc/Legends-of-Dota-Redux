function mirage( keys )
  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target
  local unit_name = caster:GetUnitName()
  local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)
  local outgoingDamage = ability:GetLevelSpecialValueFor("illusion_dealt", ability:GetLevel()-1)
  local incomingDamage = ability:GetLevelSpecialValueFor("illusion_taken", ability:GetLevel()-1)
  local position = caster:GetAbsOrigin()
  local modifier_illusion_destroy = keys.modifier_illusion_destroy

  local HPMax = caster:GetMaxHealth()
  local HPCur = caster:GetHealth()
  local Mana = caster:GetMana()

  local illusion = CreateUnitByName(unit_name, position, true, caster, nil, caster:GetTeamNumber())
  illusion:SetPlayerID(caster:GetPlayerID())
  illusion:SetOwner(caster)

  local casterLevel = caster:GetLevel()
  for i=1,casterLevel-1 do
   illusion:HeroLevelUp(false)
  end

  illusion:SetAbilityPoints(0)
  for abilitySlot=0,15 do
    local ability = caster:GetAbilityByIndex(abilitySlot)
    if ability ~= nil then 
      local abilityLevel = ability:GetLevel()
      local abilityName = ability:GetAbilityName()
      local illusionAbility = illusion:FindAbilityByName(abilityName)
      if illusionAbility then
        illusionAbility:SetLevel(abilityLevel)
      end
    end
  end

  for itemSlot=0,5 do
    local item = caster:GetItemInSlot(itemSlot)
    if item ~= nil then
      local itemName = item:GetName()
      local newItem = CreateItem(itemName, illusion, illusion)
      illusion:AddItem(newItem)
    end
  end

  illusion:SetPlayerID(caster:GetPlayerID())
  illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

  ProjectileManager:ProjectileDodge(caster)

  illusion:SetMaxHealth(HPMax)
  illusion:SetHealth(HPCur)
  illusion:SetMana(Mana)
  illusion:MoveToTargetToAttack(target)

  illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })

  illusion:MakeIllusion()

  
end