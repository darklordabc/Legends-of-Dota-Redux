class modifier_special_unique_status_resistance_20_redux extends CDOTA_Modifier_Lua {
	IsPermanent() {return true}
	IsHidden() { return true}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		]
	}

	GetModifierStatusResistanceStacking() {
		return 20
	}
}