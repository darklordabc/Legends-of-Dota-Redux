LinkLuaModifier("modifier_resurrection_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_resurrection_mutator extends CDOTA_Modifier_Lua {
  respawn_health_mana_pct:number;
  respawn_time_pct:number;

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_EVENT_ON_DEATH,
    ]
  }

  OnDeath(kv) {
    let killedUnit = this.GetParent();
    if (kv.unit == killedUnit) {
      let newItem = CreateItem( "item_tombstone", killedUnit.GetPlayerOwner(), killedUnit.GetPlayerOwner() );
      newItem.SetPurchaseTime( 0 );
      newItem.SetPurchaser( killedUnit );

      let tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} ) as CDOTA_Item_Physical;
      tombstone.SetContainedItem( newItem );
      tombstone.SetAngles( 0, RandomFloat( 0, 360 ), 0 );
      tombstone.SetAbsOrigin(killedUnit.GetAbsOrigin()) ;
      
    }

    
  }
}