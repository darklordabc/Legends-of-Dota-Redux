package  {
    import flash.events.MouseEvent;
	import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.filters.BitmapFilterQuality;

	public class NewSelectionInterface extends MovieClip {
		// Container for the skills
		public var skillCon:MovieClip;

        // Container for hero icons
        public var heroCon:MovieClip;

        // The banning area
        public var banningArea:MovieClip;

        // The random skill Icon
        public var randomSkill:MovieClip;

        // Skill lists
        public var yourSkillList:MovieClip;
        public var bearSkillList:MovieClip;
        public var towerSkillList:MovieClip;

        // The show options button
        public var helpShowOptions:MovieClip;

        // The lock skills button
        public var helpLockSkills:MovieClip;

        // The more time button
        public var helpMoreTime:MovieClip;

        // Container for the tabs up the top
        public var tabButtonCon:MovieClip;

        // Your skill browsers
        public var browseYourSkills:MovieClip;
        public var browseBearSkills:MovieClip;
        public var browseTowerSkills:MovieClip;

        // The active list
        private var activeSkillList:Number = lod.SKILL_LIST_YOUR;

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

        // List of SelectSkillList
        private var selectSkillList:Array;

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

        // Callbacks
        private var banAreaCallback:Function;
        private var slotAreaCallback:Function;
        private var recommendCallback:Function;
        private var changeListCallback:Function;

        // The effect when a target is a valid drop
        private var dropEffect:GlowFilter;

        // Recommend a skill
        private static var RECOMMEND_SKILL = 1000;
        private static var RECOMMEND_BAN = 1001;

		public function NewSelectionInterface() {
            // Make the toggle interface text work
            toggleInterfaceText.addEventListener(MouseEvent.CLICK, toggleHeroIcons);
            toggleInterfaceText.autoSize = "right";

            // Create the array
            selectSkillList = [];

            // Init drop effect
            dropEffect = new GlowFilter();
            dropEffect.blurX = 15;
            dropEffect.blurY = 15;
            dropEffect.strength = 2;
            dropEffect.inner = false;
            dropEffect.knockout = false;
            dropEffect.color = 0x00FF00;
            dropEffect.quality = BitmapFilterQuality.HIGH;
		}

        public function hideUncommonStuff():void {
            banningArea.visible = false;
            yourSkillList.visible = false;
            hideAllSkillLists();
            setPageButtonVisible(false);
        }

		// Rebuilds the interface from scratch
		public function Rebuild(newTabNames:Array, newSkillList:Object, source1:Boolean, banningDropCallback:Function, newRecommendCallback:Function, newChangeListCallback:Function) {
            var tabName:String, i:Number;

            // Store callbacks
            banAreaCallback = banningDropCallback;
            recommendCallback = newRecommendCallback;
            changeListCallback = newChangeListCallback;

            // Reload the skillKV
            skillKV = lod.Globals.GameInterface.LoadKVFile('scripts/npc/npc_abilities.txt');

            // Disable hero input on the hero icons
            heroCon.mouseEnabled = false;
            heroCon.mouseChildren = false;

            // Allow dropping to the banning area
            EasyDrag.dragMakeValidTarget(banningArea, banningDropCallback, checkBanningArea);

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

            // Set helper button texts
            helpMoreTime.setText('#helpMoreTime');
            helpMoreTime.addEventListener(MouseEvent.CLICK, lod.requestMoreTime);
            helpLockSkills.setText('#helpLockSkills');
            helpLockSkills.addEventListener(MouseEvent.CLICK, lod.lockSkills);
            helpShowOptions.setText('#helpShowOptions');
            helpShowOptions.addEventListener(MouseEvent.CLICK, lod.showOptions);

            // Set the skill list selector text
            browseYourSkills.setText('#browseYourSkills');
            browseYourSkills.addEventListener(MouseEvent.CLICK, showYourSkills);
            browseBearSkills.setText('#browseYourBear');
            browseBearSkills.addEventListener(MouseEvent.CLICK, showBearSkills);
            browseTowerSkills.setText('#browseYourTower');
            browseTowerSkills.addEventListener(MouseEvent.CLICK, showTowerSkills);

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
            randomSkill.addEventListener(MouseEvent.MOUSE_DOWN, onAbilityPressed);

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
            for(var ii=0; ii<newTabNames.length; ++ii) {
                // Grab the tab name
                tabName = newTabNames[ii];

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

                                // Do we have any active spells?
                                var activeSpells:Boolean = false;

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

                                                // Add hook for right click menu
                                                skillSlot.addEventListener(MouseEvent.MOUSE_DOWN, onAbilityPressed);

	                                            // Hook dragging
	                                            EasyDrag.dragMakeValidFrom(skillSlot, lod.skillSlotDragBegin);

	                                            // Store into the active list
	                                            activeList[skill] = skillSlot;

                                                // We have active spells
                                                activeSpells = true;
                                        	} else {
                                                // Remove the slot
                                                sl.removeChild(skillSlot);
                                            }
                                        } else {
                                            // Remove the slot
                                            sl.removeChild(skillSlot);

                                            // Loop over all the spells in this bundle
                                            for(var splitLength:Number=0;splitLength<skillSplit.length;splitLength++) {
                                                if(lod.isValidSkill(skillSplit[splitLength])) {
                                                    var msk:MovieClip = new SelectSkillsSplit(1+splitLength, skillSplit.length);
                                                    sl.addChild(msk);

                                                    // Create the new skill slot
                                                    var skillSlot2:MovieClip = new SelectSkill();
                                                    skillSlot2.mask = msk;
                                                    sl.addChild(skillSlot2);
                                                    skillSlot2.x = skillSlot.x;
                                                    skillSlot2.y = skillSlot.y;
                                                    msk.x = skillSlot.x;
                                                    msk.y = skillSlot.y;

                                                    // Add hook for right click menu
                                                    skillSlot2.addEventListener(MouseEvent.MOUSE_DOWN, onAbilityPressed);

                                                    // Put the skill into the slot
                                                    skillSlot2.setSkillName(skillSplit[splitLength]);

                                                    // Hook dragging
                                                    EasyDrag.dragMakeValidFrom(skillSlot2, lod.skillSlotDragBegin);

                                                    // Store into the active list
                                                    activeList[skillSplit[splitLength]] = skillSlot2;

                                                    // We have active spells
                                                    activeSpells = true;
                                                }
                                            }
                                        }
                                    } else {
                                        // Remove the slot
                                        sl.removeChild(skillSlot);
                                    }
                                }

                                // Do we have any active spells?
                                if(activeSpells) {
                                    // Store it
                                    selectSkillList.push(sl);
                                }
                            }
                        }
                    }
                }
            }

            // Change to the main tab
            setActiveTab('main');

            // Default to your skills
            showYourSkills();
		}

        private var rightClickedAbility:MovieClip;
        private var rightClickedAbilityName:String;
        private function onAbilityPressed(e):void {
            // Check for a right click
            if(e.buttonIdx == 1) {
                // Process the right click
                onSkillRightClicked(e.currentTarget.getSkillName(), false);
            }
        }

        public function onSkillRightClicked(skillName:String, noRecommend:Boolean=false, overrideIgnoreClick:Boolean=true):void {
            // Store it
            rightClickedAbilityName = skillName;

            // Build options
            var data:Array = [];

            // Allow banning
            if(banningArea.visible && !lod.isSkillBanned(skillName)) {
                if(!noRecommend) {
                    // Allow ban suggestions
                    data.push({
                        label: '#lodRecommendBan',
                        option: RECOMMEND_BAN
                    });
                }

                data.push({
                    label: '#lodBanSkill',
                    option: 10
                });
            }

            // Allow sloting
            if(yourSkillList.visible || bearSkillList.visible || towerSkillList.visible) {
                if(!noRecommend) {
                    // Allow recommending
                    data.push({
                        label: '#lodRecommend',
                        option: RECOMMEND_SKILL
                    });
                }

                for(var i=0;i<lod.MAX_SLOTS; ++i) {
                    if(canSlotAbility(skillName, i)) {
                        // Build Label
                        var label:String = '#lodPutSlot' + i;
                        if(i == lod.MAX_SLOTS-1) {
                            label = '#lodPutSlot5'
                        }

                        data.push({
                            label: label,
                            option: i
                        });
                    }
                }
            }

            // Cancel
            data.push({
                label: '#lodCancel',
                option: -1
            });

            // Show context menu
            lod.rightClickMenu.show(data, onAbilityOptionSelected, overrideIgnoreClick);
        }

        private function onSlotPressed(e):void {
            // Check for a right click
            if(e.buttonIdx == 1) {
                // Store ability we right clicked
                rightClickedAbility = e.currentTarget;

                var mySlot = rightClickedAbility.getSkillSlot();

                // Build options
                var data:Array = [];

                // Random Ability
                data.push({
                    label: '#lodRandomAbility',
                    option: -2
                });

                // Allow recommendations
                data.push({
                    label: '#lodRecommend',
                    option: RECOMMEND_SKILL
                });

                // Allow sloting
                if(yourSkillList.visible || bearSkillList.visible || towerSkillList.visible) {
                    for(var i=0;i<lod.MAX_SLOTS; ++i) {
                        if(mySlot != i) {
                            // Build Label
                            var label:String = '#lodSwapSlot' + i;
                            if(i == lod.MAX_SLOTS-1) {
                                label = '#lodSwapSlot5'
                            }

                            data.push({
                                label: '#lodSwapSlot' + i,
                                option: i
                            });
                        }
                    }
                }

                // Cancel
                data.push({
                    label: '#lodCancel',
                    option: -1
                });

                // Show context menu
                lod.rightClickMenu.show(data, onSlotOptionSelected);
            }
        }

        private function onAbilityOptionSelected(option:Number):void {
            var data:MovieClip;

            // Check what to do
            if(option == 10) {
                // Create the drag data
                data = new MovieClip();
                data.dragType = lod.DRAG_TYPE_SKILL;
                data.skillName = rightClickedAbilityName;

                // Fire event
                banAreaCallback(banningArea, data);
            } else if(option >= 0 && option < lod.MAX_SLOTS) {
                // Create the drag data
                data = new MovieClip();
                data.dragType = lod.DRAG_TYPE_SKILL;
                data.skillName = rightClickedAbilityName;

                switch(activeSkillList) {
                    case lod.SKILL_LIST_YOUR:
                        slotAreaCallback(yourSkillList['skill' + option], data);
                        break;

                    case lod.SKILL_LIST_BEAR:
                        slotAreaCallback(bearSkillList['skill' + option], data);
                        break;

                    case lod.SKILL_LIST_TOWER:
                        slotAreaCallback(towerSkillList['skill' + option], data);
                        break;
                }
            } else if(option == RECOMMEND_SKILL) {
                // Recommend a skill
                recommendCallback(rightClickedAbilityName, '#lod_recommends');
            } else if(option == RECOMMEND_BAN) {
                // Recommend a ban
                recommendCallback(rightClickedAbilityName, '#lod_recommend_ban');
            }
        }

        private function onSlotOptionSelected(option:Number):void {
            var data:MovieClip;

            // Check what to do
            if(option >= 0 && option < lod.MAX_SLOTS) {
                // Create the drag data
                data = new MovieClip();
                data.dragType = lod.DRAG_TYPE_SLOT;
                data.slotNumber = rightClickedAbility.getSkillSlot();

                switch(activeSkillList) {
                    case lod.SKILL_LIST_YOUR:
                        slotAreaCallback(yourSkillList['skill' + option], data);
                        break;

                    case lod.SKILL_LIST_BEAR:
                        slotAreaCallback(bearSkillList['skill' + option], data);
                        break;

                    case lod.SKILL_LIST_TOWER:
                        slotAreaCallback(towerSkillList['skill' + option], data);
                        break;
                }
            } else if(option == -2) {
                // Create the drag data
                data = new MovieClip();
                data.dragType = lod.DRAG_TYPE_SKILL;
                data.skillName = randomSkill.getSkillName();

                slotAreaCallback(rightClickedAbility, data);
            } else if(option == RECOMMEND_SKILL) {
                // Recommend a skill
                recommendCallback(rightClickedAbility.getSkillName(), '#lod_recommends');
            }
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

            // Hide all hero images
            for(var i:Number=0; i<selectSkillList.length; ++i) {
                selectSkillList[i].resetActiveChildren();
            }

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
                        var ultimate:Boolean = isUlt(key);

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

                // Show the parent
                activeList[key].parent.addActiveChild(false);

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

                        // Show the parent
                        activeList[key].parent.addActiveChild(true);
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
            switch(activeSkillList) {
                case lod.SKILL_LIST_YOUR:
                    return yourSkillList.getSkillInSlot(slotNumber);
                    break;

                case lod.SKILL_LIST_BEAR:
                    return bearSkillList.getSkillInSlot(slotNumber);
                    break;

                case lod.SKILL_LIST_TOWER:
                    return towerSkillList.getSkillInSlot(slotNumber);
                    break;
            }

            // Default to your skills list
            return yourSkillList.getSkillInSlot(slotNumber);
        }

        // Setups the skill list
        public function setupSkillList(totalSlots:Number, slotInfo:String, bearSlotInfo:String, towerSlotInfo:String, dropCallback:Function, keyBindings:Array):void {
            // Store callback
            slotAreaCallback = dropCallback;

            // Limit max slots on towers / bear
            var changedSlots:Number = totalSlots;
            if(changedSlots > 6) changedSlots = 6;

            // Do it
            yourSkillList.setup(totalSlots, slotInfo, dropCallback, keyBindings, checkTarget, lod.SKILL_LIST_YOUR);
            bearSkillList.setup(changedSlots, bearSlotInfo, dropCallback, keyBindings, checkTarget, lod.SKILL_LIST_BEAR);
            towerSkillList.setup(changedSlots, towerSlotInfo, dropCallback, keyBindings, checkTarget, lod.SKILL_LIST_TOWER);

            // Reposition buttons
            var localPaddingLeft:Number = 8;
            var localPaddingRight:Number = 4;
            var leftX:Number = yourSkillList.x - yourSkillList.width/2 - browseYourSkills.width - localPaddingLeft;
            var rightX:Number = yourSkillList.x + yourSkillList.width/2 + localPaddingRight;
            browseYourSkills.x = leftX;
            browseBearSkills.x = leftX;
            browseTowerSkills.x = leftX;

            helpShowOptions.x = rightX;
            helpMoreTime.x = rightX;
            helpLockSkills.x = rightX;

            randomSkill.x = rightX + helpShowOptions.width + localPaddingRight;

            // Hook slot right clicking
            for(var i:Number=0; i<lod.MAX_SLOTS; ++i) {
                yourSkillList['skill' + i].addEventListener(MouseEvent.MOUSE_DOWN, onSlotPressed);
            }
            for(i=0; i<changedSlots; ++i) {
                bearSkillList['skill' + i].addEventListener(MouseEvent.MOUSE_DOWN, onSlotPressed);
                towerSkillList['skill' + i].addEventListener(MouseEvent.MOUSE_DOWN, onSlotPressed);
            }
        }

        // Puts a skill into a slot
        public function skillIntoSlot(selectedInterface:Number, slotNumber:Number, skillName:String):Boolean {
            switch(selectedInterface) {
                case lod.SKILL_LIST_YOUR:
                    return yourSkillList.skillIntoSlot(slotNumber, skillName);
                    break;

                case lod.SKILL_LIST_BEAR:
                    return bearSkillList.skillIntoSlot(slotNumber, skillName);
                    break;

                case lod.SKILL_LIST_TOWER:
                    return towerSkillList.skillIntoSlot(slotNumber, skillName);
                    break;
            }

            return false;
        }

        // We have swapped two slots
        public function onSlotSwapped(selectedInterface:Number, slot1:Number, slot2:Number):void {
            switch(selectedInterface) {
                case lod.SKILL_LIST_YOUR:
                    yourSkillList.onSlotSwapped(slot1, slot2);
                    break;

                case lod.SKILL_LIST_BEAR:
                    bearSkillList.onSlotSwapped(slot1, slot2);
                    break;

                case lod.SKILL_LIST_TOWER:
                    towerSkillList.onSlotSwapped(slot1, slot2);
                    break;
            }

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
            Drop target function
        */

        private function checkTarget(slot:MovieClip, dragClip:MovieClip, active:Boolean):void {
            var doHighlight:Boolean = false;

            // Check if we are currently dragging
            if(active && dragClip) {
                // Check which type of dragging
                if(dragClip.dragType == lod.DRAG_TYPE_SKILL) {
                    // Check if this is a valid slot / skill combo
                    if(canSlotAbility(dragClip.skillName, slot.getSkillSlot())) {
                        doHighlight = true;
                    }
                } else if(dragClip.dragType == lod.DRAG_TYPE_SLOT) {
                    // Ensure we aren't dragging / dropping from the same slot
                    if(dragClip.slotNumber != slot.getSkillSlot()) {
                        doHighlight = true;
                    }
                }
            }

            // enable / disable the highlight
            if(doHighlight) {
                slot.abilityClip.filters = [dropEffect];
            } else {
                slot.abilityClip.filters = [];
            }
        }

        private function checkBanningArea(target:MovieClip, dragClip:MovieClip, active:Boolean):void {
            // Check if we are currently dragging
            if(active && dragClip) {
                target.filters = [dropEffect];
            } else {
                target.filters = [];
            }
        }

        /*
            Skill page managers
        */

        // Hide skill page views
        public function setPageButtonVisible(vis:Boolean):void {
            browseYourSkills.visible = vis;
            browseBearSkills.visible = lod.allowBearSkills && vis;
            browseTowerSkills.visible = lod.allowTowerSkills && vis;
        }

        // Hides all skill lists
        private function hideAllSkillLists():void {
            yourSkillList.visible = false;
            bearSkillList.visible = false;
            towerSkillList.visible = false;
        }

        // Shows only your skills
        public function showYourSkills():void {
            var doChange:Boolean = false;
            if(activeSkillList != lod.SKILL_LIST_YOUR) doChange = true;

            hideAllSkillLists();
            yourSkillList.visible = true;
            activeSkillList = lod.SKILL_LIST_YOUR;

            if(doChange) changeListCallback();
        }

        // Shows only bear skills
        public function showBearSkills():void {
            var doChange:Boolean = false;
            if(activeSkillList != lod.SKILL_LIST_BEAR) doChange = true;

            hideAllSkillLists();
            bearSkillList.visible = lod.allowBearSkills;
            activeSkillList = lod.SKILL_LIST_BEAR;

            if(doChange) changeListCallback();
        }

        // Shows only tower skills
        public function showTowerSkills():void {
            var doChange:Boolean = false;
            if(activeSkillList != lod.SKILL_LIST_TOWER) doChange = true;

            hideAllSkillLists();
            towerSkillList.visible = lod.allowTowerSkills;
            activeSkillList = lod.SKILL_LIST_TOWER;

            if(doChange) changeListCallback();
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

        /*
            Helper function
        */

        // Works out if a skill is an ulty or not
        private function isUlt(skillName:String):Boolean {
            var ultimate:Boolean = false;
            var skill = skillKV[skillName];

            // Did we find it?
            if(skill) {
                // Is it an ult?
                if(skill.AbilityType && skill.AbilityType.indexOf('DOTA_ABILITY_TYPE_ULTIMATE') != -1) {
                    ultimate = true;
                }
            }

            return ultimate;
        }

        // Returns true if the given skill will fit in the given slot
        private function canSlotAbility(skillName:String, slotNumber:Number):Boolean {
            // If it's banned, it wont fit in any slot
            if(lod.isSkillBanned(skillName)) return false;

            // Does the slot even exist?
            var slot:MovieClip;

            switch(activeSkillList) {
                case lod.SKILL_LIST_YOUR:
                    slot = yourSkillList['skill' + slotNumber];
                    break;

                case lod.SKILL_LIST_BEAR:
                    slot = bearSkillList['skill' + slotNumber];
                    break;

                case lod.SKILL_LIST_TOWER:
                    slot = towerSkillList['skill' + slotNumber];
                    break;
            }


            if(!slot) return false;

            // Grab the slot type
            var slotType:String = slot.getSlotType();

            // Return if it fits, or not
            switch(slotType) {
                case lod.SLOT_TYPE_ABILITY:
                    return !isUlt(skillName)
                    break;

                case lod.SLOT_TYPE_ULT:
                    return isUlt(skillName);
                    break;

                case lod.SLOT_TYPE_EITHER:
                    return true;
                    break;

                case lod.SLOT_TYPE_NEITHER:
                    return false;
                    break;
            }

            // Something went wrong, default to false
            return false;
        }
	}
}
