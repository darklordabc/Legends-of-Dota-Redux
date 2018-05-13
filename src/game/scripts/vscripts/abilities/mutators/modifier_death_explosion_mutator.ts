LinkLuaModifier("modifier_death_explosion_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_death_explosion_mutator extends CDOTA_Modifier_Lua {
  damage_base:number;
  damage_per_level:number;
  aoe:number
  delay_ms:number;

  units : CDOTA_BaseNPC[];

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  OnCreated() {
    this.damage_base = 150;
    this.damage_per_level = 25;
    this.aoe = 300;
    this.delay_ms = 900;
  }

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_EVENT_ON_DEATH,
    ]
  }

  OnDeath(kv:ModifierAttackEvent) {
    //@ts-ignore
    if (this.GetParent() == kv.unit) {
      let p = ParticleManager.CreateParticle("particles/units/heroes/hero_undying/undying_tombstone_spawn.vpcf",ParticleAttachment_t.PATTACH_POINT,this.GetParent());
      ParticleManager.SetParticleControl(p,0,this.GetParent().GetAbsOrigin());
      ParticleManager.ReleaseParticleIndex(p);

      let damageTable:DamageTable = {
        damage: this.damage_base + (this.damage_per_level * this.GetParent().GetLevel()),
        attacker:this.GetParent(),
        victim:this.GetParent(), 
        damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
      }

      let units = FindUnitsInRadius(DOTATeam_t.DOTA_TEAM_NEUTRALS,this.GetParent().GetAbsOrigin(),null,this.aoe,DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
      units.forEach((unit)=>{
        damageTable.victim = unit;
        ApplyDamage(damageTable);
      })
    }
  }
}