--[[ 	Mercy main, BTW
		Author: Firetoad
		Date: 11.03.2017	]]

modifier_mercy_caduceus_power = class({
	IsBuff =		function(self) return true end,
	IsHidden =		function(self) return false end,
	IsPurgable =	function(self) return true end,
	IsPassive =		function(self) return false end,
})

function modifier_mercy_caduceus_power:OnCreated(keys)
	self.bonus_damage = keys.bonus_damage
	self.bonus_spell_damage = keys.bonus_spell_damage
end

function modifier_mercy_caduceus_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE 
	}
	return funcs
end

function modifier_mercy_caduceus_power:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_mercy_caduceus_power:GetModifierSpellAmplify_Percentage()
	return self.bonus_spell_damage
end

function modifier_mercy_caduceus_power:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end