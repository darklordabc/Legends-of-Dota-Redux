LinkLuaModifier("modifier_flesh_heap_fiery_soul","abilities/fiery_heap.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class pudge_flesh_heap_fiery_soul extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {
		return "modifier_flesh_heap_fiery_soul"
	}
}

class modifier_flesh_heap_fiery_soul extends CDOTA_Modifier_Lua {
	IsHidden() {return this.GetStackCount() == 0;}
	IsDebuff() {return false;}
	IsPermanent() {return true;}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_EVENT_ON_DEATH,
			modifierfunction.MODIFIER_EVENT_ON_TAKEDAMAGE,

			modifierfunction.MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			modifierfunction.MODIFIER_PROPERTY_HEALTH_BONUS,
			modifierfunction.MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
			modifierfunction.MODIFIER_PROPERTY_MODEL_SCALE,
		]
	}

	OnDeath(params:ModifierAttackEvent) {
		//@ts-ignore
		let unit = params.unit
		if (params.attacker == this.GetParent() && unit.IsRealHero()){
			this.IncrementStackCount();
			// Particle
			let nFXIndex = ParticleManager.CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", ParticleAttachment_t.PATTACH_OVERHEAD_FOLLOW, this.GetCaster() )
      		ParticleManager.SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
      		ParticleManager.ReleaseParticleIndex( nFXIndex )
		} else if ( unit == this.GetParent()) {
			let talent = this.GetParent().FindAbilityByName("special_bonus_unique_fiery_soul_collector_0")
			if (!talent || talent.GetLevel() == 0) {
				this.SetStackCount(this.GetStackCount()/2);
			}
		}
	}

	OnTakeDamage(params:ModifierAttackEvent) {
		if (params.attacker == this.GetParent() && params.damage_category == DamageCategory_t.DOTA_DAMAGE_CATEGORY_SPELL) {
			let healPercentage = this.GetAbility().GetSpecialValueFor("spell_lifesteal_bonus") * 0.01;
			this.GetParent().Heal(healPercentage*this.GetStackCount()*params.damage,this.GetParent());

			
		}
	}

	GetModifierAttackSpeedBonus_Constant() {
		let value = this.GetAbility().GetSpecialValueFor("attack_speed_bonus");
		return value * this.GetStackCount();
	}

	GetModifierMoveSpeedBonus_Constant() {
		let value = this.GetAbility().GetSpecialValueFor("move_speed_bonus");
		return value * this.GetStackCount();
	}

	GetModifierBonusStats_Intellect() {
		let value = this.GetAbility().GetSpecialValueFor("int_bonus");
		return value * this.GetStackCount();
	}

	GetModifierHealthBonus() {
		let value = this.GetAbility().GetSpecialValueFor("health_bonus");
		return value * this.GetStackCount();
	}

	GetModifierCastRangeBonusStacking() {
		let value = this.GetAbility().GetSpecialValueFor("cast_range_bonus");
		return value * this.GetStackCount();
	}

	GetModifierModelScale() {
		let value = this.GetAbility().GetSpecialValueFor("model_scale_bonus");
		return value * this.GetStackCount();
	}
}