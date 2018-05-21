modifier_rune_doubledamage_mutated = class({})

function modifier_rune_doubledamage_mutated:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE 
    }
end

function modifier_rune_doubledamage_mutated:GetModifierBaseDamageOutgoing_Percentage()
    return 200 -- 300?
end

function modifier_rune_doubledamage_mutated:GetEffectName()
  return "particles/generic_gameplay/rune_doubledamage.vpcf"
end

function modifier_rune_doubledamage_mutated:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

modifier_rune_arcane_mutated = class({})

function modifier_rune_arcane_mutated:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,   
    }
end

function modifier_rune_arcane_mutated:GetModifierPercentageCooldownStacking()
    return 60
end

function modifier_rune_arcane_mutated:GetModifierPercentageManacostStacking()
    return 60
end


function modifier_rune_arcane_mutated:GetEffectName()
  return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_rune_arcane_mutated:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end