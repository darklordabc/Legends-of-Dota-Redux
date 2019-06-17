LinkLuaModifier('modifier_basic_bat',"abilities/basic_bat.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier('modifier_basic_bat_reduction',"abilities/basic_bat.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class basic_bat extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {return "modifier_basic_bat";}
}

class basic_bat_op extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {return "modifier_basic_bat";}
}

class basic_bat_reduction extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {return "modifier_basic_bat_reduction";}
}

class basic_bat_reduction_op extends CDOTA_Ability_Lua {
	GetIntrinsicModifierName() {return "modifier_basic_bat_reduction";}
}

class modifier_basic_bat extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	DeclareFunctions() {
		return [
		 	modifierfunction.MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		];
	}

	GetModifierBaseAttackTimeConstant() {
		return this.GetAbility().GetSpecialValueFor("new_bat");
	}

	
}
class modifier_basic_bat_reduction extends CDOTA_Modifier_Lua {
	IsPermanent() {return true;}
	IsHidden() {return true;}

	OnCreated() {
		if (IsServer()) {
			this.GetParent().AddNewModifier(this.GetParent(),null,"modifier_bat_manager",{})
		}
	}

	GetBATReductionConstant() {
		return -this.GetAbility().GetSpecialValueFor("new_bat")
	}

	
}
