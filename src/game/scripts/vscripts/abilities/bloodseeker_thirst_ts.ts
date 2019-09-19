LinkLuaModifier("modifier_blodseeker_thrist_lod_buff","abilities/bloodseeker_thirst_ts.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class bloodseeker_thirst_lod extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {
		return "modifier_blodseeker_thrist_lod_buff";
	}

	OnUpgrade() {
		let caster = this.GetCaster();
		if (this.GetName()== "bloodseeker_thirst_lod") {
			caster.AddNewModifier(caster,this,"modifier_bloodseeker_thirst",{});
		} else if(this.GetName()== "bloodseeker_thirst_lod_op") {
			caster.AddNewModifier(caster,this,"modifier_bloodseeker_thirst",{});
		} 
	}
}


class modifier_blodseeker_thrist_lod_buff extends CDOTA_Modifier_Lua {
	OnCreated() {
		if (IsServer()) {
			this.StartIntervalThink(FrameTime());
		}
	}

	OnIntervalThink() {
		let caster = this.GetCaster();
		let ability = this.GetAbility();
		let team = caster.GetTeamNumber();
		let units = HeroList.GetAllHeroes();
		let bonus = 0
		let max_treshhold = ability.GetSpecialValueFor("buff_threshold_pct")
		let min_treshhold = ability.GetSpecialValueFor("visibility_threshold_pct")
		units.forEach((hero)=>{
			if (hero.IsOpposingTeam(team) && hero.IsAlive() && hero.IsRealHero() && hero.GetHealthPercent() < max_treshhold) {
				bonus = bonus + Math.max(max_treshhold-min_treshhold,hero.GetHealthPercent()-max_treshhold)
			}
		})

		this.SetStackCount(bonus);
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		]
	}

	GetModifierAttackSpeedBonus_Constant() {
		return this.GetStackCount() * this.GetAbility().GetSpecialValueFor("bonus_attack_speed") * 0.5;
	}

	GetModifierMoveSpeedBonus_Percentage() {
		return this.GetStackCount() * this.GetAbility().GetSpecialValueFor("bonus_movement_speed") * 0.5 ;
	}

	IsAura() {
		return true;
	}

	GetAuraSearchTeam() {
		return DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY;
	}

	GetAuraSearchType() {
		return DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO;
	}

	GetModifierAura() {
		return "modifier_blodseeker_thrist_lod_debuff";
	}

	IsHidden() {
		return this.GetStackCount() == 0;
	}
}

class modifier_blodseeker_thrist_lod_debuff extends CDOTA_Modifier_Lua {
	IsHidden() {
		return this.GetParent().GetHealthPercent() > this.GetAbility().GetSpecialValueFor("visibility_threshold_pct");
	}

	CheckState() {
		return {
			[modifierstate.MODIFIER_STATE_PROVIDES_VISION]:this.GetParent().GetHealthPercent() < this.GetAbility().GetSpecialValueFor("visibility_threshold_pct")
		}
	}
}