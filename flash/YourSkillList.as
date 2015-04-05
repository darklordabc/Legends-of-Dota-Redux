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
        public var skill6:MovieClip;
        public var skill7:MovieClip;
        public var skill8:MovieClip;
        public var skill9:MovieClip;
        public var skill10:MovieClip;
        public var skill11:MovieClip;
		public var skill12:MovieClip;

		public function YourSkillList() {
			this.gotoAndStop(1);
		}

		public function setup(totalSlots:Number, slotInfo:String, dropCallback:Function, keyBindings:Array, checkTarget:Function, newInterface:Number):void {
			// Ensure valid values
			if(totalSlots < 4) {
				totalSlots = 4;
				trace('WARNING: Total slots was < 4');
			} else if(totalSlots > 12) {
				totalSlots = 12;
				trace('WARNING: total slots was > 12');
			}

            // TEMP, remap 7-11 --> 12
            if(totalSlots >= 7 && totalSlots <= 11) totalSlots = 12;

			// Change the number of skills
			this.gotoAndStop(totalSlots - 3);

            // Validate slot info
            if(slotInfo == null) slotInfo = '';

			// Set the sorts of slots they are
			for(var i=0; i<totalSlots; i++) {
				// Grab the character for this slot
				var char:String = slotInfo.charAt(i);

				// Grab the slot
				var s:MovieClip = this['skill'+i];

                s.hotKey.text = keyBindings[i];

				// Set the slot number
				s.setSkillSlot(newInterface, i);

				// Allow dropping
            	EasyDrag.dragMakeValidTarget(s, dropCallback, checkTarget);

            	// Allow dropping
            	EasyDrag.dragMakeValidFrom(s, skillSlotDragBegin);

                // Set the slot type
                s.setSlotType(char);
			}
		}

		// Puts a skill into a slot
		public function skillIntoSlot(slotNumber:Number, skillName:String):Boolean {
			// Grab the slot
			var s:MovieClip = this['skill'+slotNumber];

			// Ensure it exists
			if(s != null) {
				// Set the skill in the slot
				return s.setSkillName(skillName);
			}

			return false;
		}

		// We have swapped two slots
        public function onSlotSwapped(slot1:Number, slot2:Number):void {
        	// Grab both slots
            var s1:MovieClip = this['skill'+slot1];
            var s2:MovieClip = this['skill'+slot2];

            // Ensure they both exist
            if(s1 != null && s2 != null) {
            	// Swap the texts on them
            	var tmpText:String = s1.getSlotType();
            	s1.setSlotType(s2.getSlotType());
            	s2.setSlotType(tmpText);
            }
        }

        // Slot swapping
		private function skillSlotDragBegin(me:MovieClip, dragClip:MovieClip):Boolean {
            // Grab the name of the skill
            var skillName = me.getSkillName();

            // Load a skill into the dragClip
            lod.Globals.LoadAbilityImage(skillName, dragClip);

            // Store the skill
            dragClip.slotNumber = me.getSkillSlot();

            // Store that it is a skill drag
            dragClip.dragType = lod.DRAG_TYPE_SLOT;

            // Enable dragging
            return true;
        }

        // Returns the skill in the given slot
        public function getSkillInSlot(slotNumber:Number):String {
            var s = this['skill'+slotNumber];
            if(s != null) {
            	return s.getSkillName();
            }

            return 'nothing';
        }
	}
}
