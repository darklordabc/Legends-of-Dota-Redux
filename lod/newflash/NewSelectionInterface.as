package  {
    import flash.events.MouseEvent;
	import flash.display.MovieClip;
    import flash.text.TextField;

	public class NewSelectionInterface extends MovieClip {
		// Container for the skills
		public var skillCon:MovieClip;

        // Container for hero icons
        public var heroCon:MovieClip;

        // The banning area
        public var banningArea:MovieClip;

        // Your skill list
        public var yourSkillList:MovieClip;

        // Combo boxes
        public var comboBehavior:MovieClip;
        public var comboType:MovieClip;
        public var comboDamageType:MovieClip;
        public var comboTab:MovieClip;

        // The toggle interface text
        public var toggleInterfaceText:TextField;

        // The timer
        public var timerField:TextField;

		// Stores tabs
		private var tabList:Object;

		// Defining how to layout skills
        private static var X_SECTIONS = 3;      // How many sections in the x direction
        private static var Y_SECTIONS = 2;      // How many sections in the y direction

        private static var X_PER_SECTION = 7;   // How many skill lists in each x section
        private static var Y_PER_SECTION = 3;   // How many skill lists in each y section

        // How big a SelectSkillList is
        private static var SL_WIDTH = 43;
        private static var SL_HEIGHT = 43;

        // How much padding to put between each list
        private static var S_PADDING = 2;

        // Active list of skills (key = skill name)
        private var activeList:Object = {};

        // The names of tabs
        var tabNames:Array;

		public function NewSelectionInterface() {
            // Make the toggle interface text work
            toggleInterfaceText.addEventListener(MouseEvent.CLICK, toggleHeroIcons);
		}

        public function hideUncommonStuff():void {
            banningArea.visible = false;
            yourSkillList.visible = false;
        }

		// Rebuilds the interface from scratch
		public function Rebuild(newTabNames:Array, newSkillList:Object, source1:Boolean, banningDropCallback:Function) {
            var tabName:String;

            // Disable hero input on the hero icons
            heroCon.mouseEnabled = false;
            heroCon.mouseChildren = false;

            // Allow dropping to the banning area
            EasyDrag.dragMakeValidTarget(banningArea, banningDropCallback);

            // Setup comboboxes
            comboBehavior.setComboBoxSlots([
                '#By_Behavior',
                '#DOTA_ToolTip_Ability_NoTarget',
                '#DOTA_ToolTip_Ability_Target',
                '#DOTA_ToolTip_Ability_Point',
                '#DOTA_ToolTip_Ability_Channeled',
                '#DOTA_ToolTip_Ability_Passive',
                '#DOTA_ToolTip_Ability_Aoe',
                '#DOTA_ToolTip_Ability_Toggle'
            ]);

            comboType.setComboBoxSlots([
                '#By_Type',
                '#Ability',
                '#Ultimate'
            ]);

            comboDamageType.setComboBoxSlots([
                '#By_Damage_Type',
                '#Magical_Damage',
                '#Physical_Damage'
            ]);

            // Build tabs combo
            tabNames = newTabNames;
            comboTab.setComboBoxSlots(tabNames);
            comboTab.setIndexCallback(onTabChanged);

            // Calculate settings
			var singleWidth:Number = X_PER_SECTION*(SL_WIDTH + S_PADDING);
            var totalWidth:Number = X_SECTIONS * singleWidth - S_PADDING;

            var singleHeight:Number = Y_PER_SECTION*(SL_HEIGHT + S_PADDING);
            var totalHeight:Number = Y_SECTIONS * singleHeight - S_PADDING;

            var useableHeight:Number = 320;

            var workingWidth:Number = 1024 - 64;
            skillCon.x = -workingWidth/2;
            heroCon.x = -workingWidth/2;

            var gapSizeX:Number = (workingWidth-totalWidth) / (X_SECTIONS-1);
            var gapSizeY:Number = (useableHeight-totalHeight) / (Y_SECTIONS-1);

            var gapSize:Number = Math.min(gapSizeX, gapSizeY);

            // New active list
            activeList = {};

            // New tab list
            tabList = {};

            // Empty the skill container
            Util.empty(skillCon);

            // Loop over all the possible tabs
            for(tabName in newSkillList) {
            	// Check if the tab is allowed
            	if(!lod.isTabAllowed(tabName)) continue;

            	// Grab the tab
            	var currentTab:Object = newSkillList[tabName];

                // The skill we are upto in our skill list
                var skillNumber:Number = 0;

                // Create the new tab
                var tab:MovieClip = new MovieClip();
                skillCon.addChild(tab);

                var heroTab:MovieClip = new MovieClip();
                heroCon.addChild(heroTab);

                // Store the tab
                tabList[tabName] = {
                    tab: tab,
                    heroTab: heroTab
                };

                for(var k=0;k<Y_SECTIONS;k++) {
                    for(var l=0; l<Y_PER_SECTION; l++) {
                        for(var i=0;i<X_SECTIONS;i++) {
                            for(var j=0; j<X_PER_SECTION; j++) {
                                // Create new skill list
                                var sl = new SelectSkillList();
                                tab.addChild(sl);
                                sl.x = i*(singleWidth+gapSize) + j*(SL_WIDTH+S_PADDING);
                                sl.y = k*(singleHeight+gapSize) + l*(SL_HEIGHT+S_PADDING);

                                // See if there is a header image for this slot
                                sl.setHeroImage(currentTab['hero_' + skillNumber]);

                                // Store the hero image
                                if(sl.heroImage.visible) {
                                    // Move onto hero icons layer
                                    heroTab.addChild(sl.heroImage);
                                    sl.heroImage.x = i*(singleWidth+gapSize) + j*(SL_WIDTH+S_PADDING);
                                    sl.heroImage.y = k*(singleHeight+gapSize) + l*(SL_HEIGHT+S_PADDING);
                                }

                                for(var a=0; a<4; a++) {
                                    // Grab the slot
                                    var skillSlot = sl['skill'+a];

                                    // Grab a new skill
                                    var skill = currentTab[skillNumber++];

                                    // Source1 skill list
                                    if(source1) {
                                        var skill1 = currentTab[(skillNumber-1)+'_s1'];
                                        if(skill1 != null) {
                                            skill = skill1;
                                        }
                                    }

                                    if(skill && skill != '') {
                                        var skillSplit = skill.split('||');

                                        if(skillSplit.length == 1) {
                                        	// Ensure valid skill
                                        	if(lod.isValidSkill(skill)) {
                                        		// Put the skill into the slot
	                                            skillSlot.setSkillName(skill);

	                                            // Hook dragging
	                                            EasyDrag.dragMakeValidFrom(skillSlot, lod.skillSlotDragBegin);

	                                            // Store into the active list
	                                            activeList[skill] = skillSlot;
                                        	}
                                        } else {
                                            // Remove the slot
                                            sl.removeChild(skillSlot);

                                            // Loop over all the spells in this bundle
                                            /*for(var splitLength:Number=0;splitLength<skillSplit.length;splitLength++) {
                                                msk = new SelectSkillsSplit(1+splitLength, skillSplit.length);
                                                sl.addChild(msk);

                                                // Create the new skill slot
                                                skillSlot2 = new SelectSkill();
                                                skillSlot2.mask = msk;
                                                sl.addChild(skillSlot2);
                                                skillSlot2.x = skillSlot.x;
                                                skillSlot2.y = skillSlot.y;
                                                msk.x = skillSlot.x;
                                                msk.y = skillSlot.y;

                                                // Put the skill into the slot
                                                skillSlot2.setSkillName(skillSplit[splitLength]);

                                                skillSlot2.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                                                skillSlot2.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

                                                // Hook dragging
                                                EasyDrag.dragMakeValidFrom(skillSlot2, skillSlotDragBegin);

                                                // Store into the active list
                                                activeList[skillSplit[splitLength]] = skillSlot2;

                                                // Fix the lists
                                                completeList[-(skillNumber-1+splitLength*1000)] = skillSplit[splitLength];
                                            }*/
                                        }
                                    } else {
                                        // Remove the slot
                                        sl.removeChild(skillSlot);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Change to the main tab
            setActiveTab('main');
		}

        // Setups the skill list
        public function setupSkillList(totalSlots:Number, slotInfo:String, dropCallback:Function):void {
            this.yourSkillList.setup(totalSlots, slotInfo, dropCallback);
        }

        // Puts a skill into a slot
        public function skillIntoSlot(slotNumber:Number, skillName:String):Boolean {
            return this.yourSkillList.skillIntoSlot(slotNumber, skillName);
        }

        // We have swapped two slots
        public function onSlotSwapped(slot1:Number, slot2:Number):void {
            yourSkillList.onSlotSwapped(slot1, slot2);
        }

        // Changes the tab
        public function setActiveTab(tab:String):void {
            // Set any tab that has a different name to `tab` to invisible
            // Makes the given tab visible
            for(var tabName:String in tabList) {
                if(tabName == tab) {
                    tabList[tabName].tab.visible = true;
                    tabList[tabName].heroTab.visible = true;
                } else {
                    tabList[tabName].tab.visible = false;
                    tabList[tabName].heroTab.visible = false;
                }
            }
        }

        // Called when the tab selector changes
        public function onTabChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            // Change tabs
            setActiveTab(tabNames[i]);
        }

        // Toggles the hero icons on/off
        public function toggleHeroIcons():void {
            // Invert container
            heroCon.visible = !heroCon.visible;
        }
	}

}
