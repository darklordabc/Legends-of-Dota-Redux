LinkLuaModifier("modifier_redux_tower_ability", "abilities/pocket_tower.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);

ListenToGameEvent("entity_killed",(keys) => {
	
	//@ts-ignore
	if (OptionManager.GetOption('convertableTowers') == 0){
		return;
	}

	let building = EntIndexToHScript(keys.entindex_killed) as CDOTA_BaseNPC;
	if (building.IsTower && building.IsTower()) {
		let buildingName:string = building.GetUnitName();
		let teamNumber:DOTATeam_t;
		if (building.GetTeamNumber() == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
			buildingName = buildingName.replace("goodguys","badguys");
			teamNumber=DOTATeam_t.DOTA_TEAM_BADGUYS;
		} else {
			buildingName = buildingName.replace("badguys","goodguys");
			teamNumber=DOTATeam_t.DOTA_TEAM_GOODGUYS;
		}
		let newTower = CreateUnitByName(buildingName,building.GetAbsOrigin(),true,null,null,teamNumber) as CDOTA_BaseNPC_Building;
  		newTower.SetOrigin(GetGroundPosition(building.GetAbsOrigin(),newTower));
  		newTower.RemoveModifierByName("modifier_invulnerable");
  		if (newTower.HasAbility("backdoor_protection_in_base")) {
  			newTower.RemoveAbility("backdoor_protection_in_base");
  		}
  		building.AddNewModifier(null, null, "modifier_redux_tower_ability", {});

  		let dust_pfx = ParticleManager.CreateParticle("particles/dev/library/base_dust_hit_detail.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null);
  		ParticleManager.SetParticleControl(dust_pfx, 0, building.GetAbsOrigin());
  		ParticleManager.ReleaseParticleIndex(dust_pfx);

  		building.EmitSound("Redux.PocketTower");

  		//@ts-ignore
		Timers.CreateTimer(FrameTime(), () => {
			ResolveNPCPositions(building.GetAbsOrigin(), 144);
		});
	}
},null);