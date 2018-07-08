LinkLuaModifier("modifier_redux_tower_ability", "abilities/pocket_tower.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);
require("abilities/builder")
class item_redux_pocket_tower extends builder {
	GetUnitName() {
		if (this.GetCaster().GetTeamNumber() == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
			return "npc_dota_goodguys_tower4";
		} else {
			return "npc_dota_badguys_tower4";
		}
	}

	OnBuildingPlaced(location:Vec,building:CDOTA_BaseNPC_Building) {
		building.AddNewModifier(this.GetCaster(), this, "modifier_redux_tower_ability", {});
		//@ts-ignore
		if (OptionManager.GetOption('strongTowers')) {
			//@ts-ignore
    		ingame.updateStrongTowers(building);
  		}

  		this.SetCurrentCharges(this.GetCurrentCharges()-1);
  		if (this.GetCurrentCharges() <= 0) {
  			this.Destroy()
  		}
	}
}