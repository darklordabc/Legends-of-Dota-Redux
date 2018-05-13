LinkLuaModifier("modifier_random_spell_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
// Attach to a hidden neutral creature
class modifier_random_spell_mutator extends CDOTA_Modifier_Lua {
  random_spells: string[];
  cast_interval:number;
  warning_time:number;
  level_up_duration:number

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  CheckState() {
    return {
      [modifierstate.MODIFIER_STATE_INVISIBLE]:true,
      [modifierstate.MODIFIER_STATE_INVULNERABLE]:true,
      [modifierstate.MODIFIER_STATE_TRUESIGHT_IMMUNE]:true,
      [modifierstate.MODIFIER_STATE_NO_UNIT_COLLISION]:true,
    }
  }

  OnCreated() {
    if (IsClient()) return;

    this.level_up_duration = 5
    this.cast_interval = 60
    this.warning_time = this.cast_interval - 5
    this.random_spells = [
      "bloodseeker_rupture",
      "zuus_lightning_bolt",
      "invoker_sun_strike",
      "kunkka_torrent",
      "bounty_hunter_track",
      "ancient_apparition_cold_feet",
      "disruptor_glimpse",
      "rubick_telekinesis",
    ]

    let unit = this.GetParent();

    this.random_spells.forEach((spell) => {
      let ability = unit.AddAbility(spell);
      ability.SetLevel(1);
    })

    this.StartIntervalThink(1)
  }

  OnIntervalThink() {

    // Send warning
    if (Math.floor(GameRules.GetDOTATime(false,false) % 60) == this.warning_time) {
      let unit = this.GetParent();
      this.random_spells.forEach((spell) => {
        let ability = unit.FindAbilityByName(spell);
        ability.SetLevel(Math.min(Math.floor(GameRules.GetGameTime()/5),ability.GetMaxLevel()));
      })
    }

    // Fire spell
    if (Math.floor(GameRules.GetDOTATime(false,false) % 60) == this.cast_interval) {
      let unit = this.GetParent();
      let rnd = RandomInt(0,this.random_spells.length-1);
      let ability = unit.FindAbilityByName(this.random_spells[rnd]);

      let targets = FindUnitsInRadius(DOTATeam_t.DOTA_TEAM_GOODGUYS,Vector(0,0,0),null,10000,DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
      targets.forEach((hero)=>{
        // Decide action based on ability type
        if ((ability.GetBehavior() & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) {
          unit.SetCursorCastTarget(hero);
          ability.OnSpellStart();
        } else if ((ability.GetBehavior() & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) {
          unit.SetCursorPosition(hero.GetAbsOrigin());
          ability.OnSpellStart();
        } else if ((ability.GetBehavior() & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) {
          ability.OnSpellStart();
        }
      })

    }  
  }
}