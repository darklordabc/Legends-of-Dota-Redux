class modifier_sled_penguin_passive_redux extends CDOTA_Modifier_Lua {
	IsHidden() {return !IsInToolsMode();}
	IsPurgable() { return false;}

	OnCreated(kv) {
		if (IsServer()) {
			let parent = this.GetParent();
			let penguin = CreateUnitByName("npc_dummy_unit_imba",parent.GetAbsOrigin(),true,parent,parent.GetPlayerOwner(),parent.GetTeamNumber());
			parent.parentPenguin = penguin;
			//@ts-ignore
			penguin.hero = parent
			let ability = penguin.AddAbility("sled_penguin_passive");
			ability.SetLevel(this.GetAbility().GetLevel());
			
			//penguin.SetModel("models/creeps/ice_biome/penguin/penguin.vmdl");
			penguin.SetModelScale(2);
			FindClearSpaceForUnit(penguin,penguin.GetAbsOrigin(),true);
			penguin.SetForwardVector(parent.GetForwardVector());

			parent.AddNewModifier(penguin,ability,"modifier_sled_penguin_movement",{});
			penguin.AddNewModifier(penguin,ability,"modifier_sled_penguin_movement",{});

			this.StartIntervalThink(FrameTime());
		}

		
	}

	OnIntervalThink() {
		if (this.GetParent().IsStunned()) {
			this.GetAbility().ToggleAbility();
		}
	}
	OnUpgrade(kv) {
		this.OnDestroy();
		this.OnCreated(kv);
	}

	OnDestroy() {
		if (IsServer()) {
			let parent = this.GetParent();
			parent.RemoveModifierByName("modifier_sled_penguin_movement")
			parent.parentPenguin.RemoveSelf();
			parent.parentPenguin = null;
		}
	}
}