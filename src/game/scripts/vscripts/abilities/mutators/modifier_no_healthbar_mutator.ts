class modifier_no_healthbar_mutator extends CDOTA_Modifier_Lua {
	IsPermanent() {return true}
	IsHidden() {return true}

	CheckState() {
		return {
			[modifierstate.MODIFIER_STATE_NO_HEALTH_BAR]:true,
		}
	}
}