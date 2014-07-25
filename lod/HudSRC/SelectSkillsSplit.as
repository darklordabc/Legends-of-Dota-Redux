package  {
	import flash.display.MovieClip;

	public class SelectSkillsSplit extends MovieClip {
		public function SelectSkillsSplit(slot:Number, total:Number) {
            // Ajdust to correct frame
            if(total == 3) {
                slot += 2;
            }
            if(total == 4) {
                slot += 5;
            }
            // More options will be here in the future
            this.gotoAndStop(slot);
		}
	}

}
