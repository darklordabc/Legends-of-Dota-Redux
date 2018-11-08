LinkLuaModifier("modifier_pushing_blast_slow","abilities/pushing_blast.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)

class pushing_blast extends CDOTA_Ability_Lua {
	OnSpellStart() {
		let caster = this.GetCaster();
		let point = caster.GetAbsOrigin();

		let p = ParticleManager.CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf",ParticleAttachment_t.PATTACH_CUSTOMORIGIN,caster);
		ParticleManager.SetParticleControl(p,0,point);
		ParticleManager.SetParticleControl(p,1 ,point);
		ParticleManager.SetParticleControl(p,2,Vector(this.GetSpecialValueFor("radius"),0,0));
		let units = FindUnitsInRadius(caster.GetTeamNumber(),point,null,this.GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
		units.forEach((unit) => {
			unit.AddNewModifier(caster,this,"modifier_pushing_blast_slow",{duration : this.GetSpecialValueFor("duration")})

			let dist = (point-unit.GetAbsOrigin()).Length2D()
			let knockback = {
                should_stun : true,
                knockback_duration : 0.33,
                duration : 0.33,
                knockback_distance : this.GetSpecialValueFor("radius") - dist,
                knockback_height : 0,
                center_x : caster.GetAbsOrigin()[1],
                center_y : caster.GetAbsOrigin()[2],
                center_z : GetGroundHeight(caster.GetAbsOrigin(),null),
            }
			unit.AddNewModifier(caster,this,"modifier_knockback",knockback)
			let dTable:DamageTable = {
				victim : unit,
				ability: this,
				attacker:caster,
				damage: this.GetSpecialValueFor("damage"),
				damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
			}

			ApplyDamage(dTable);


		})


	}
}

class modifier_pushing_blast_slow extends CDOTA_Modifier_Lua {
	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			modifierfunction.MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		]
	}

	GetModifierMoveSpeedBonus_Percentage() {
		return -this.GetAbility().GetSpecialValueFor("ms_slow");
	}

	GetModifierTotalDamageOutgoing_Percentage() {
		if (IsServer()) {
			let caster = this.GetCaster();
			let talent = caster.FindAbilityByName("special_bonus_unique_pushing_blast_0");
			if (talent && talent.GetLevel() > 0) {
				return talent.GetSpecialValueFor("value")
			}
		}
		return 0
	}
}
