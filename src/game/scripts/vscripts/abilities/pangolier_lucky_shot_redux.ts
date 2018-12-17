LinkLuaModifier("modifier_pangolier_luckyshot_redux_passive","abilities/pangolier_lucky_shot_redux.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class pangolier_lucky_shot_redux extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() { return "modifier_pangolier_luckyshot_redux_passive"}
}

class modifier_pangolier_luckyshot_redux_passive extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_EVENT_ON_ATTACK_LANDED,
		]
	}

	OnAttackLanded(params:ModifierAttackEvent) {

		if (params.attacker == this.GetParent()) {
			let chance = this.GetAbility().GetSpecialValueFor("chance_pct");
			if (this.GetParent().IsRangedAttacker()) {
				chance = this.GetAbility().GetSpecialValueFor("chance_pct_ranged");
			}
			if (RollPercentage(chance)) {
				if (RollPercentage(50)) {
					params.target.AddNewModifier(params.attacker,this.GetAbility(),"modifier_pangolier_luckyshot_disarm",{duration:this.GetAbility().GetSpecialValueFor("duration")})
				} else {
					params.target.AddNewModifier(params.attacker,this.GetAbility(),"modifier_pangolier_luckyshot_silence",{duration:this.GetAbility().GetSpecialValueFor("duration")})
				}
				let p = ParticleManager.CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,params.attacker)
				ParticleManager.SetParticleControlEnt(p,1,params.target,ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,"follow_hitloc",params.target.GetAbsOrigin(),false)
				ParticleManager.ReleaseParticleIndex(p)

				params.attacker.EmitSound("Hero_Pangolier.LuckyShot.Proc")
			}
		}
	}
}