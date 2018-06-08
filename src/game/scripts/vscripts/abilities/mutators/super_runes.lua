modifier_rune_doubledamage_mutated_redux = class({})

function modifier_rune_doubledamage_mutated_redux:IsHidden()
  return false
end

function modifier_rune_doubledamage_mutated_redux:DeclareFunctions()
    return {
      MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE 
    }
end

function modifier_rune_doubledamage_mutated_redux:OnCreated()
  print("AAA",IsServer())
  print(self:GetRemainingTime())
end

function modifier_rune_doubledamage_mutated_redux:OnDestroy()
  print("modifier_rune_doubledamage_mutated_redux Gone")
end

function modifier_rune_doubledamage_mutated_redux:GetModifierBaseDamageOutgoing_Percentage()
    return 200 -- 300?
end

function modifier_rune_doubledamage_mutated_redux:GetEffectName()
  return "particles/generic_gameplay/rune_doubledamage.vpcf"
end

function modifier_rune_doubledamage_mutated_redux:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rune_doubledamage_mutated_redux:GetTexture()
    return "abaddon_death_coil"
end

modifier_rune_arcane_mutated_redux = class({})

function modifier_rune_arcane_mutated_redux:OnCreated()
  print("bbb",IsServer())
  print(self:GetRemainingTime())
end

function modifier_rune_arcane_mutated_redux:OnDestroy()
  print("modifier_rune_arcane_mutated_redux Gone")
end


function modifier_rune_arcane_mutated_redux:IsHidden()
  return false
end

function modifier_rune_arcane_mutated_redux:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,   
    }
end

function modifier_rune_arcane_mutated_redux:GetModifierPercentageCooldownStacking()
    return 60
end

function modifier_rune_arcane_mutated_redux:GetModifierPercentageManacostStacking()
    return 60
end


function modifier_rune_arcane_mutated_redux:GetEffectName()
  return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_rune_arcane_mutated_redux:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rune_arcane_mutated_redux:GetTexture()
    return "abaddon_aphotic_shield"
end