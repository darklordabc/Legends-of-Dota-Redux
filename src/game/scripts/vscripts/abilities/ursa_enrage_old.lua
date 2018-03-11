function UpdateEnrageBonusDamage(keys)
  local caster = keys.caster
  local ability = keys.ability
  local casterHealth = caster:GetHealth()
  local healthAsDamage = ability:GetSpecialValueFor("current_health_as_damage") * 0.01 -- Converting it to %

  local modifier = "modifier_ursa_enrage_old_hidden"
  local bonusDamage = casterHealth * healthAsDamage

  caster:SetModifierStackCount(modifier,caster,bonusDamage)
end

function EnrageHeroVisual(keys)
  local caster = keys.caster
  local ability = keys.ability

  caster:SetRenderColor(255, 140, 0)

end

function RemoveEnrageVisual(keys)
  local caster = keys.caster
  local ability = keys.ability
  caster:SetRenderColor(255, 255, 255)
  caster:RemoveModifierByName("modifier_ursa_enrage_old_hidden") -- Just to make sure

end
