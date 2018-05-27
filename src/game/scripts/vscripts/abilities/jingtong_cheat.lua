LinkLuaModifier( "modifier_jingtong", "abilities/jingtong_cheat.lua" ,LUA_MODIFIER_MOTION_NONE )

if jingtong_cheat ~= "" then jingtong_cheat = class({}) end

function jingtong_cheat:GetIntrinsicModifierName()
  return "modifier_jingtong"
end

if modifier_jingtong ~= "" then modifier_jingtong = class({}) end

function modifier_jingtong:IsPassive()
  return true
end

function modifier_jingtong:IsHidden()
  return true
end

function modifier_jingtong:IsPurgable()
	return false
end

function modifier_jingtong:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
  }
 
  return funcs
end

function modifier_jingtong:GetPriority()
  return MODIFIER_PRIORITY_ULTRA
end

if IsServer() then
  function modifier_jingtong:GetModifierPercentageCooldown()
    local caster = self:GetParent()

    local core = 0
    if caster:FindItemByName("item_octarine_core") or caster:FindItemByName("item_octarine_core_consumable") or caster:HasModifier("modifier_item_octarine_core_consumable") then
      core = 25
    end

    local talent = 0
    if caster:FindAbilityByName("special_bonus_cooldown_reduction_10") and caster:FindAbilityByName("special_bonus_cooldown_reduction_10"):GetLevel() > 0 then
      talent = 10
    elseif caster:FindAbilityByName("special_bonus_cooldown_reduction_12") and caster:FindAbilityByName("special_bonus_cooldown_reduction_12"):GetLevel() > 0 then
      talent = 12
    elseif caster:FindAbilityByName("special_bonus_cooldown_reduction_15") and caster:FindAbilityByName("special_bonus_cooldown_reduction_15"):GetLevel() > 0 then
      talent = 15
    elseif caster:FindAbilityByName("special_bonus_cooldown_reduction_20") and caster:FindAbilityByName("special_bonus_cooldown_reduction_20"):GetLevel() > 0 then
      talent = 20
    elseif caster:FindAbilityByName("special_bonus_cooldown_reduction_25") and caster:FindAbilityByName("special_bonus_cooldown_reduction_25"):GetLevel() > 0 then
      talent = 25
    end

    local final = (100 - core) * (100 - self:GetAbility():GetSpecialValueFor("reduce"))

    self:SetStackCount(final)

    return 100 - (final / 100)
  end
else
  function modifier_jingtong:GetModifierPercentageCooldown()
    local caster = self:GetParent()

    return 100 - (self:GetStackCount() / 100)
  end
end