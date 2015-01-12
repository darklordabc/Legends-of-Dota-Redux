package  {
	// Flash stuff
	import flash.display.MovieClip;

	// Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class HeroImage extends MovieClip {
		// Container for the hero image
		public var heroImage:MovieClip;

		// The ability container
		public var ability:MovieClip;

		public function HeroImage() {
			// Grab the class
			var dotoClass:Class = getDefinitionByName("AbilityButton") as Class;

			// Create the ability
			ability = new dotoClass();
			heroImage.addChild(ability);

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

			ability.scaleX = 71/128;
			ability.scaleY = 71/128;

			//ability.AbilityArt.scaleX = 128/71;
			//ability.AbilityArt.scaleY = 128/71;
		}

		// Change the image
		public function setHeroImage(newImage:String):void {
			// Load the hero image
			lod.Globals.LoadImageWithCallback('images/heroes/selection/' + newImage + '.png', ability.AbilityArt, false, function(bitmap) {
				// Rescale the bitmap
				var newScale = 128/bitmap.width;

				bitmap.scaleX = newScale;
				bitmap.scaleY = newScale;
			});
		}
	}
}
