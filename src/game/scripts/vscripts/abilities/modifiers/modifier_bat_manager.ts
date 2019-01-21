class modifier_bat_manager extends CDOTA_Modifier_Lua {
	IsHidden() {return true;}
	IsPermanent() {return true;}

	GetPriority() {return modifierpriority.MODIFIER_PRIORITY_SUPER_ULTRA}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
		]
	}
	OnCreated() {
		if (IsServer()) {
			this.StartIntervalThink(1)
		}
	}

	OnIntervalThink() {
		this.SetStackCount(this.GetParent().GetBaseBAT() * 100);
	}

	GetModifierBaseAttackTimeConstant() {
		if (IsServer()) {
			//this.SetStackCount(this.GetParent().GetBaseBAT() * 100);
		}
		//if (this.GetParent().IsAlive()) {
			return this.GetStackCount() / 100;
		//}
		
	}
}