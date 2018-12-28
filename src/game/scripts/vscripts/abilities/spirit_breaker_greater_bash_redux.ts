// Breaks the interaction with charge!

LinkLuaModifier("modifier_spiritbreaker_greater_bash_redux","abilities/spirit_breaker_greater_bash_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class spirit_breaker_greater_bash_redux extends CDOTA_Ability_Lua {
	IsPassive() {return true;}

	GetIntrinsicModifierName() {
		return "modifier_spiritbreaker_greater_bash_redux";
	}
}

class modifier_spiritbreaker_greater_bash_redux extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return false;}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_EVENT_ON_ATTACK_LANDED,
		]
	}

	OnAttackLanded(params:ModifierAttackEvent) {

		if (params.attacker == this.GetParent() && !params.target.IsBuilding()) {
			let chance = this.GetAbility().GetSpecialValueFor("chance_pct");
			if (this.GetParent().IsRangedAttacker()) {
				chance = this.GetAbility().GetSpecialValueFor("chance_pct_ranged");
				let talent = this.GetParent().FindAbilityByName("special_bonus_unique_spirit_breaker_1");
				if (talent) {
					chance += (talent.GetSpecialValueFor("value")/2);
				}
			} else {
				let talent = this.GetParent().FindAbilityByName("special_bonus_unique_spirit_breaker_1");
				if (talent) {
					chance += talent.GetSpecialValueFor("value");
				}
			}

			let damage = this.GetAbility().GetSpecialValueFor("damage")
			let talent = this.GetParent().FindAbilityByName("special_bonus_unique_spirit_breaker_3");
			if (talent) {
				damage += talent.GetSpecialValueFor("value");
			}

			if (RollPercentage(chance)) {
				let dTable:DamageTable = {
					victim : params.target,
					attacker : this.GetParent(),
					damage_type : DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
					damage : this.GetParent().GetIdealSpeed() * damage * 0.01 ,
				}
				ApplyDamage(dTable);

				let v = this.GetParent().GetAbsOrigin()


				let knockbackTable = {
					should_stun:true,
				    knockback_duration : this.GetAbility().GetSpecialValueFor("knockback_duration"),
				    duration : this.GetAbility().GetSpecialValueFor("duration"),
				    knockback_distance : this.GetAbility().GetSpecialValueFor("knockback_distance"),
				    knockback_height : 0,
				    //@ts-ignore
				    center_x : v.x,
				    //@ts-ignore
				    center_y : v.y,
				    center_z : GetGroundHeight(v,null),
				}

				params.target.AddNewModifier(this.GetCaster(),this.GetAbility(),"modifier_knockback",knockbackTable);
				let second_strike_delay = this.GetAbility().GetSpecialValueFor("second_strike_delay");
				//@ts-ignore
				Timers.CreateTimer(second_strike_delay,()=>{
					this.GetParent().PerformAttack(params.target,true,true,true,true,true,true,true);
				})

				let p = ParticleManager.CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,params.target);
				ParticleManager.SetParticleControl(p,0,params.target.GetAbsOrigin());
				ParticleManager.ReleaseParticleIndex(p);
				this.GetParent().EmitSound("Hero_Spirit_Breaker.GreaterBash");

				this.GetParent().AddNewModifier(this.GetParent(),this.GetAbility(),"modifier_spirit_breaker_greater_bash_speed",{duration : this.GetAbility().GetSpecialValueFor("movespeed_duration")});
			}
		}
	}

	
}