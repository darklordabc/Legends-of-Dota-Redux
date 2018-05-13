LinkLuaModifier("modifier_killstreak_mutator_redux","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_killstreak_mutator_redux extends CDOTA_Modifier_Lua {
  damage_multiplier:number;

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return false;}

  OnCreated() {
    this.damage_multiplier = 20
  }

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
      modifierfunction.MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
      modifierfunction.MODIFIER_PROPERTY_MODEL_SCALE,
      modifierfunction.MODIFIER_EVENT_ON_DEATH,
    ]
  }



  OnDeath(kv) {
    if (this.GetParent() == kv.unit) {
      this.SetStackCount(0);
    } else if (this.GetParent() == kv.attacker) {
      this.IncrementStackCount();
    }
  }

  GetModifierIncomingDamage_Percentage() {
    if (IsClient()) { 
      return 0;
    }
    let unit = this.GetParent();

    if (unit.PassivesDisabled() || unit.IsIllusion()) {
      return 0;
    }

    let killStreak = this.GetStackCount();
    return this.damage_multiplier * killStreak;


  }

  GetModifierDamageOutgoing_Percentage() {
    if (IsClient()) { 
      return 0;
    }

    let unit = this.GetParent();

    if (unit.PassivesDisabled() || unit.IsIllusion()) {
      return 0;
    }

    let killStreak = this.GetStackCount();
    return this.damage_multiplier * killStreak;

  }

  GetModifierModelScale() {
    return 1 + (this.damage_multiplier  * this.GetStackCount())
  }

}