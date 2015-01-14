package  {
    import flash.events.MouseEvent;
	import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.events.Event;

	public class NewSelectionInterface extends MovieClip {
		// Container for the skills
		public var skillCon:MovieClip;

        // Container for hero icons
        public var heroCon:MovieClip;

        // The banning area
        public var banningArea:MovieClip;

        // The random skill Icon
        public var randomSkill:MovieClip;

        // Your skill list
        public var yourSkillList:MovieClip;

        // Container for the tabs up the top
        public var tabButtonCon:MovieClip;

        // Combo boxes
        public var comboBehavior:MovieClip;
        public var comboType:MovieClip;
        public var comboDamageType:MovieClip;

        // Search box
        public var searchBox:MovieClip;

        // The toggle interface text
        public var toggleInterfaceText:TextField;

        // The timer
        public var timerField:TextField;

		// Stores tabs
		private var tabList:Object;

        // Stores the skillKV
        private var skillKV:Object;

        // The search filters
        private var filterText:String = '';
        private var filter1:Number = 0;
        private var filter2:Number = 0;
        private var filter3:Number = 0;

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

		public function NewSelectionInterface() {
            // Make the toggle interface text work
            toggleInterfaceText.addEventListener(MouseEvent.CLICK, toggleHeroIcons);
            toggleInterfaceText.autoSize = "right";
		}

        public function hideUncommonStuff():void {
            banningArea.visible = false;
            yourSkillList.visible = false;
        }

		// Rebuilds the interface from scratch
		public function Rebuild(newTabNames:Array, newSkillList:Object, source1:Boolean, banningDropCallback:Function) {
            var tabName:String, i:Number;

            // Reload the skillKV
            skillKV = lod.Globals.GameInterface.LoadKVFile('scripts/npc/npc_abilities.txt');

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
            comboBehavior.setIndexCallback(onComboBehaviorChanged);

            comboType.setComboBoxSlots([
                '#By_Type',
                '#Ability',
                '#Ultimate'
            ]);
            comboType.setIndexCallback(onComboTypeChanged);

            comboDamageType.setComboBoxSlots([
                '#By_Damage_Type',
                '#Magical_Damage',
                '#Physical_Damage'
            ]);
            comboDamageType.setIndexCallback(onComboDamageTypeChanged);

            // Do the tabs
            Util.empty(tabButtonCon);
            for(i=0; i<newTabNames.length; ++i) {
                var tabBtn:MovieClip = Util.smallButton(tabButtonCon, '#tab_' + newTabNames[i]);
                tabBtn.x = (tabBtn.width + 8) * i;
                tabBtn.y = 0;

                // Hook up the button
                (function() {
                    var ourCurrentTab:String = newTabNames[i];
                    tabBtn.addEventListener(MouseEvent.CLICK, function() {
                        setActiveTab(ourCurrentTab);
                    });
                })();
            }

            // Hook up the search box
            searchBox.initSearchbox();
            searchBox.addEventListener(Event.CHANGE, onSearchTextChanged);

            // Hook the random skill
            EasyDrag.dragMakeValidFrom(randomSkill, lod.skillSlotDragBegin);
            randomSkill.setSkillName('random');

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

                for(var k:Number=0;k<Y_SECTIONS;k++) {
                    for(var l:Number=0; l<Y_PER_SECTION; l++) {
                        for(i=0;i<X_SECTIONS;i++) {
                            for(var j:Number=0; j<X_PER_SECTION; j++) {
                                // Create new skill list
                                var sl:MovieClip = new SelectSkillList();
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

                                for(var a:Number=0; a<4; a++) {
                                    // Grab the slot
                                    var skillSlot:MovieClip = sl['skill'+a];

                                    // Grab a new skill
                                    var skill:String = currentTab[skillNumber++];

                                    // Source1 skill list
                                    if(source1) {
                                        var skill1 = currentTab[(skillNumber-1)+'_s1'];
                                        if(skill1 != null) {
                                            skill = skill1;
                                        }
                                    }

                                    if(skill && skill != '') {
                                        var skillSplit:Array = skill.split('||');

                                        if(skillSplit.length == 1) {
                                        	// Ensure valid skill
                                        	if(lod.isValidSkill(skill)) {
                                        		// Put the skill into the slot
	                                            skillSlot.setSkillName(skill);

	                                            // Hook dragging
	                                            EasyDrag.dragMakeValidFrom(skillSlot, lod.skillSlotDragBegin);

	                                            // Store into the active list
	                                            activeList[skill] = skillSlot;
                                        	} else {
                                                // Remove the slot
                                                sl.removeChild(skillSlot);
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

        // Updates the filtered skills
        public function updateFilters() {
            // Grab translation function
            var trans:Function = lod.Globals.GameInterface.Translate;
            var prefix = '#DOTA_Tooltip_ability_';

            // Workout how many filters to use
            var totalFilters:Number = 0;
            if(filterText != '')    totalFilters++;
            if(filter1 > 0)         totalFilters++;
            if(filter2 > 0)         totalFilters++;
            if(filter3 > 0)         totalFilters++;

            // Declare vars
            var skill:Object;

            // Search abilities for this key word
            for(var key in activeList) {
                // Check for valid drafting skills
                if(!lod.isValidDraftSkill(key)) {
                    activeList[key].visible = false;
                    continue;
                }

                var doShow:Number = 0;

                // Behavior filter
                if (filter1 > 0) {
                    // Check if we have info on this skill
                    skill = skillKV[key];
                    if(skill && skill.AbilityBehavior) {
                        var b:String = skill.AbilityBehavior;

                        // Check filters
                        if(filter1 == 1 && b.indexOf('DOTA_ABILITY_BEHAVIOR_NO_TARGET') != -1)      doShow++;
                        if(filter1 == 2 && b.indexOf('DOTA_ABILITY_BEHAVIOR_UNIT_TARGET') != -1)    doShow++;
                        if(filter1 == 3 && b.indexOf('DOTA_ABILITY_BEHAVIOR_POINT') != -1)          doShow++;
                        if(filter1 == 4 && b.indexOf('DOTA_ABILITY_BEHAVIOR_CHANNELLED') != -1)     doShow++;
                        if(filter1 == 5 && b.indexOf('DOTA_ABILITY_BEHAVIOR_PASSIVE') != -1)        doShow++;
                        if(filter1 == 6 && b.indexOf('DOTA_ABILITY_BEHAVIOR_AOE') != -1)            doShow++;
                        if(filter1 == 7 && b.indexOf('DOTA_ABILITY_BEHAVIOR_TOGGLE') != -1)         doShow++;
                    }
                }

                // Type filter
                if(filter2 > 0) {
                    // Check if we have info on this skill
                    skill = skillKV[key];
                    if(skill) {
                        // Workout if this is an ult
                        var ultimate:Boolean = false;
                        if(skill.AbilityType && skill.AbilityType.indexOf('DOTA_ABILITY_TYPE_ULTIMATE') != -1) {
                            ultimate = true;
                        }

                        // Apply filter
                        if(filter2 == 1 && !ultimate) doShow++;
                        if(filter2 == 2 && ultimate) doShow++;
                    }
                }

                // Damge type filter
                if(filter3 > 0) {
                    // Check if we have info on this skill
                    skill = skillKV[key];
                    if(skill && skill.AbilityUnitDamageType) {
                        var d:String = skill.AbilityUnitDamageType;

                        // Check filters
                        if(filter3 == 1 && d.indexOf('DAMAGE_TYPE_MAGICAL') != -1)      doShow++;
                        if(filter3 == 2 && d.indexOf('DAMAGE_TYPE_PHYSICAL') != -1)     doShow++;
                    }
                }

                // Search filter
                if(filterText != '' && (key.toLowerCase().indexOf(filterText) != -1 || trans(prefix+key).toLowerCase().indexOf(filterText) != -1)) {
                    // Found
                    doShow++;
                }

                // Did this skill pass all the filters?
                if(doShow >= totalFilters) {
                    // Found, is it banned?
                    if(lod.isSkillBanned(key)) {
                        // Banned :(
                        activeList[key].filters = Util.redFilter;
                        activeList[key].alpha = 0.5;
                        activeList[key].setBanned(true);
                    } else if(lod.isTrollSkill(key)) {
                        // Banned combo :(
                        activeList[key].filters = Util.redFilter;
                        activeList[key].alpha = 0.5;
                    } else {
                        // Yay, not banned!
                        activeList[key].filters = null;
                        activeList[key].alpha = 1;
                    }
                } else {
                    // Not found
                    activeList[key].filters = Util.greyFilter;
                    activeList[key].alpha = 0.5;
                }
            }
        }

        // Returns the skill in the given slot
        public function getSkillInSlot(slotNumber:Number):String {
            return this.yourSkillList.getSkillInSlot(slotNumber);
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

        // Toggles the hero icons on/off
        public function toggleHeroIcons():void {
            // Invert container
            heroCon.visible = !heroCon.visible;
        }

        /*
            Combo callbacks
        */

        private function onComboBehaviorChanged(comboBox):void {
            filter1 = comboBox.selectedIndex;
            updateFilters();
        }

        private function onComboTypeChanged(comboBox):void {
            filter2 = comboBox.selectedIndex;
            updateFilters();
        }

        private function onComboDamageTypeChanged(comboBox):void {
            filter2 = comboBox.selectedIndex;
            updateFilters();
        }

        // Called when the search text changes
        public function onSearchTextChanged(e:Event):void {
            // Grab the text string
            filterText = e.target.text.toLowerCase();
            updateFilters();
        }
	}

}
