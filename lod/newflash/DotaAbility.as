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
			ability.removeChild(ability.levelUp);
			ability.removeChild(ability.activeDownType);
			ability.removeChild(ability.activePressedType);
			ability.removeChild(ability.activeCastType);
			ability.removeChild(ability.unlearnedState);
			ability.removeChild(ability.enemyState);
			ability.removeChild(ability.passiveDownType);
			ability.removeChild(ability.noManaState);
			ability.removeChild(ability.cooldownLabel);
			ability.removeChild(ability.autocast);
			ability.removeChild(ability.cooldownEnd);
			ability.removeChild(ability.silencedState);
			ability.removeChild(ability.cooldownSwipe);
			ability.removeChild(ability.overState);
			ability.removeChild(ability.autocastable);
			//ability.removeChild(ability.passiveType);
			//ability.removeChild(ability.activeType);*/

			// Add the cover command
            this.addEventListener(MouseEvent.ROLL_OVER, lod.onSkillRollOver, false, 0, true);
            this.addEventListener(MouseEvent.ROLL_OUT, lod.onSkillRollOut, false, 0, true);
		}

		// Updates the ability stored inside
		public function setSkillName(abilityName:String):Boolean {
			// Only update if it is new
			if(skillName != abilityName) {
				// Add image
            	//lod.Globals.LoadAbilityImage(abilityName, ability.AbilityArt);
            	lod.Globals.LoadAbilityImage(abilityName, con);
            	con.scaleX = 100/128;
            	con.scaleY = 100/128;

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
