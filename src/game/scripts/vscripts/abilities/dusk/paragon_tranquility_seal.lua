paragon_tranquility_seal = class({})

LinkLuaModifier("modifier_tranquility_seal","abilities/dusk/paragon_tranquility_seal",LUA_MODIFIER_MOTION_NONE)

function paragon_tranquility_seal:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()
  local cteam = caster:GetTeam()
  local tteam = target:GetTeam()
  local duration = self:GetSpecialValueFor("duration")

  target:EmitSound("Hero_SkywrathMage.AncientSeal.Target")

  target:AddNewModifier(caster, self, "modifier_tranquility_seal", {Duration=duration}) --[[Returns:void
  No Description Set
  ]]
end

modifier_tranquility_seal = class({})

function modifier_tranquility_seal:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
  }
  return funcs
end

function modifier_tranquility_seal:GetEffectName()
  return "particles/units/heroes/hero_paragon/tranquil_seal_rune.vpcf"
end

function modifier_tranquility_seal:GetAbsoluteNoDamageMagical()
  return true
end

function modifier_tranquility_seal:GetAbsoluteNoDamagePhysical()
  return true
end

function modifier_tranquility_seal:GetAbsoluteNoDamagePure()
  return true
end

function modifier_tranquility_seal:IsDebuff()
  return true
end