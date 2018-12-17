//require('abilities/items/consumable_baseclass')
LinkLuaModifier("modifier_item_sange_kaya_yasha","abilities/items/sange_kaya_yasha.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sange_kaya_yasha_buffs","abilities/items/sange_kaya_yasha.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)

class item_sange_kaya_yasha_consumable extends item_consumable_redux {
	GetIntrinsicModifierName() { 
		return "modifier_item_sange_kaya_yasha";
	}
}

class modifier_item_sange_kaya_yasha_consumable extends CDOTA_Modifier_Lua {
	IsHidden() {
		if (!this.GetAbility()) {
			this.Destroy();
			return false;
		}
		return this.GetAbility().IsItem == null;
	}

	IsPermanent() {return true;}
	GetTexture() {return "item_sange_kaya_yasha";}

	GetAttributes() { 
		return DOTAModifierAttribute_t.MODIFIER_ATTRIBUTE_MULTIPLE
	}

	OnCreated() {
		if (IsServer()) {
			this.GetParent().AddNewModifier(this.GetParent(),this.GetAbility(),"modifier_item_sange_kaya_yasha_buffs",{})
		}
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			modifierfunction.MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			modifierfunction.MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			modifierfunction.MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			modifierfunction.MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		]
	}

	GetModifierBonusStats_Intellect() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_bonus_intellect")
	}

	GetModifierBonusStats_Agility() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_bonus_agility")
	}

	GetModifierBonusStats_Strength() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_bonus_strength")
	}

	GetModifierPreAttack_BonusDamage() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_bonus_damage")
	}

	GetModifierAttackSpeedBonus_Constant() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_bonus_attack_speed")
	}
}


class modifier_item_sange_kaya_yasha_consumable_buffs extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			modifierfunction.MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			modifierfunction.MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		]
	}

	GetModifierStatusResistanceStacking() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_status_resistance")
	}

	GetModifierMoveSpeedBonus_Percentage() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_movement_speed_percent_bonus")
	}

	GetModifierSpellAmplify_Percentage() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_spell_amp")
	}

	GetModifierPercentageManacostStacking() {
		if (!this.GetAbility()) {
			this.Destroy();
			return 0;
		}
		return this.GetAbility().GetSpecialValueFor("sange_kaya_yasha_manacost_reduction")
	}

	
}

// "item_recipe_sange_kaya_yasha_consumable"
//     {
//         // General
//         //-------------------------------------------------------------------------------------------------------------
//         "ID"                            "99997"                                                       // unique ID number for this item.  Do not change this once established or it will invalidate collected stats.
//         "Model"                         "models/props_gameplay/recipe.vmdl"
        
//         // Item Info
//         //-------------------------------------------------------------------------------------------------------------
//         "ItemCost"                      "0"   
//         "ItemShopTags"                  ""
        
//         // Recipe
//         //-------------------------------------------------------------------------------------------------------------
//         "ItemRecipe"                    "1"
//         "ItemResult"                    "item_sange_kaya_yasha_consumable"
//         "ItemRequirements"
//         {
            
//             "01"                        "item_sange_and_yasha;item_kaya"
//             "02"                        "item_kaya_and_sange;item_yasha"
//             "03"                        "item_yasha_and_kaya;item_sange"
//             "04"                        "item_sange;item_kaya;item_yasha"
//         }  
//     }
//     "item_sange_kaya_yasha_consumable"
//     {
//         "ID"                            "99998"
//         "ScriptFile"                    "abilities/items/sange_kaya_yasha.lua"
//         "AbilityTextureName"            "item_bloodstone"
//         "BaseClass"                     "item_lua"
//         "ItemCost"                      "6150"

//         "AbilityBehavior"               "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE"
//         "AbilityUnitTargetTeam"         "DOTA_UNIT_TARGET_TEAM_FRIENDLY"
//         "AbilityUnitTargetType"         "DOTA_UNIT_TARGET_HERO"
//         "AbilityGoldCost"               "6150"
//         "ItemPurchasable"              "0 "

         

