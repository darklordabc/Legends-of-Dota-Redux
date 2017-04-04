--tenebris_mortal_coil_modifier_buff.lua
if tenebris_mortal_coil_modifier_buff == nil then tenebris_mortal_coil_modifier_buff = class ({}) end
 
function tenebris_mortal_coil_modifier_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
 
    return funcs
end
 
function tenebris_mortal_coil_modifier_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end
 
function tenebris_mortal_coil_modifier_buff:IsHidden()
    return true
end