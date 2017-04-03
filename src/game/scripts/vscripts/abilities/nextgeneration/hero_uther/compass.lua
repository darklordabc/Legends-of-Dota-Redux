function CreateHalo(keys)
  local caster = keys.caster
  local ability = keys.ability
  local casterPosition = caster:GetAbsOrigin()
  ability.casterPosition = casterPosition -- Store this to track whether the order location is in or out the halo.

  local radius = ability:GetSpecialValueFor("radius")
  local duration = ability:GetSpecialValueFor("duration")
  local particle = "particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf"
 

  --EmitSoundOn(keys.sound, caster)

  ability.field_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
  ParticleManager:SetParticleControl(ability.field_particle, 0, casterPosition)
  ParticleManager:SetParticleControl(ability.field_particle, 1, Vector(radius, radius, 0))
  ParticleManager:SetParticleControl(ability.field_particle, 2, casterPosition)

  ability:ApplyDataDrivenThinker(caster,casterPosition,"modifier_uther_compass_halo",{duration = duration})
  ability:ApplyDataDrivenThinker(caster,casterPosition,"modifier_uther_compass_halo2",{duration = duration})
end

function RemoveHalo(keys)
  local caster = keys.caster
  local ability = keys.ability

  ParticleManager:DestroyParticle(ability.field_particle, true)
end


function CompassPositionCheck(keys)
  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
  local radius = ability:GetSpecialValueFor("radius")
  local currTime = GameRules:GetGameTime()

  if not target.positions or not target.positions[(math.floor(currTime * 100)/100)-0.04] then 
     return 
  end

  local oldPosition = target.positions[math.floor((currTime*25)/25)-0.04]
  local targetPosition = target:GetAbsOrigin()
  if (ability.casterPosition - oldPosition):Length2D() > radius then
    -- Unit was outside the halo, at the edge. We need to keep it out.
    
    if (ability.casterPosition - targetPosition):Length2D() < radius then
      --Unit is now inside the halo, setting the unit back to where it was an instant before
      
      target:SetAbsOrigin(oldPosition)
    end
  else
    -- Unit was inside the halo, it needs to stay in
    
    if (ability.casterPosition - targetPosition):Length2D() > radius then
      --Unit is now outside the halo, setting it back to where it was
      
      target:SetAbsOrigin(oldPosition)
    end
  end
end

function UtherCompassFilterOrders(hCaster,hTarget,iOrderType,vOrderVector)
  local unit = hCaster  -- The unit giving the order
  local target = hTarget -- In the order
  local orderType = iOrderType



  


  if unit:HasModifier("modifier_uther_compass_control_orders") then
    local caster = unit:FindModifierByName("modifier_uther_compass_control_orders"):GetCaster() -- The owner of the spell
    local ability = caster:FindAbilityByName("uther_compass")
    local radius = ability:GetSpecialValueFor("radius")
    
    if not (orderType == DOTA_UNIT_ORDER_CAST_POSITION or
    orderType == DOTA_UNIT_ORDER_CAST_TARGET or
    orderType == DOTA_UNIT_ORDER_CAST_TARGET_TREE) then
      return true 
    end -- An order that's not a spell is not relevant
    
    if not vOrderVector then
      vOrderVector = taget:GetAbsOrigin()
    end
    
    if not vOrderVector then return true end -- An ability without a target has been cast, just to be sure
    

    if (unit:GetAbsOrigin() - ability.casterPosition):Length2D() < radius then
      -- Unit is in halo, can't target anything outside
      if (vOrderVector - ability.casterPosition):Length2D() < radius then
        -- Order is targetted within halo
        return true
      else
        local pID = unit:GetPlayerID()
        Notifications:ClearBottom(pID)
        Notifications:Bottom(pID, {text="You can't target outside the halo.", duration=4, style={color="red"}, continue=false})
        return false
      end
    else
      -- Unit is outside of halo
      if (vOrderVector - ability.casterPosition):Length2D() < radius then
        -- Order is targetted within halo
        local pID = unit:GetPlayerID()
        Notifications:ClearBottom(pID)
        Notifications:Bottom(pID, {text="You can't target inside the halo.", duration=4, style={color="red"}, continue=false}) 
        return false
      else
        return true
      end
    end
  else
    return true
  end
end



