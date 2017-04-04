function aura( keys )
  local target = keys.target
  if target:GetMaxMana() == 0 then return end 
  local ability = keys.ability
  local targetmana = 100 - target:GetManaPercent()
  local resistance_loss = keys.resistance_loss
  local stacks = math.floor(targetmana/10) - 1
 
  if not target:HasModifier(resistance_loss) and stacks > 0 then 
    ability:ApplyDataDrivenModifier(target, target, resistance_loss, {})
  end
  target:SetModifierStackCount(resistance_loss, ability, stacks)

end

function stacktrack( keys)
  local modifier = "modifier_resistance_loss"
  if not keys.target:HasModifier("modifier_reduction_aura") then
    keys.target:RemoveModifierByName(modifier)
  end
end