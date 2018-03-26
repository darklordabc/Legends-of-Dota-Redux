LinkLuaModifier( "modifier_redux_silver_break_damage_reduction", "abilities/item_redux_silver.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_redux_silver_break_damage_reduction = class({})

function modifier_redux_silver_break_damage_reduction:IsPassive()
  return false
end

function modifier_redux_silver_break_damage_reduction:IsHidden()
  return true
end

function modifier_redux_silver_break_damage_reduction:IsPurgable()
	return true
end

function modifier_redux_silver_break_damage_reduction:IsDebuff()
  return true
end

function modifier_redux_silver_break_damage_reduction:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
  }
 
  return funcs
end

function modifier_redux_silver_break_damage_reduction:GetModifierTotalDamageOutgoing_Percentage()
  local caster = self:GetParent()
  return GetAbilitySpecial("item_redux_silver", "damage_reduction") * -1
end

function ApplyDamageReductionModifier( keys )
  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target
  
  target:AddNewModifier(caster,ability,"modifier_redux_silver_break_damage_reduction",{duration = ability:GetSpecialValueFor("break_duration")})

end

function ApplyDamageReductionModifierConsume( keys )
  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target
  
  target:AddNewModifier(caster,ability,"modifier_redux_silver_break_damage_reduction",{duration = ability:GetSpecialValueFor("break_duration")})
  
  local consumeable = caster:FindItemByName("item_redux_silver_consume")
  if consumeable then
    consumeable:SpendCharge()
  end

end

