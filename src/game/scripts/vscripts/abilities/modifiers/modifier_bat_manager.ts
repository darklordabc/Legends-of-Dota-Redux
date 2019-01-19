class modifier_bat_manager extends CDOTA_Modifier_Lua {
	IsHidden() {return true;}
	IsPermanent() {return true;}

	GetPriority() {return modifierpriority.MODIFIER_PRIORITY_SUPER_ULTRA}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
		]
	}

	GetModifierBaseAttackTimeConstant() {
		if (IsServer()) {
			this.SetStackCount(this.GetParent().GetBaseBAT() * 100)
		}

		return this.GetStackCount() / 100
	}
}