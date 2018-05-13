LinkLuaModifier("modifier_drop_gold_bag_mutator","",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class modifier_drop_gold_bag_mutator extends CDOTA_Modifier_Lua {

  IsPermanent() {return true;}
  IsPurgable() {return false;}
  IsHidden() {return true;}

  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_EVENT_ON_DEATH,
    ]
  }

  OnDeath(kv:ModifierAttackEvent) {
    //@ts-ignore
    if (this.GetParent() == kv.unit) {
      let newItem = CreateItem("item_bag_of_gold",null,null);
      newItem.SetAbsOrigin(this.GetParent().GetAbsOrigin());
    }
  }
}