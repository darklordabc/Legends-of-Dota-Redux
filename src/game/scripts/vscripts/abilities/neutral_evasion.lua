neutral_evasion = {}

function neutral_evasion:GetIntrinsicModifierName()
	return "modifier_neutral_evasion"
end

function neutral_evasion:OnUpgrade()
	self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_neutral_evasion", {})
end

modifier_neutral_evasion = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	IsPassive = function() return true end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_EVASION_CONSTANT,} end,
	GetModifierEvasion_Constant = function(self) return self.evasion end,

	OnRefresh = function(self) OnCreated(self, kv) end,
	OnCreated = function(self)
		self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	end,
}