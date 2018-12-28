LinkLuaModifier("modifier_sled_penguin_passive_redux","abilities/modifiers/modifier_sled_penguin_passive_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)

class sled_penguin_redux extends CDOTA_Ability_Lua {
	modifier:CDOTA_Buff
	OnToggle() {
		let caster = this.GetCaster();
		if (this.GetToggleState()) {
			this.modifier = caster.AddNewModifier(caster,this,"modifier_sled_penguin_passive_redux",{});
		} else {
			this.modifier.Destroy();
			let talentValue = 0;
			let talent = caster.FindAbilityByName("special_bonus_unique_sled_penguin_1");
			if (talent) {
				talentValue = talent.GetSpecialValueFor("value");
			}
			if (talentValue == 0){
				this.StartCooldown(this.GetSpecialValueFor("cooldown") * (1+ caster.GetCooldownReduction()));
			}
		}
	}

	GetBehavior() {
		let value = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_IMMEDIATE;
		if (this.GetCaster().HasModifier("modifier_sled_penguin_passive_redux")) {
			value = value + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE;
		}
		return value;
	}

	GetCooldown(level:number) {
		if (IsClient()) {
			return this.GetSpecialValueFor("cooldown");
		}
	}
}
