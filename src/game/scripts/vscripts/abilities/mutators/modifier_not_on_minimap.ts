class modifier_not_on_minimap_mutator extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	CheckState() {
		return {
			[modifierstate.MODIFIER_STATE_NOT_ON_MINIMAP]:true,
		};
	}
}