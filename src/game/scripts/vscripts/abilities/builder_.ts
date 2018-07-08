// This file should be used to edit the builder class and then saved as builder.lua instead of builder_.lua.
// In the lua file builder.new should return class(builder)	instead of instance.

class builder extends CDOTA_Item_Lua {
	/**
     * Override this function to change the sound
     */
	GetSoundName():string {
		return "Redux.PocketTower";
	}

	/**
     * Override this function to change the particles, they need to be executed here. Don't forget to release them!
     */
	PlayBuildParticle(location:Vec):void {
		let dust_pfx = ParticleManager.CreateParticle("particles/dev/library/base_dust_hit_detail.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null);
  		ParticleManager.SetParticleControl(dust_pfx, 0, location);
  		ParticleManager.ReleaseParticleIndex(dust_pfx);
	}

	 /**
     * Override this function to get the proper building.
     */
	GetUnitName():string {
		return "npc_dota_badguys_tower4";
	}

	/**
     * Use this to do stuff after the building has been created.
     */
	OnBuildingPlaced(location:Vec,building:CDOTA_BaseNPC_Building) {
	}

	CastFilterResultLocation(location) {
	  if (IsClient()) {
	    return UnitFilterResult.UF_SUCCESS;
	  } 
	  let buildings = FindUnitsInRadius(this.GetCaster().GetTeam(), location, null, 144, DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FindType_t.FIND_ANY_ORDER, false);
	  if (!GridNav.IsTraversable(location) || buildings.length  > 0 || this.GetCaster().IsPositionInRange(location, 144 + this.GetCaster().GetHullRadius()))
	    return UnitFilterResult.UF_FAIL_CUSTOM;
	  else
	    return UnitFilterResult.UF_SUCCESS;
	}
	GetCustomCastErrorLocation(location) {
		return "#dota_hud_error_no_buildings_here";
	}

	OnSpellStart() {
		let caster = this.GetCaster();
  		let location = this.GetCursorPosition();
  		let buildingName = this.GetUnitName();

  		let building = CreateUnitByName(buildingName,location,true,caster,caster.GetPlayerOwner(),caster.GetTeam()) as CDOTA_BaseNPC_Building;
  		building.SetOwner(caster);
  		building.SetOrigin(GetGroundPosition(location,building));
  		GridNav.DestroyTreesAroundPoint(location,building.GetHullRadius(),true);
  		building.RemoveModifierByName("modifier_invulnerable");
  		building.RemoveAbility("backdoor_protection_in_base");

  		this.PlayBuildParticle(location);
  		building.EmitSound(this.GetSoundName());

  		this.OnBuildingPlaced(location,building);
  		//@ts-ignore
		Timers.CreateTimer(0.01, () => {
			ResolveNPCPositions(location, 144);
		});
	}
}