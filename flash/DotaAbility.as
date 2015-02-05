package  {
	// Flash stuff
	import flash.display.MovieClip;

	// Other events
	import flash.events.MouseEvent;

	// Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class DotaAbility extends MovieClip {
		// The actual image looking thingo
		//public var ability:MovieClip;
		public var con:MovieClip;

		// The name of the ability in this slot
		public var skillName:String;

		public function DotaAbility() {
			// Grab the class
			/*var dotoClass:Class = getDefinitionByName("AbilityButton") as Class;

			// Create the ability
			ability = new dotoClass();
			addChild(ability);

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

			ability.scaleX = 4;
			ability.scaleY = 4;
			ability.y += 40;*/

			// Add the cover command
            this.addEventListener(MouseEvent.ROLL_OVER, lod.onSkillRollOver, false, 0, true);
            this.addEventListener(MouseEvent.ROLL_OUT, lod.onSkillRollOut, false, 0, true);
		}

		// Updates the ability stored inside
		public function setSkillName(abilityName:String):Boolean {
			// Only update if it is new
			if(skillName != abilityName) {
				// Add image
            	lod.Globals.LoadAbilityImage(abilityName, con);
            	//lod.Globals.LoadAbilityImage(abilityName, ability.AbilityArt);
            	con.scaleX = 102/128;
            	con.scaleY = 102/128;

            	//ability.abilityArt.scaleX = 100/128;
            	//ability.abilityArt.scaleY = 100/128;
            	// Store the name
				skillName = abilityName;

            	return true;
			}

			return false;
		}

		// Returns the ability in this slot
		public function getSkillName():String {
			return this.skillName;
		}
	}
}
