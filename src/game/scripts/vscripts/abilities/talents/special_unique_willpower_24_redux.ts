class modifier_special_unique_willpower_24_redux extends CDOTA_Modifier_Lua {
	IsPermanent() {return true}
	IsHidden() { return true}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		]
	}

	GetModifierStatusResistanceStacking() {
		return 24
	}
}