class modifier_flying_with_slow extends CDOTA_Modifier_Lua {
	z:number;
	IsPermanent() {return true;	}
	//IsHidden() {return this.GetStackCount() == 1;}

	CheckState() {
		return {
			[modifierstate.MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]: !(this.GetAbility() && this.GetParent().PassivesDisabled())
		};
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			modifierfunction.MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		];
	}

	OnCreated() {
		if (IsServer()) {
			this.SetStackCount(0);
			this.StartIntervalThink(FrameTime())
		} else {
			this.z = 0;
		}
	}

	OnIntervalThink() {
		let unit = this.GetParent();
		if (GridNav.IsBlocked(unit.GetAbsOrigin())) {
			this.SetStackCount(0);
		}
		else {
			this.SetStackCount(1);
		}
		
	}
	GetModifierMoveSpeedBonus_Percentage() {
		let unit = this.GetParent();

		if (!this.GetAbility() && unit.PassivesDisabled())
			return 0;

		if (this.GetStackCount() == 0) {
			let ms = this.GetAbility() ? -this.GetAbility().GetSpecialValueFor("flying_movespeed_slow_pct") : -50;
			return ms;
		}

		return 0;

	}

	GetVisualZDelta() {
		let unit = this.GetParent();
		if (!this.GetAbility() && unit.PassivesDisabled()) {
			this.z = this.z-15;
			return this.z;
		}
		if (this.GetStackCount() == 0) {
			this.z = Math.min(250,this.z + 15);
			return this.z;
		}

		this.z = Math.max(0,this.z-15);
		return this.z;
	}
}