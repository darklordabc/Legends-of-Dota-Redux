item_aether_lens_baseclass = {}

LinkLuaModifier("modifier_item_aether_lens_arena", "items/angel_arena_black_star/item_aether_lens.lua", LUA_MODIFIER_MOTION_NONE)

function item_aether_lens_baseclass:GetIntrinsicModifierName()
	return "modifier_item_aether_lens_arena"
end

item_aether_lens_arena = class(item_aether_lens_baseclass)
item_aether_lens_2 = class(item_aether_lens_baseclass)
item_aether_lens_3 = class(item_aether_lens_baseclass)
item_aether_lens_4 = class(item_aether_lens_baseclass)
item_aether_lens_5 = class(item_aether_lens_baseclass)


modifier_item_aether_lens_arena = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsHidden      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_item_aether_lens_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_aether_lens_arena:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_aether_lens_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_aether_lens_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_aether_lens_arena:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end
