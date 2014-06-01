package  {
    // Flash Libraries
    import flash.display.MovieClip;

    // For showing the info pain
    import flash.geom.Point;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;

    // Used to make nice buttons
    import flash.utils.getDefinitionByName;

    // Events
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;

    // Marking spells different colors
    import flash.filters.ColorMatrixFilter;

    public class lod extends MovieClip {
        // Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // How many players are on a team
        private static var MAX_PLAYERS_TEAM = 5;

        // How many skills each player gets
        private static var MAX_SKILLS = 4;

        // Constant used for scaling (just the height of our movieClip)
        private static var myStageHeight = 720;

        // The real size of the screen (this will be changed automatically)
        private static var realScreenWidth = 1280;
        private static var realScreenHeight = 720;

        // Stores the scaling factor
        private static var scalingFactor = 1;

        // Original data providers
        private static var dpRolesCombo;
        private static var dpAttackCombo;
        private static var dpMyHeroesCombo;

        // Are we currently picking skills?
        private static var pickingSkills = false;
        private static var heroScreenState:Array;

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

        // The skill selection screen
        private var skillScreen:MovieClip;

        // The skill list to feed in
        private var completeList;

        // Active list of skills (key = skill name)
        private var activeList:Object;

        // When the hud is loaded
        public function onLoaded():void {
            // Tell everyone we're loading
            trace('\n\nLegends of Dota hud is loading...');

            // Grab the dock
            var dock:MovieClip = getDock();

            // Spawn player skill lists
            hookSkillList(dock.radiantPlayers, 0);
            hookSkillList(dock.direPlayers, 5);

            // Hero tab button
            var btnHeroes:MovieClip = smallButton('Heroes');
            btnHeroes.addEventListener(MouseEvent.CLICK, onBtnHeroesClicked);
            btnHeroes.x = 38;
            btnHeroes.y = 6;

            // Skill tab button
            var btnSkills:MovieClip = smallButton('Skills');
            btnSkills.addEventListener(MouseEvent.CLICK, onBtnSkillsClicked);
            btnSkills.x = 104;
            btnSkills.y = 6;

            // Store the data providers
            dpRolesCombo = dock.filterButtons.RolesCombo.menuList.dataProvider;
            dpAttackCombo = dock.filterButtons.AttackCombo.menuList.dataProvider;
            dpMyHeroesCombo = dock.filterButtons.MyHeroesCombo.menuList.dataProvider;

            // Load KV
            var kv = Globals.instance.GameInterface.LoadKVFile('scripts/kv/abilities.kv');
            completeList = kv.abs;

            // Build the skill screen
            buildSkillScreen();

            // Hook resizing
            Globals.instance.resizeManager.AddListener(this);

            trace('Legends of Dota hud finished loading!\n\n');
        }

        // When the resolution changes, fix our hud
        public function onResize(re:ResizeManager):void {
            // Align to top of screen
            x = 0;
            y = 0;

            // Ensure the hud is visible
            visible = true;

            // Workout the scaling factor
            scalingFactor = re.ScreenHeight/myStageHeight;

            // Apply the scale
            this.scaleX = scalingFactor;
            this.scaleY = scalingFactor;

            // Store the real screen size
            realScreenWidth = re.ScreenWidth;
            realScreenHeight = re.ScreenHeight;

            // How much space we have to use
            var workingWidth:Number = myStageHeight*4/3;

            // Align the skill screen correctly
            skillScreen.x = (realScreenWidth/scalingFactor-workingWidth)/2;
            skillScreen.y = 128;
        }

        private function buildSkillScreen() {
            var i:Number, j:Number, k:Number, l:Number, a:Number, sl:MovieClip;

            // How much space we have to use
            var workingWidth:Number = myStageHeight*4/3;

            // Build a container
            skillScreen = new MovieClip();
            addChild(skillScreen);

            var singleWidth:Number = X_PER_SECTION*(SL_WIDTH + S_PADDING);
            var totalWidth:Number = X_SECTIONS * singleWidth - S_PADDING;

            var singleHeight:Number = Y_PER_SECTION*(SL_HEIGHT + S_PADDING);
            var totalHeight:Number = Y_SECTIONS * singleHeight - S_PADDING;

            var useableHeight:Number = 320;

            var gapSizeX:Number = (workingWidth-totalWidth) / (X_SECTIONS-1);
            var gapSizeY:Number = (useableHeight-totalHeight) / (Y_SECTIONS-1);

            var gapSize:Number = Math.min(gapSizeX, gapSizeY);

            // The skill we are upto in our skill list
            var skillNumber:Number = 0;

            // New active list
            activeList = {};

            for(k=0;k<Y_SECTIONS;k++) {
                for(l=0; l<Y_PER_SECTION; l++) {
                    for(i=0;i<X_SECTIONS;i++) {
                        for(j=0; j<X_PER_SECTION; j++) {
                            // Create new skill list
                            sl = new SelectSkillList();
                            skillScreen.addChild(sl);
                            sl.x = i*(singleWidth+gapSize) + j*(SL_WIDTH+S_PADDING);
                            sl.y = k*(singleHeight+gapSize) + l*(SL_HEIGHT+S_PADDING);

                            for(a=0; a<4; a++) {
                                // Grab a new skill
                                var skill = completeList[skillNumber++];
                                if(skill) {
                                    // Put the skill into the slot
                                    sl['skill'+a].setSkillName(skill);

                                    sl['skill'+a].addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                                    sl['skill'+a].addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

                                    // Store into the active list
                                    activeList[skill] = sl['skill'+a];
                                } else {
                                    // Hide this select skill
                                    sl['skill'+a].visible = false;
                                }
                            }
                        }
                    }
                }
            }

            // Hide it
            skillScreen.visible = false;
        }

        // Adds the skill lists to a given mc
        private function hookSkillList(players:MovieClip, playerIdStart):void {
            // Ensure our reference to players isn't null
            if(players == null) {
                trace('\n\nWARNING: Null reference passed to hookSkillList!\n\n');
                return;
            }

            // The playerID we are up to
            var playerId:Number = playerIdStart;

            // Create a skill list for each player
            for(var i:Number=0; i<MAX_PLAYERS_TEAM; i++) {
                // Attempt to find the player container
                var con:MovieClip = players['playerSlot'+i];
                if(con == null) {
                    trace('\n\nWARNING: Failed to create a new skill list for player '+i+'!\n\n');
                    continue;
                }

                // Create the new skill list
                var sl:PlayerSkillList = new PlayerSkillList();
                sl.setColor(playerId++);

                // Apply the scale
                sl.scaleX = (sl.width-9)/sl.width;
                sl.scaleY = (sl.width-9)/sl.width;

                // Make the skills show information
                for(var j:Number=0; j<MAX_SKILLS; j++) {
                    // Grab a skill
                    var ps:PlayerSkill = sl['skill'+j];

                    // Apply the default skill
                    ps.setSkillName('antimage_mana_break');

                    // Make it show information when hovered
                    ps.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                    ps.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);
                }

                // Center it perfectly
                sl.x = 0;
                sl.y = 22;

                // Move the icon up a little
                con.heroIcon.y = -15;

                // Store this skill list into the container
                con.addChild(sl);
            }
        }

        // When someone hovers over a skill
        private function onSkillRollOver(e:MouseEvent):void {
            // Grab what we rolled over
            var s:Object = e.target;

            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(0, 0));

            // Decide how to show the info
            if(lp.x < realScreenWidth/2) {
                // Workout how much to move it
                var offset:Number = 16*scalingFactor;

                // Face to the right
                globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip(lp.x+offset, lp.y, s.getSkillName());
            } else {
                // Face to the left
                globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, s.getSkillName());
            }
        }

        // When someone stops hovering over a skill
        private function onSkillRollOut(e:MouseEvent):void {
            // Hide the skill info pain
            globals.Loader_heroselection.gameAPI.OnSkillRollOut();
        }

        // Make a small button
        private function smallButton(txt:String):MovieClip {
            // Grab the class for a small button
            var dotoButtonClass:Class = getDefinitionByName("ChannelTab") as Class;

            // Create the button
            var btn:MovieClip = new dotoButtonClass();
            btn.label = txt;
            addChild(btn);

            // Return the button
            return btn;
        }

        // Makes a combo box
        private function comboBox():MovieClip {
            // Grab the class for a small button
            var dotoComboBoxClass:Class = getDefinitionByName("ComboBoxSkinned") as Class;

            // Create the button
            var comboBox:MovieClip = new dotoComboBoxClass();
            addChild(comboBox);

            // Return the button
            return comboBox;
        }

        // Sets the selection mode to skills
        private function setSkillMode():void {
            // Grab the hero dock
            var dock:MovieClip = getDock();
            var sel:MovieClip = getSelMC();

            // Patch in custom filters
            sel.resetComboBox('RolesCombo', 8);
            sel.setComboBoxString('RolesCombo', 0, '#DOTA_SortBackpack_Type');
            sel.setComboBoxString('RolesCombo', 1, '#DOTA_ToolTip_Ability_NoTarget');
            sel.setComboBoxString('RolesCombo', 2, '#DOTA_ToolTip_Ability_Target');
            sel.setComboBoxString('RolesCombo', 3, '#DOTA_ToolTip_Ability_Point');
            sel.setComboBoxString('RolesCombo', 4, '#DOTA_ToolTip_Ability_Channeled');
            sel.setComboBoxString('RolesCombo', 5, '#DOTA_ToolTip_Ability_Passive');
            sel.setComboBoxString('RolesCombo', 6, '#DOTA_ToolTip_Ability_Aura');
            sel.setComboBoxString('RolesCombo', 7, '#DOTA_ToolTip_Ability_Toggle');

            sel.resetComboBox('AttackCombo', 1);
            sel.setComboBoxString('AttackCombo', 0, 'By asd');

            sel.resetComboBox('MyHeroesCombo', 1);
            sel.setComboBoxString('MyHeroesCombo', 0, 'By dsa');

            // Patch callbacks
            dock.filterButtons.RolesCombo.setIndexCallback = onRolesComboChanged;
            dock.filterButtons.AttackCombo.setIndexCallback = onAttackComboChanged;
            dock.filterButtons.MyHeroesCombo.setIndexCallback = onMyHeroesComboChanged;

            // Hide hero selection stuff
            setHeroStuffVisibility(false);

            // We are picking skills
            pickingSkills = true;
        }

        // Change the visibility of hero selection stuff
        private function setHeroStuffVisibility(vis:Boolean) {
            // pickingSkills is the opposite of what you think
            // if true, change to hero picking mode

            // Check if we need to change anything
            if(pickingSkills && !vis) return;
            if(!pickingSkills && vis) return;

            // Grab the hero dock
            var dock:MovieClip = getDock();
            var sel:MovieClip = getSelMC();

            var i:Number;

            // Change the visibility of stuff
            var lst:Array = [
                dock.heroSelectorContainer,
                dock.itemSelection,
                dock.selectedCardOutline,
                dock.selectButton_Grid,
                dock.purchasepreview,
                dock.fullDeckEditButtons,
                dock.backToBrowsingButton,
                dock.repickButton,
                dock.selectButton,
                dock.playButton,
                dock.Message,
                dock.spinRandomButton,
                dock.suggestedHeroes,
                dock.suggestButton,
                dock.randomButton,
                dock.raisedCard,
                dock.viewToggleButton,
                dock.fullDeckLegacy,
                dock.backButton,
                dock.heroLoadout
            ];

            // Remove keyboard event listeners
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,sel.onGlobalKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP,sel.onGlobalKeyUp);
            dock.removeEventListener(MouseEvent.MOUSE_WHEEL,sel.onGlobalMouseWheel);
            dock.filterButtons.searchBox.removeEventListener(Event.CHANGE, sel.searchTextChangedEvent);
            dock.filterButtons.searchBox.removeEventListener(Event.CHANGE, searchTextChangedEvent);

            if(pickingSkills == false) {
                // Reset the heroScreenState
                heroScreenState = new Array();

                // Store states
                for(i=0; i<lst.length; i++) {
                    // Store visibility state
                    heroScreenState.push(lst[i].x);

                    // Hide all
                    lst[i].x = 10000000;
                }

                // Add listeners
                dock.filterButtons.searchBox.addEventListener(Event.CHANGE, searchTextChangedEvent);

                // Show skill selection
                skillScreen.visible = true;
            } else {
                for(i=0; i<lst.length; i++) {
                    // Restore visibility state
                    lst[i].x = heroScreenState[i];
                }

                // Restore event listeners
                stage.addEventListener(KeyboardEvent.KEY_DOWN, sel.onGlobalKeyDown);
                stage.addEventListener(KeyboardEvent.KEY_UP, sel.onGlobalKeyUp);
                dock.addEventListener(MouseEvent.MOUSE_WHEEL, sel.onGlobalMouseWheel);
                dock.filterButtons.searchBox.addEventListener(Event.CHANGE, sel.searchTextChangedEvent);

                // Hide skill selection
                skillScreen.visible = false;
            }
        }

        // Sets the selection mode to heroes
        private function setHeroesMode():void {
            // Grab the hero dock
            var dock:MovieClip = getDock();
            var sel:MovieClip = getSelMC();

            // Reset filters
            sel.resetComboBox('RolesCombo', dpRolesCombo.length);
            sel.resetComboBox('AttackCombo', dpAttackCombo.length);
            sel.resetComboBox('MyHeroesCombo', dpMyHeroesCombo.length);

            // Set original data providers
            dock.filterButtons.RolesCombo.setDataProvider(dpRolesCombo);
            dock.filterButtons.AttackCombo.setDataProvider(dpAttackCombo);
            dock.filterButtons.MyHeroesCombo.setDataProvider(dpMyHeroesCombo);

            // Fix first selection problem
            sel.setComboBoxString('RolesCombo', 0, dpRolesCombo[0].label);
            sel.setComboBoxString('AttackCombo', 0, dpAttackCombo[0].label);
            sel.setComboBoxString('MyHeroesCombo', 0, dpMyHeroesCombo[0].label);

            // Fix callbacks
            dock.filterButtons.RolesCombo.setIndexCallback = sel.onRolesComboChanged;
            dock.filterButtons.AttackCombo.setIndexCallback = sel.onAttackComboChanged;
            dock.filterButtons.MyHeroesCombo.setIndexCallback = sel.onMyHeroesComboChanged;

            // Show hero selection stuff
            setHeroStuffVisibility(true);

            // We are picking skills
            pickingSkills = false;
        }

        private function searchTextChangedEvent(field:Object):void {
            // Grab the text string
            var txt:String = field.target.text.toLowerCase();

            // Grab translation function
            var trans:Function = Globals.instance.GameInterface.Translate;
            var prefix = '#DOTA_Tooltip_ability_';

            // Search abilities for this key word
            for(var key in activeList) {
                if(key.toLowerCase().indexOf(txt) != -1 || trans(prefix+key).toLowerCase().indexOf(txt) != -1) {
                    // Found
                    activeList[key].filters = null;
                    activeList[key].alpha = 1;
                } else {
                    // Not found
                    activeList[key].filters = greyFilter();
                    activeList[key].alpha = 0.5;

                }
            }
        }

        private function onRolesComboChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            trace('You selected: '+i);

            // Update clear status
            var sel:MovieClip = getSelMC();
            sel.updateComboBoxClear(comboBox)
        }

        private function onAttackComboChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            trace('You selected: '+i);

            // Update clear status
            var sel:MovieClip = getSelMC();
            sel.updateComboBoxClear(comboBox)
        }

        private function onMyHeroesComboChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            trace('You selected: '+i);

            // Update clear status
            var sel:MovieClip = getSelMC();
            sel.updateComboBoxClear(comboBox)
        }

        // When the heroes button is clicked
        private function onBtnHeroesClicked():void {
            // Set it into heroes mode
            setHeroesMode();
        }

        // When the skills button is clicked
        private function onBtnSkillsClicked():void {
            // Set it into skills mode
            setSkillMode();
        }

        // Grabs the hero selection
        private function getSelMC():MovieClip {
            return globals.Loader_shared_heroselectorandloadout.movieClip;
        }

        // Grabs the hero dock
        private function getDock():MovieClip {
            return globals.Loader_shared_heroselectorandloadout.movieClip.heroDock;
        }

        // Makes something grey
        private function greyFilter():Array {
            return [new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.0,0.0,0.0,1,0])];
        }
    }
}