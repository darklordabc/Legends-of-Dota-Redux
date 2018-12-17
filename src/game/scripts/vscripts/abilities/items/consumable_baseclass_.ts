// Example
/* You only need to make the modifier and declare it with GetIntrinsicModifier()
Require this file
require("abilities/items/consumable_baseclass")
LinkLuaModifier("modifier_my_modifier",abilities/items/MYFILE.lua",LUA_MODIFIER_MOTION_NONE)
// LUA
function item_my_item_consumable:GetIntrinsicModifierName()
	return "modifier_my_modifier"
end

//TS

class item_my_item_consumable extends item_consumable {
	GetIntrinsicModifierName() { 
		return "modifier_my_modifier";
	}
}

*/

class item_consumable_redux extends CDOTA_Item_Lua {
	
	//GetIntrinsicModifierName() { 
	//	return "";
	//}




	OnSpellStart() {
		this.ConsumeItem(this.GetCaster());
	}
	CastFilterResultTarget(target) {
		if (this.GetCaster() != target) {
			return UnitFilterResult.UF_FAIL_CUSTOM;
		}
		if (IsServer()) {
			let name = this.GetIntrinsicModifierName();
			let ab:CDOTABaseAbility;
			if (!this.GetCaster().HasAbility("ability_consumable_item_container")) {
				ab = this.GetCaster().AddAbility("ability_consumable_item_container");
				ab.SetLevel(1);
				ab.SetHidden(true);
			}
			ab = ab ? ab : this.GetCaster().FindAbilityByName("ability_consumable_item_container");
			if (!ab || ab[name]) {
				return UnitFilterResult.UF_FAIL_CUSTOM;
			}
			return UnitFilterResult.UF_SUCCESS;
		}
		return UnitFilterResult.UF_SUCCESS;
	}

	GetCustomCastErrorTarget(target) {
		if (this.GetCaster() != target) {
   			return "#consumable_items_only_self";
  		}
  		let ab  = this.GetCaster().FindAbilityByName("ability_consumable_item_container")
	  	if (!ab) {
	    	return "#consumable_items_no_available_slot";
	  	}
	  	let name = this.GetIntrinsicModifierName()
	  	if (ab[name]) {
	    	return "#consumable_items_already_consumed";
	  	}
	}

	ConsumeItem(caster){
		let name = this.GetIntrinsicModifierName()
		if (!this.GetCaster().HasAbility("ability_consumable_item_container")) {
			let ab = this.GetCaster().AddAbility("ability_consumable_item_container");
		    ab.SetLevel(1);
		    ab.SetHidden(true);
		}

		let ab = this.GetCaster().FindAbilityByName("ability_consumable_item_container");
		if (ab && !ab[name]) {
			caster.RemoveItem(this);
			caster.RemoveModifierByName(name);
			let modifier = caster.AddNewModifier(caster,ab,name,{});
			ab[name] = true;
		}
	}
}
