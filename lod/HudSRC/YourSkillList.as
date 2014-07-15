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

		public function YourSkillList(totalSkills:Number, totalUlts:Number) {
			// Ensure valid values
			if(totalSkills < 4) {
				totalSkills = 4;
				trace('WARNING: Total skills was < 4');
			} else if(totalSkills > 6) {
				totalSkills = 6;
				trace('WARNING: total skills was > 6');
			}

			// Change the number of skills
			if(totalSkills <= 4) {
				this.gotoAndStop(1);
			} else if(totalSkills == 5) {
				this.gotoAndStop(2);
			} else {
				this.gotoAndStop(3);
			}

			// Change between skill and ulty
			var skills = 0;
			for(var i:Number=0; i<totalSkills; i++) {
				var s:MovieClip = this['skill'+i];

				if(skills++ < totalSkills - totalUlts) {
					s.gotoAndStop(1);
				} else {
					s.gotoAndStop(2);
				}
			}
		}
	}

}
