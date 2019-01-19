require("abilities/items/consumable_baseclass");

LinkLuaModifier('modifier_item_holy_locket_consumable',"abilities/items/holy_locket.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class item_holy_locket_consumable extends item_consumable_redux {
	GetIntrinsicModifierName() {
		return "modifier_item_holy_locket_consumable"
	}
}

class modifier_item_holy_locket_consumable extends CDOTA_Modifier_Lua {
	modifier:CDOTA_Buff
	IsHidden() {
		if (!this.GetAbility()) {
			//this.Destroy();
			return false;
		}
		return this.GetAbility().GetName() != "ability_consumable_item_container"
	}

	IsPermanent() {return true;}
	GetTexture() {return "item_holy_locket";}
	IsDebuff() {return false;}

	GetAttributes() { 
		return DOTAModifierAttribute_t.MODIFIER_ATTRIBUTE_MULTIPLE;
	}

	OnCreated() {
	}

	OnDestroy() {
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_HEALTH_BONUS,
			modifierfunction.MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			modifierfunction.MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		];
	}

	GetModifierHealthBonus() {
		if (!this.GetAbility()) {
		 	this.Destroy();
		 	return 0;
		}
		return this.GetAbility().GetSpecialValueFor("holy_locket_bonus_health");
	}

	GetModifierConstantHealthRegen() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("holy_locket_health_regen");
	}
	GetModifierConstantManaRegen() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("holy_locket_mana_regen");
	}
	GetModifierMagicalResistanceBonus() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("holy_locket_magic_resist");
	}
	GetModifierHPRegenAmplify_Percentage() {

		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		if (IsServer()) {
			let count = 0
			let parent = this.GetParent()
			for (let i = 0;i<parent.GetModifierCount();i++) {
				let modifier = parent.GetModifierNameByIndex(i)
				if (modifier == "modifier_item_holy_locket_consumable") {
					count++
				}
			}
			if (count > 1) {
				this.SetStackCount(count);
			}
		}
		if (this.GetStackCount() > 1) {
			return this.GetAbility().GetSpecialValueFor("holy_locket_heal_increase")/(this.GetStackCount());
		} else {
			return this.GetAbility().GetSpecialValueFor("holy_locket_heal_increase");
		}
		
	}
	
}
