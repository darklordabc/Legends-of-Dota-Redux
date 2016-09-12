
--[[
  Author: kritth
  Date: 09.01.2015
  Find closest hero fire projectile at it
]]
function concussive_shot_seek_target( keys )
  -- Variables
  local caster = keys.caster
  local ability = keys.ability
  local particle_name = "particles/concussive_break/skywrath_mage_concussive_breakshot.vpcf"
  local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
  local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
  local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
  local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
  local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS

  -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
  local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false)

  -- Seek out target
  for k, v in pairs( units ) do
    if caster:CanEntityBeSeenByMyTeam(v) then
      local projTable = {
        EffectName = particle_name,
        Ability = ability,
        Target = v,
        Source = caster,
        bDodgeable = false,
        bProvidesVision = true,
        vSpawnOrigin = caster:GetAbsOrigin(),
        iMoveSpeed = speed,
        iVisionRadius = radius,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
      }
      ProjectileManager:CreateTrackingProjectile( projTable )
      end
    break
  end
end

--[[
  Author: kritth
  Date: 8.1.2015.
  Give post attack vision
]]
function concussive_shot_post_vision( keys )
  local target = keys.target:GetAbsOrigin()
  local ability = keys.ability
  local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
  local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

  -- Create node
  ability:CreateVisibilityNode( target, radius, duration )
end
