package  {

	import flash.display.MovieClip;

	// Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class DotaAbility extends MovieClip {
		// The actual image looking thingo
		public var ability:MovieClip;

		// The name of the ability in this slot
		public var skillName:String;

		public function DotaAbility(abilityName) {
			// Grab the class
			var dotoClass:Class = getDefinitionByName("AbilityButton") as Class;

			// Create the ability
			ability = new dotoClass();
			addChild(ability);

			// Store the name
			skillName = abilityName;

			// Reset filters
			ability.AbilityArt.filters = [];

			// Hide useless stuff
			ability.levelUp.visible = false;
			ability.activeDownType.visible = false;
			ability.activePressedType.visible = false;
			ability.activeCastType.visible = false;
			ability.unlearnedState.visible = false;
			ability.enemyState.visible = false;
			ability.passiveDownType.visible = false;
			ability.noManaState.visible = false;
			ability.cooldownLabel.visible = false;
		}
	}

}
