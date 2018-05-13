LinkLuaModifier("modifier_no_healthbar_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_no_healthbar_mutator extends CDOTA_Modifier_Lua {
  reduction_pct:number;
  mana_regen_pct:number;

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  CheckState() {
    return {
      [modifierstate.MODIFIER_STATE_NO_HEALTH_BAR] : true,
    }
  }
}