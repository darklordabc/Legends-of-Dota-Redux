package  {
	import flash.display.MovieClip;

	public class YourSkillList extends MovieClip {
		// Our skills
		public var skill0:MovieClip;
		public var skill1:MovieClip;
		public var skill2:MovieClip;
		public var skill3:MovieClip;
		public var skill4:MovieClip;
		public var skill5:MovieClip;

		public function YourSkillList(totalSlots:Number, totalSkills:Number, totalUlts:Number) {
			// Ensure valid values
			if(totalSlots < 4) {
				totalSlots = 4;
				trace('WARNING: Total slots was < 4');
			} else if(totalSlots > 6) {
				totalSlots = 6;
				trace('WARNING: total slots was > 6');
			}

			// Change the number of skills
			if(totalSlots <= 4) {
				this.gotoAndStop(1);
			} else if(totalSlots == 5) {
				this.gotoAndStop(2);
			} else {
				this.gotoAndStop(3);
			}

			// Change between skill and ulty
			for(var i:Number=0; i<totalSlots; i++) {
				var s:MovieClip = this['skill'+i];

				if(i < totalSkills) {
					if(i >= totalSlots - totalUlts) {
						s.skillType.text = '#either';
					} else {
						s.skillType.text = '#skill';
					}
				} else if(i >= totalSlots - totalUlts) {
					s.skillType.text = '#ult';
				} else {
					s.skillType.text = '#nothing';
				}
			}
		}
	}

}
