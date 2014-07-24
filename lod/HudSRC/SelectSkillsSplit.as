package  {
	import flash.display.MovieClip;

	public class SelectSkillsSplit extends MovieClip {
		public function SelectSkillsSplit(slot:Number, total:Number) {
            // More options will be here in the future
            this.gotoAndStop(slot);
		}
	}

}
