modifier_rattletrap_rocket_flare_ai = class({})


--------------------------------------------------------------------------------

function modifier_rattletrap_rocket_flare_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_rattletrap_rocket_flare_ai:RemoveOnDeath()
    return false
end

function modifier_rattletrap_rocket_flare_ai:IsPurgable()
    return false
end


--------------------------------------------------------------------------------
function modifier_rattletrap_rocket_flare_ai:OnCreated()
  self:StartIntervalThink(0.1)
end

function modifier_rattletrap_rocket_flare_ai:OnIntervalThink()
  local caster = self:GetParent()

  self:CastRocketFlare(caster)
end




function modifier_rattletrap_rocket_flare_ai:CastRocketFlare(caster)
  if IsServer() then
    local ability = caster:FindAbilityByName("rattletrap_rocket_flare")
    if ability:IsFullyCastable() and not ability:IsInAbilityPhase() and ability:GetLevel() > 0 then
      local abilityDamage = ability:GetSpecialValueFor("damage")
      local abilityDamageType = ability:GetAbilityDamageType()
      if not abilityDamage or abilityDamage == 0 then
        abilityDamage = ability:GetAbilityDamage()
      end
      local abilitySpeed = ability:GetSpecialValueFor("speed")

      local units = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,0,0,false)
      for _,target in pairs(units) do
        local magicResistance = target:GetMagicalArmorValue()
        local regeneration = target:GetHealthRegen()
        local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
        local time = distance/abilitySpeed
        local direction = target:GetForwardVector()
        local speed = 0
        if target.previousPosition then
          if target:CanEntityBeSeenByMyTeam(caster)
            if target:GetHealth() < (abilityDamage * (1-magicResistance)) - (time * regeneration) then -- Is there enough damage to kill?
            
              local targetLocation = target:GetAbsOrigin()
              speed = ((target.previousPosition - targetLocation):Length2D()) * 10 -- Interval 0.1
              local targetLocationTemp = targetLocation + (direction * speed)
              --Now we have an estimate of the position the unit will be after the time the projectile would take to hit the position the target is.
              local distance = (targetLocationTemp - caster:GetAbsOrigin()):Length2D()
              local time = distance/abilitySpeed
              -- Now we have the location where the target would be in the time we would hit the previous location
              
              targetLocation = targetLocation + (direction * speed)
              
              caster:CastAbilityOnPosition(targetLocation,ability,caster:GetPlayerOwnerID())
            end
          end
        end
        target.previousPosition = target:GetAbsOrigin()
      end
    end
  end
end


