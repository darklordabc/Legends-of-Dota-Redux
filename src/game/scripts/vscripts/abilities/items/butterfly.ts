require("abilities/items/consumable_baseclass");

LinkLuaModifier('modifier_item_butterfly_consumable',"abilities/items/butterfly.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class item_butterfly_consumable extends item_consumable_redux {
	GetIntrinsicModifierName() {
		return "modifier_item_butterfly_consumable"
	}
}

class modifier_item_butterfly_consumable extends CDOTA_Modifier_Lua {
	IsHidden() {
		if (!this.GetAbility()) {
			//this.Destroy();
			return false;
		}
		return this.GetAbility().GetName() != "ability_consumable_item_container"
	}

	IsPermanent() {return true;}
	GetTexture() {return "item_butterfly";}
	IsDebuff() {return false;}

	GetAttributes() { 
		return DOTAModifierAttribute_t.MODIFIER_ATTRIBUTE_MULTIPLE;
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			modifierfunction.MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			modifierfunction.MODIFIER_PROPERTY_EVASION_CONSTANT,
		];
	}

	GetModifierBonusStats_Agility() {
		if (!this.GetAbility()) {
		 	this.Destroy();
		 	return 0;
		}
		return this.GetAbility().GetSpecialValueFor("butterfly_bonus_agility");
	}

	GetModifierAttackSpeedBonus_Constant() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("butterfly_bonus_attack_speed");
	}
	GetModifierEvasion_Constant() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("butterfly_bonus_evasion");
	}
	GetModifierPreAttack_BonusDamage() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("butterfly_bonus_damage");
	}
}