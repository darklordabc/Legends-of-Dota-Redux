LinkLuaModifier("modifier_fountain_break", "abilities/unpickable/fountain_break_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fountain_break_aura", "abilities/unpickable/fountain_break_aura", LUA_MODIFIER_MOTION_NONE)
fountain_break_aura = {GetIntrinsicModifierName = function() return "modifier_fountain_break" end,}
modifier_fountain_break = {
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsAura = function() return true end,
	GetAuraDuration = function() return 5.0 end,
	GetAuraRadius = function(self) return self:GetAbility():GetSpecialValueFor("radius") end,
	GetModifierAura = function() return "modifier_fountain_break_aura" end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end,
	GetAuraSearchTeam = function(self) return self:GetAbility():GetAbilityTargetTeam() end,
	GetAuraSearchType = function(self) return self:GetAbility():GetAbilityTargetType() end,
}
modifier_fountain_break_aura = {
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	CheckState = function() return {[MODIFIER_STATE_PASSIVES_DISABLED] = true,} end,
}