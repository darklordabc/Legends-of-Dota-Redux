LinkLuaModifier("modifier_cooldown_reduction_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_cooldown_reduction_mutator extends CDOTA_Modifier_Lua {
  reduction_pct:number;
  mana_regen_pct:number;

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  OnCreated() {
    this.reduction_pct = 50;
    this.mana_regen_pct = 100;
  }

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
      modifierfunction.MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
    ]
  }

  GetModifierTotalPercentageManaRegen() {
    return this.mana_regen_pct
  }

  GetModifierPercentageCooldownStacking() {
    return this.reduction_pct
  }
}