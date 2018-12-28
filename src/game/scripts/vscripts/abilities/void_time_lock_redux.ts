LinkLuaModifier("modifier_void_time_lock_redux","abilities/void_time_lock_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class faceless_void_time_lock_redux extends CDOTA_Ability_Lua {
	IsPassive() {return true;}

	GetIntrinsicModifierName() {
		return "modifier_void_time_lock_redux";
	}
}

class modifier_void_time_lock_redux extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

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
			}
			print(chance)
			let bonus_damage = this.GetAbility().GetSpecialValueFor("bonus_damage");
			let talent = this.GetParent().FindAbilityByName("special_bonus_unique_faceless_void_3");
			bonus_damage += talent.GetSpecialValueFor("value");

			if (RollPercentage(chance)) {
				let dTable:DamageTable = {
					victim : params.target,
					attacker : this.GetParent(),
					damage_type : DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
					damage : bonus_damage
				}
				ApplyDamage(dTable);

				params.target.AddNewModifier(this.GetCaster(),this.GetAbility(),"modifier_faceless_void_timelock_freeze",{duration:this.GetAbility().GetSpecialValueFor("duration")});
				let second_strike_delay = this.GetAbility().GetSpecialValueFor("second_strike_delay");
				//@ts-ignore
				Timers.CreateTimer(second_strike_delay,()=>{
					this.GetParent().PerformAttack(params.target,true,true,true,true,true,true,true);
				})

				let particle = ParticleManager.CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack02.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, this.GetParent());
				ParticleManager.ReleaseParticleIndex(particle);
				this.GetParent().EmitSound("Hero_FacelessVoid.TimeLockImpact");
			}

			
		}
	}

	
}