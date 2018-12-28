LinkLuaModifier("modifier_slardar_bash_redux","abilities/slardar_bash_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_slardar_bash_counter_redux","abilities/slardar_bash_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class slardar_bash_redux extends CDOTA_Ability_Lua {
	IsPassive() {return true;}

	GetIntrinsicModifierName() {
		return "modifier_slardar_bash_redux";
	}
}

class modifier_slardar_bash_redux extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_EVENT_ON_ATTACK_LANDED,
			modifierfunction.MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		]
	}

	OnAttackLanded(params:ModifierAttackEvent) {
		if (params.attacker == this.GetParent() && !params.target.IsBuilding()) {
			let modifier = params.target.FindModifierByNameAndCaster("modifier_slardar_bash_counter_redux",this.GetParent());
			if (modifier) {
				modifier.IncrementStackCount();
				if (this.GetParent().IsRangedAttacker() && modifier.GetStackCount() == this.GetAbility().GetSpecialValueFor("attack_count_ranged") ||
					!this.GetParent().IsRangedAttacker() && modifier.GetStackCount() == this.GetAbility().GetSpecialValueFor("attack_count")) {
					modifier.SetStackCount(0);
					params.target.AddNewModifier(this.GetParent(),this.GetAbility(),"modifier_slardar_bash",{duration : this.GetAbility().GetSpecialValueFor("duration")})
					EmitSoundOn("Hero_Slardar.Bash",params.target)
				}
			} else {
				params.target.AddNewModifier(this.GetParent(),this.GetAbility(),"modifier_slardar_bash_counter_redux",{});
			}
		}
	}

	GetModifierProcAttack_BonusDamage_Physical(params:ModifierAttackEvent) {
		if (IsClient()) {return 0}
		let modifier = params.target.FindModifierByNameAndCaster("modifier_slardar_bash_counter_redux",this.GetParent());
		if (!modifier) {return 0}

		if (params.attacker == this.GetParent()) {
			if (this.GetParent().IsRangedAttacker() && modifier.GetStackCount() == this.GetAbility().GetSpecialValueFor("attack_count_ranged")-1 ||
			!this.GetParent().IsRangedAttacker() && modifier.GetStackCount() == this.GetAbility().GetSpecialValueFor("attack_count")-1) {
				let bonus = this.GetAbility().GetSpecialValueFor("bonus_damage");
				let talent = this.GetParent().FindAbilityByName("special_bonus_unique_slardar_2")
				bonus += talent.GetSpecialValueFor("value")
				return bonus
			}
		}
	}
}