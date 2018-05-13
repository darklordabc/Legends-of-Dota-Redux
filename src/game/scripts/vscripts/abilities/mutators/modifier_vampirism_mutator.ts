LinkLuaModifier("modifier_vampirism_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_vampirism_mutator extends CDOTA_Modifier_Lua {
  daytime_hp_drain:number;
  night_lifesteal:number;

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  //IsHidden() {return true;}

  OnCreated() {
    this.daytime_hp_drain = 1
    this.night_lifesteal = 20
  }

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
      modifierfunction.MODIFIER_EVENT_ON_ATTACK_LANDED,
    ]
  }

  GetModifierHealthRegenPercentage() {
    if (IsClient()) return 0;

    if (GameRules.IsDaytime()) return -1;
    return 0;
  }

  OnAttackLanded(kv:ModifierAttackEvent) {
    if (GameRules.IsDaytime()) return 0;

    if (this.GetParent() == kv.attacker && kv.target.IsAlive()) {
      if (!kv.target.IsOther() && !kv.target.IsBuilding()) {
        this.GetParent().Heal(kv.damage*this.night_lifesteal*0.01,this.GetParent());

        let p = ParticleManager.CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",ParticleAttachment_t.PATTACH_OVERHEAD_FOLLOW,this.GetParent());
        ParticleManager.ReleaseParticleIndex(p);
      }
    }
  }
}