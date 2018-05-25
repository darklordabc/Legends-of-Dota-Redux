modifier_rune_doubledamage_mutated_redux = class({})

function modifier_rune_doubledamage_mutated_redux:IsHidden()
  return true
end

function modifier_rune_doubledamage_mutated_redux:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE 
    }
end

function modifier_rune_doubledamage_mutated_redux:OnCreated()
  print("AAA")
end


function modifier_rune_doubledamage_mutated_redux:GetModifierBaseDamageOutgoing_Percentage()
    return 100 -- 300?
end
--[[
function modifier_rune_doubledamage_mutated_redux:GetEffectName()
  return "particles/generic_gameplay/rune_doubledamage.vpcf"
end

function modifier_rune_doubledamage_mutated_redux:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rune_doubledamage_mutated_redux:GetTexture()
    return "puck_phase_shift"
end]]

modifier_rune_arcane_mutated_redux = class({})

function modifier_rune_arcane_mutated_redux:IsHidden()
  return true
end

function modifier_rune_arcane_mutated_redux:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,   
    }
end

function modifier_rune_arcane_mutated_redux:GetModifierPercentageCooldownStacking()
    return 30
end

function modifier_rune_arcane_mutated_redux:GetModifierPercentageManacostStacking()
    return 30
end


--[[function modifier_rune_arcane_mutated_redux:GetEffectName()
  return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_rune_arcane_mutated_redux:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rune_arcane_mutated_redux:GetTexture()
    return "tiny_toss"
end]]