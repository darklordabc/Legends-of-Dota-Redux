--[[
  Author: kritth
  Date: 6.1.2015.
  Register target
]]
function assassinate_register_target( keys )
  keys.caster.assassinate_target = keys.target
end

--[[
  Author: kritth
  Date: 6.1.2015.
  Remove debuff from target
]]
function assassinate_remove_target( keys )
  if keys.caster.assassinate_target then
    keys.caster.assassinate_target:RemoveModifierByName( "modifier_assassinate_target_datadriven" )
    keys.caster.assassinate_target = nil
  end
end

--[[
  Author: 
  Date: 
  Check for scepter and use required behavior
]]
function assasinate_deal_damage( keys )
  if not keys.caster:HasScepter() then
    local damageTable = {
      victim = keys.target,
      attacker = keys.caster,
      damage = keys.ability:GetSpecialValueFor("damage"),
      damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable)
  else
    local units = FindUnitsInRadius(keys.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, keys.ability:GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    if keys.target:IsCreep() then
      local damageTable = {
        victim = keys.target,
        attacker = keys.caster,
        damage = keys.caster:GetAttackDamage() * 2.8,  
        damage_type = DAMAGE_TYPE_PHYSICAL,
      }
    end
    for k,v in pairs (units) do
      local damageTable = {
        victim = v,
        attacker = keys.caster,
        damage = keys.caster:GetAttackDamage() * 2.8,  
        damage_type = DAMAGE_TYPE_PHYSICAL,
      }
      ApplyDamage(damageTable)
    end
  end
end
