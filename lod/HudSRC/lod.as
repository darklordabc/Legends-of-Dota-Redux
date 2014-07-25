package  {
    // Flash Libraries
    import flash.display.MovieClip;

    // For showing the info pain
    import flash.geom.Point;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

    // Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // Events
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;

    // Marking spells different colors
    import flash.filters.ColorMatrixFilter;

    // Scaleform stuff
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.data.DataProvider;

    public class lod extends MovieClip {
        // Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
        private static var gameAPIShared:Object;

        // How many players are on a team
        private static var MAX_PLAYERS_TEAM = 5;

        // How many skill slots each player gets
        private static var MAX_SLOTS = 4;

        // How many regular skills can each player get
        private static var MAX_SKILLS = 3;

        // How many ults the user can have
        private static var MAX_ULTS = 1;

        // Constant used for scaling (just the height of our movieClip)
        private static var myStageHeight = 720;

        // The real size of the screen (this will be changed automatically)
        private static var realScreenWidth = 1280;
        private static var realScreenHeight = 720;

        // Stores the scaling factor
        private static var scalingFactor = 1;

        // Are we currently picking skills?
        private static var pickingSkills = false;

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
        private var completeList:Object;

        // Stores voting info
        public static var votingList:Object;

        // Active list of skills (key = skill name)
        private var activeList:Object = {};

        // Stores the different tabs
        private var tabList:Object = {};

        // The total number of tabs
        private var totalTabs:Number = 3;

        // Access to the skills at the top
        private var topSkillList:Object = {};

        // Stores the top panels so we can remove them
        private var topPanels:Array = [];

        // Stores my skills
        private var mySkills:MovieClip;

        // The voting UI
        private var votingUI:MovieClip;

        // The banning area
        private var banningArea:MovieClip;

        // Have we shown the help screen yet?
        private var shownHelp:Boolean = false;

        // Have we gotten voting info?
        private var gottenVotingInfo:Boolean = false;

        // Have we gotten picking info?
        private var gottenPickingInfo:Boolean = false;

        // The skill KV file
        var skillKV:Object;

        // The searching filters
        private var filterText:String = "";
        private var filter1:Number = 0;
        private var filter2:Number = 0;
        private var filter3:Number = 0;

        // List of banned skills nawwwww
        private var bannedSkills:Object;

        // Picking time info
        private var heroSelectionStart:Number;
        private var votingTime:Number;
        private var banningTime:Number;
        private var pickingTime:Number;

        // Stage info
        private static var STAGE_VOTING:Number = 1;
        private static var STAGE_BANNING:Number = 2;
        private static var STAGE_PICKING:Number = 3;

        // Stage timer (for changing to picking)
        private static var stageTimer:Timer;

        // When the hud is loaded
        public function onLoaded():void {
            // Tell everyone we're loading
            trace('\n\nLegends of Dota hud is loading...');

            // Load EasyDrag
            EasyDrag.init(stage);

            // Reset list of banned skills
            bannedSkills = {};

            // Load our ability list KV
            completeList = Globals.instance.GameInterface.LoadKVFile('scripts/kv/abilities.kv').abs;

            // Load voting stuff
            votingList = Globals.instance.GameInterface.LoadKVFile('scripts/kv/voting.kv');

            // Load KV with info on abilities
            skillKV = Globals.instance.GameInterface.LoadKVFile('scripts/npc/npc_abilities.txt');
            var customSkillKV = Globals.instance.GameInterface.LoadKVFile('scripts/npc/npc_abilities_custom.txt');

            // Merge in custom kv
            for(var key in customSkillKV) {
                skillKV[key] = customSkillKV[key]
            }

            // Hook resizing
            Globals.instance.resizeManager.AddListener(this);

            // Store reference to game API for static use
            gameAPIShared = gameAPI;

            // Hook events
            this.gameAPI.SubscribeToGameEvent("lod_ban", onSkillBanned);
            this.gameAPI.SubscribeToGameEvent("lod_skill", onSkillPicked);
            this.gameAPI.SubscribeToGameEvent("lod_voting_info", onGetVotingInfo);
            this.gameAPI.SubscribeToGameEvent("lod_picking_info", onGetPickingInfo);
            this.gameAPI.SubscribeToGameEvent("lod_state", onGetStateInfo);
            this.gameAPI.SubscribeToGameEvent("hero_picker_shown", initLod);
            this.gameAPI.SubscribeToGameEvent("hero_picker_hidden", cleanupHud);
            this.gameAPI.SubscribeToGameEvent("gameui_hidden", requestStateInfo);
            this.gameAPI.SubscribeToGameEvent("lod_msg", handleMessage);

            trace('Legends of Dota hud finished loading!\n\n');
        }

        // Called when LoD is unloaded
        public function OnUnload():void {
            // Fixup the damned hud!
            trace('\n\nFixing the hud...');

            // All done, tell the user
            trace('Done fixing the hud!\n\n');
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
            var workingWidth:Number = myStageHeight*getWorkingRatio();

            // Align the skill screen correctly
            if(skillScreen != null) {
                // Do we need to scale the picker?
                if(skillScreen.width > workingWidth) {
                    var newScale:Number = workingWidth / skillScreen.width;
                    skillScreen.scaleX = newScale;
                    skillScreen.scaleY = newScale;
                }

                skillScreen.x = (realScreenWidth/scalingFactor-workingWidth)/2;
                skillScreen.y = 128;
            }
        }

        // Returns how much aspect ratio we have to work with
        public function getWorkingRatio() {
            return Math.min(4/3, realScreenWidth/realScreenHeight);
        }

        // Adds chat to the chat window
        public function addChatMessage(msg:String):void {
            // Attend to chat
            globals.Loader_shared_heroselectorandloadout.movieClip.appendChatText(msg);
        }

        // When the gui is "hidden"
        private function requestStateInfo():void {
            // Voting info is most important
            if(!gottenVotingInfo) {
                requestVoteStatus();
                return;
            }

            // Do we also need picking info?
            if(!gottenPickingInfo) {
                gameAPI.SendServerCommand("lod_picking_info");
                return;
            }

            // Request the state info
            gameAPI.SendServerCommand("lod_state_info");
        }

        // Requests info on the vote status
        private function requestVoteStatus():void {
            // Request the voting info
            gameAPI.SendServerCommand("lod_voting_info");
        }

        // Init LoD
        private function initLod():void {
            // Ask about the vote status
            requestVoteStatus();
        }

        // Sets the hud up
        private function setupHud():void {
            // Reset the hud
            cleanupHud();

            // Request voting info
            if(!gottenVotingInfo) {
                requestVoteStatus();
                return
            }

            // Build the voting UI
            buildVotingUI();

            // Request picking info
            if(!gottenPickingInfo) {
                requestStateInfo();
                return;
            }

            // Proceed to rebuild it

            // Grab the dock
            var dock:MovieClip = getDock();

            // Spawn player skill lists
            hookSkillList(dock.radiantPlayers, 0);
            hookSkillList(dock.direPlayers, 5);

            // Hero tab button
            var btnHeroes:MovieClip = smallButton(this, 'Heroes');
            btnHeroes.addEventListener(MouseEvent.CLICK, onBtnHeroesClicked);
            btnHeroes.x = 38;
            btnHeroes.y = 6;

            // Skill tab button
            var btnSkills:MovieClip = smallButton(this, 'Skills');
            btnSkills.addEventListener(MouseEvent.CLICK, onBtnSkillsClicked);
            btnSkills.x = 104;
            btnSkills.y = 6;

            // Wraith Night tab button
            var btnWN:MovieClip = smallButton(this, 'Wraith Night');
            btnWN.addEventListener(MouseEvent.CLICK, onBtnWNClicked);
            btnWN.x = 170;
            btnWN.y = 6;

            // Neutral tab button
            var btnNeutral:MovieClip = smallButton(this, 'Neutral');
            btnNeutral.addEventListener(MouseEvent.CLICK, onBtnNeutralClicked);
            btnNeutral.x = 236;
            btnNeutral.y = 6;

            // Build the skill screen
            buildSkillScreen();

            // Setup the filters at the top
            setupFilters();

            // Update filters
            updateFilters();

            // Set it into skills mode
            setSkillMode(0);

            // Should we show the help?
            if(!shownHelp) {
                // Only show it once
                shownHelp = true;

                // Create the help
                var help:MovieClip = new PickingHelp();
                addChild(help);
                help.x = 38;
                help.y = 6;

                var rcPos = this.globalToLocal(dock.filterButtons.RolesCombo.localToGlobal(new Point(0,0)));

                help = new PickingHelpFilters();
                addChild(help);
                help.x = rcPos.x;
                help.y = rcPos.y;
            }

            // We've rebuilt the hud, ask for state info
            requestStateInfo();
        }

        // Cleans up the hud
        private function cleanupHud():void {
            // Remove stage timer
            if(stageTimer != null) {
                stageTimer.reset();
                stageTimer = null;
            }

            // Reset to hero selection mode
            setHeroesMode();

            // Cleanup everything on our stage
            while (this.numChildren > 0) {
                this.removeChildAt(0);
            }

            // Cleanup injected stuff
            for(var i in topPanels) {
                topPanels[i].parent.removeChild(topPanels[i]);
            }

            // Fix the positions of the hero icons
            resetHeroIcons();
        }

        // Builds the voting screen
        private function buildVotingUI():void {
            // Spawn the voting UI
            votingUI = new VotingUI();
            addChild(votingUI);
            votingUI.x = (realScreenWidth/scalingFactor)/2;
            votingUI.y = 10;
            votingUI.visible = false;

            // Update the stage
            updateStage();
        }

        // Updates a user's vote with the server
        public static function updateVote(optNumber:Number, myChoice:Number):void {
            gameAPIShared.SendServerCommand("lod_vote \""+optNumber+"\" \""+myChoice+"\"");
        }

        // Builds the picking screen
        private function buildSkillScreen():void {
            var i:Number, j:Number, k:Number, l:Number, a:Number, sl:MovieClip, skillSlot:MovieClip, skillSlot2:MovieClip, msk:MovieClip;

            // How much space we have to use
            var workingWidth:Number = myStageHeight*getWorkingRatio();

            // Build a container
            skillScreen = new MovieClip();
            addChild(skillScreen);
            skillScreen.x = (realScreenWidth/scalingFactor-workingWidth)/2;
            skillScreen.y = 128;

            // Do we need to scale the picker?
            if(skillScreen.width > workingWidth) {
                var newScale:Number = workingWidth / skillScreen.width;
                skillScreen.scaleX = newScale;
                skillScreen.scaleY = newScale;
            }

            var singleWidth:Number = X_PER_SECTION*(SL_WIDTH + S_PADDING);
            var totalWidth:Number = X_SECTIONS * singleWidth - S_PADDING;

            var singleHeight:Number = Y_PER_SECTION*(SL_HEIGHT + S_PADDING);
            var totalHeight:Number = Y_SECTIONS * singleHeight - S_PADDING;

            var useableHeight:Number = 320;

            var gapSizeX:Number = (workingWidth-totalWidth) / (X_SECTIONS-1);
            var gapSizeY:Number = (useableHeight-totalHeight) / (Y_SECTIONS-1);

            var gapSize:Number = Math.min(gapSizeX, gapSizeY);

            // New active list
            activeList = {};

            // Loop over all the possible tabs
            for(var tabNumber:Number=0;tabNumber<totalTabs;tabNumber++) {
                // The skill we are upto in our skill list
                var skillNumber:Number = 0;

                // Create the new tab
                var tab:MovieClip = new MovieClip();
                skillScreen.addChild(tab);

                // Store the tab
                tabList[tabNumber] = tab;

                for(k=0;k<Y_SECTIONS;k++) {
                    for(l=0; l<Y_PER_SECTION; l++) {
                        for(i=0;i<X_SECTIONS;i++) {
                            for(j=0; j<X_PER_SECTION; j++) {
                                // Create new skill list
                                sl = new SelectSkillList();
                                tab.addChild(sl);
                                sl.x = i*(singleWidth+gapSize) + j*(SL_WIDTH+S_PADDING);
                                sl.y = k*(singleHeight+gapSize) + l*(SL_HEIGHT+S_PADDING);

                                for(a=0; a<4; a++) {
                                    // Grab the slot
                                    skillSlot = sl['skill'+a];

                                    // Grab a new skill
                                    var skill = completeList[tabNumber*1000+skillNumber++];
                                    if(skill) {
                                        var skillSplit = skill.split('||');

                                        if(skillSplit.length == 1) {


                                            // Put the skill into the slot
                                            skillSlot.setSkillName(skill);

                                            skillSlot.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                                            skillSlot.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

                                            // Hook dragging
                                            EasyDrag.dragMakeValidFrom(skillSlot, skillSlotDragBegin);

                                            // Store into the active list
                                            activeList[skill] = skillSlot;
                                        } else {
                                            // Remove the slot
                                            sl.removeChild(skillSlot);

                                            // Loop over all the spells in this bundle
                                            for(var splitLength:Number=0;splitLength<skillSplit.length;splitLength++) {
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
                                            }
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

            // Create banning area
            banningArea = new BanningArea();
            skillScreen.addChild(banningArea);
            banningArea.x = workingWidth/2;
            banningArea.y = 296;
            banningArea.visible = false;

            // Container for you skills
            mySkills = new YourSkillList(MAX_SLOTS, MAX_SKILLS, MAX_ULTS);
            skillScreen.addChild(mySkills);
            mySkills.x = workingWidth/2;
            mySkills.y = 296;
            mySkills.visible = false;

            // Add random skill
            var randomSkill:MovieClip = new SelectSkill();
            EasyDrag.dragMakeValidFrom(randomSkill, skillSlotDragBegin);
            randomSkill.setSkillName('random');
            skillScreen.addChild(randomSkill);
            randomSkill.x = workingWidth/2 - mySkills.width/2 - 64;
            randomSkill.y = 296 + 35 - randomSkill.height*3/2;
            randomSkill.scaleX = 3;
            randomSkill.scaleY = 3;

            // Hook roll overs
            for(i=0; i<MAX_SLOTS; i++) {
                mySkills['skill'+i].addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                mySkills['skill'+i].addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

                // Set it's slot
                mySkills['skill'+i].setSkillSlot(i);

                // Allow dropping
                EasyDrag.dragMakeValidTarget(mySkills['skill'+i], onDropMySkills);

                // Apply default skills
                mySkills['skill'+i].setSkillName('nothing');
            }

            // Allow dropping to the banning area
            EasyDrag.dragMakeValidTarget(banningArea, onDropBanningArea);

            // Hide it
            skillScreen.visible = false;

            // Have we gotten the picking info already?
            if(gottenPickingInfo) {
                // Yep, fix the stage
                updateStage();
            }
        }

        private function setupFilters():void {
            // Grab the dock
            var dock:MovieClip = getDock();

            // Calculate positions for filters
            var rcPos = skillScreen.globalToLocal(dock.filterButtons.RolesCombo.localToGlobal(new Point(0,0)));
            var acPos = skillScreen.globalToLocal(dock.filterButtons.AttackCombo.localToGlobal(new Point(0,0)));
            var hcPos = skillScreen.globalToLocal(dock.filterButtons.MyHeroesCombo.localToGlobal(new Point(0,0)));

            // Create buttons at the top

            // First Combo
            var rolesCombo = comboBox(this, 8);
            skillScreen.addChild(rolesCombo);
            rolesCombo.x = rcPos.x;
            rolesCombo.y = rcPos.y;

            // Second Combo
            var attackCombo = comboBox(this, 3);
            skillScreen.addChild(attackCombo);
            attackCombo.x = acPos.x;
            attackCombo.y = acPos.y;

            // Third Combo
            var heroCombo = comboBox(this, 5);
            skillScreen.addChild(heroCombo);
            heroCombo.x = hcPos.x;
            heroCombo.y = hcPos.y;

            // Add options for each combo box
            setComboBoxString(rolesCombo, 0, '#By_Behavior');
            setComboBoxString(rolesCombo, 1, '#DOTA_ToolTip_Ability_NoTarget');
            setComboBoxString(rolesCombo, 2, '#DOTA_ToolTip_Ability_Target');
            setComboBoxString(rolesCombo, 3, '#DOTA_ToolTip_Ability_Point');
            setComboBoxString(rolesCombo, 4, '#DOTA_ToolTip_Ability_Channeled');
            setComboBoxString(rolesCombo, 5, '#DOTA_ToolTip_Ability_Passive');
            setComboBoxString(rolesCombo, 6, '#DOTA_ToolTip_Ability_Aoe');
            setComboBoxString(rolesCombo, 7, '#DOTA_ToolTip_Ability_Toggle');

            setComboBoxString(attackCombo, 0, '#By_Type');
            setComboBoxString(attackCombo, 1, '#Ability');
            setComboBoxString(attackCombo, 2, '#Ultimate');

            setComboBoxString(heroCombo, 0, '#By_Damage_Type');
            setComboBoxString(heroCombo, 1, '#Magical_Damage');
            setComboBoxString(heroCombo, 2, '#Pure_Damage');
            setComboBoxString(heroCombo, 3, '#Physical_Damage');
            setComboBoxString(heroCombo, 4, '#HP_Removal_Damage');

            // Patch callbacks
            rolesCombo.setIndexCallback = onRolesComboChanged;
            attackCombo.setIndexCallback = onAttackComboChanged;
            heroCombo.setIndexCallback = onMyHeroesComboChanged;

            // Hook into the search box
            dock.filterButtons.searchBox.addEventListener(Event.CHANGE, searchTextChangedEvent);
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
                var sl:PlayerSkillList = new PlayerSkillList(MAX_SLOTS);
                sl.setColor(playerId);

                // Store it
                topPanels.push(sl);

                // Apply the scale
                sl.scaleX = (sl.width-9)/sl.width;
                sl.scaleY = (sl.width-9)/sl.width;

                // Make the skills show information
                for(var j:Number=0; j<MAX_SLOTS; j++) {
                    // Grab a skill
                    var ps:PlayerSkill = sl['skill'+j];

                    // Apply the default skill
                    ps.setSkillName('nothing');

                    // Make it show information when hovered
                    ps.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
                    ps.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

                    // Hook dragging
                    EasyDrag.dragMakeValidFrom(ps, skillSlotDragBegin);

                    // Store a reference to it
                    topSkillList[playerId*MAX_SLOTS+j] = ps;
                }

                // Center it perfectly
                sl.x = 0;
                sl.y = 22;

                // Move the icon up a little
                con.heroIcon.y = -15;

                // Store this skill list into the container
                con.addChild(sl);

                // Move onto the next playerID
                playerId++;
            }
        }

        private function resetHeroIcons():void {
            // Grab the dock
            var dock:MovieClip = getDock();

            // Reset the positions
            resetHeroIconY(dock.radiantPlayers);
            resetHeroIconY(dock.direPlayers);
        }

        private function resetHeroIconY(players:MovieClip):void {
            // Loop over all the players
            for(var i:Number=0; i<MAX_PLAYERS_TEAM; i++) {
                // Attempt to find the player container
                var con:MovieClip = players['playerSlot'+i];

                // Reset the position
                con.heroIcon.y = -5.2;
            }
        }

        private function getSkillName(skillNumber:Number):String {
            return completeList[skillNumber] || completeList[String(skillNumber)];
        }

        // Fired when the server gives us voting info
        private function onGetVotingInfo(args:Object):void {
            // Only do this once
            if(gottenVotingInfo) return;
            gottenVotingInfo = true;

            // Store vars
            heroSelectionStart = args.startTime;
            votingTime = args.votingTime;

            // Rehook the picking screen
            setupHud();
        }

        // Fired when the server gives us our picking info
        private function onGetPickingInfo(args:Object):void {
            // Only do this ONCE
            if(gottenPickingInfo) return;
            gottenPickingInfo = true;

            // Store vars
            heroSelectionStart = args.startTime;
            banningTime = args.banningTime;
            pickingTime = args.pickingTime;

            MAX_SLOTS = args.slots;
            MAX_SKILLS = args.skills;
            MAX_ULTS = args.ults;

            // Rehook the picking screen
            setupHud();

            // Update the stage
            updateStage();
        }

        // Fired when the server sends us an error
        private function handleMessage(args:Object):void {
            // Was this me? (or everyone)
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID || args.playerID == -1) {
                // Log message to console
                trace(args.msg);

                // Add the text to chat
                addChatMessage(args.msg);
            }
        }

        // Fired when the sever gives us info on the current state
        private function onGetStateInfo(args:Object):void {
            var i:Number, j:Number, skillNumber:Number, slot:MovieClip, skillName;

            // Update skills
            for(i=0; i<10; i++) {
                for(j=0; j<MAX_SLOTS; j++) {
                    skillNumber = args[String(i)+String(j+1)];
                    if(skillNumber != -1) {
                        // Attempt to grab the slot
                        slot = topSkillList[i*MAX_SLOTS+j];
                        if(slot != null) {
                            slot.setSkillName(getSkillName(skillNumber));
                        }
                    }
                }
            }

            // We currently don't need to update he filters
            var needUpdate:Boolean = false;

            // Update bans
            for(i=1; i<=50; i++) {
                skillNumber = args['b'+i];
                if(skillNumber != -1) {
                    // Grab the name of this skill
                    skillName = getSkillName(skillNumber);

                    // Check if this skill isn't banned
                    if(!bannedSkills[skillName]) {
                        // Ban the skill
                        bannedSkills[skillName] = true;

                        // We need to update filters
                        needUpdate = true;
                    }
                }
            }

            // Check if a filter update is needed
            if(needUpdate) {
                // Update Filters
                updateFilters();
            }
        }

        // Update the current stage
        private function updateStage():void {
            // Stop any timers
            if(stageTimer != null) {
                stageTimer.reset();
                stageTimer = null;
            }

            // Hide the voting UI
            if(votingUI != null) votingUI.visible = false;

            // Hide the banning panel
            if(banningArea != null) banningArea.visible = false;

            // Hide the skills panel
            if(mySkills != null) mySkills.visible = false;

            // Workout where we are at
            var now:Number = globals.Game.Time();

            // Decide what needs to be shown
            if(now < heroSelectionStart+votingTime) {
                // It's voting time

                // Show the voting UI
                if(votingUI != null) {
                    // Display voting UI
                    votingUI.visible = true;

                    // Update timer
                    votingUI.timer.text = Math.ceil(heroSelectionStart+votingTime-now);
                }
            } else if(now < heroSelectionStart+banningTime+votingTime) {
                // It is banning time

                // Show the banning panel
                if(banningArea != null) {
                    // Make it visible
                    banningArea.visible = true;

                    // Update the timer
                    banningArea.timer.text = Math.ceil(heroSelectionStart+votingTime+banningTime-now);
                }
            } else {
                // It is skill selection time

                // Show the skills area
                if(mySkills != null) mySkills.visible = true;

                // We don't need a timer <3
                return;
            }

            // Wait for a moment, and try again
            stageTimer = new Timer(100);
            stageTimer.addEventListener(TimerEvent.TIMER, updateStage, false, 0, true);
            stageTimer.start();
        }

        // Fired when the server bans a skill
        private function onSkillBanned(args:Object) {
            // Grab the skill
            var skillName:String = args.skill;

            // Check if we have a reference to this skill
            if(activeList[skillName]) {
                // Ban this skill
                activeList[skillName].setBanned(true);
            }

            // Store this skill as banned
            bannedSkills[skillName] = true;

            // Update Filters
            updateFilters();
        }

        // Fired when a skill is picked by someone
        private function onSkillPicked(args:Object) {
            // Attempt to find the skill
            var topSkill = topSkillList[args.playerSlot*MAX_SLOTS+args.slotNumber];
            if(topSkill != null) {
                topSkill.setSkillName(args.skillName);
            } else {
                trace('WARNING: Failed to find playerID '+args.playerID+', slot '+args.playerSlot);
            }

            // Was this me?
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID) {
                // It is me
                var slot = mySkills['skill'+args.slotNumber];
                if(slot != null) {
                    slot.setSkillName(args.skillName);
                }
            }
        }

        // Tell the server to put a skill into a slot
        private function tellServerWeWant(slotNumber:Number, skillName:String):void {
            // Send the message to the server
            gameAPI.SendServerCommand("lod_skill \""+slotNumber+"\" \""+skillName+"\"");
        }

        // Tell the server to ban a given skill
        private function tellServerToBan(skill:String):void {
            // Send the message to the server
            gameAPI.SendServerCommand("lod_ban \""+skill+"\"");
        }

        // When someone hovers over a skill
        private function onSkillRollOver(e:MouseEvent):void {
            // Don't show stuff if we're dragging
            if(EasyDrag.isDragging()) return;

            // Grab what we rolled over
            var s:Object = e.target;

            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(0, 0));

            // Decide how to show the info
            if(lp.x < realScreenWidth/2) {
                // Workout how much to move it
                var offset:Number = s.width*scalingFactor;

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
        public static function smallButton(container:MovieClip, txt:String):MovieClip {
            // Grab the class for a small button
            var dotoButtonClass:Class = getDefinitionByName("ChannelTab") as Class;

            // Create the button
            var btn:MovieClip = new dotoButtonClass();
            btn.label = txt;
            container.addChild(btn);

            // Return the button
            return btn;
        }

        // Makes a combo box
        public static function comboBox(container:MovieClip, slots:Number):MovieClip {
            // Grab the class for a small button
            var dotoComboBoxClass:Class = getDefinitionByName("ComboBoxSkinned") as Class;

            // Create the button
            var comboBox:MovieClip = new dotoComboBoxClass();
            container.addChild(comboBox);

            // Create the data provider
            var dp:IDataProvider = new DataProvider();
            for(var i:Number=0; i<slots; i++) {
                dp[i] = {
                  "label":"empty",
                  "data":i
               };
            }

            // Apply the data provider
            comboBox.setDataProvider(dp);

            // Return the button
            return comboBox;
        }

        // Sets the selection mode to skills
        private function setSkillMode(tabNumber:Number):void {
            // Hide hero selection stuff
            setHeroStuffVisibility(false);

            // Press the back button
            getSelMC().onBackButtonClicked(null);

            // We are picking skills
            pickingSkills = true;

            // Hide all tabs
            for(var i:Number=0;i<totalTabs;i++) {
                tabList[i].visible = false;
            }

            // Show the correct tab
            tabList[tabNumber].visible = true;
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
                dock.heroLoadout,
                dock.goldleft,
                dock.filterButtons.RolesCombo,
                dock.filterButtons.AttackCombo,
                dock.filterButtons.MyHeroesCombo,
                //dock.filterButtons.searchBox
            ];

            // Delete any old masks
            for(i=0; i<lst.length; i++) {
                // Validate that is exists
                if(lst[i] != null) {
                    if(lst[i].mask != null) {
                        // Check if this is one of our masks
                        if(contains(lst[i].mask)) {
                            removeChild(lst[i].mask);
                        }

                        // Remove the mask
                        lst[i].mask = null;
                    }
                }
            }

            if(pickingSkills == false) {
                // Store states
                for(i=0; i<lst.length; i++) {
                    // Validate that is exists
                    if(lst[i] != null) {
                        // Hide it
                        var msk = new MovieClip();
                        addChild(msk);
                        lst[i].mask = msk;
                    }
                }
                // Show skill selection
                if(skillScreen != null) {
                    skillScreen.visible = true;
                }
            } else {
                // Hide skill selection
                if(skillScreen != null) {
                    skillScreen.visible = false;
                }
            }
        }

        // Sets the selection mode to heroes
        private function setHeroesMode():void {
            // Grab the hero dock
            var dock:MovieClip = getDock();
            var sel:MovieClip = getSelMC();

            // Show hero selection stuff
            setHeroStuffVisibility(true);

            // We are picking skills
            pickingSkills = false;
        }

        // Fired when the search box is updated
        private function searchTextChangedEvent(field:Object):void {
            // Grab the text string
            filterText = field.target.text.toLowerCase();

            // Update filters
            updateFilters();
        }

        // Updates the filtered skills
        private function updateFilters() {
            // Grab translation function
            var trans:Function = Globals.instance.GameInterface.Translate;
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
                        if(filter3 == 2 && d.indexOf('DAMAGE_TYPE_PURE') != -1)         doShow++;
                        if(filter3 == 3 && d.indexOf('DAMAGE_TYPE_PHYSICAL') != -1)     doShow++;
                        if(filter3 == 4 && d.indexOf('DAMAGE_TYPE_HP_REMOVAL') != -1)   doShow++;
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
                    if(bannedSkills[key]) {
                        // Banned :(
                        activeList[key].filters = redFilter();
                        activeList[key].alpha = 0.5;
                    } else {
                        // Yay, not banned!
                        activeList[key].filters = null;
                        activeList[key].alpha = 1;
                    }
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

            // Update filters
            filter1 = i;
            updateFilters();

            // Update clear status
            var sel:MovieClip = getSelMC();
            sel.updateComboBoxClear(comboBox)
        }

        private function onAttackComboChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            // Update filters
            filter2 = i;
            updateFilters();

            // Update clear status
            var sel:MovieClip = getSelMC();
            sel.updateComboBoxClear(comboBox)
        }

        private function onMyHeroesComboChanged(comboBox):void {
            // Grab what is selected
            var i:Number = comboBox.selectedIndex;

            // Update filters
            filter3 = i;
            updateFilters();

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
            setSkillMode(0);
        }

        // When the wraith night skills button is clicked
        private function onBtnWNClicked():void {
            // Set it into skills mode
            setSkillMode(1);
        }

        // When the wraith night skills button is clicked
        private function onBtnNeutralClicked():void {
            // Set it into skills mode
            setSkillMode(2);
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

        // Makes something red
        private function redFilter():Array {
            return [new ColorMatrixFilter([1,1,1,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.0,0.0,0.0,1,0])];
        }

        public static function setComboBoxString(comboBox:MovieClip, slot:Number, txt:String):void {
            comboBox.menuList.dataProvider[slot] = {
                "label":txt,
                "data":slot
            };

            if(slot == 0) {
                comboBox.defaultSelection = comboBox.menuList.dataProvider[0];
                comboBox.setSelectedIndex(0);
            }
        }

        private function skillSlotDragBegin(me:MovieClip, dragClip:MovieClip):Boolean {
            // Grab the name of the skill
            var skillName = me.getSkillName();

            // Can we even drag this skill?
            if(skillName == 'nothing') {
                // Stop the drag
                return false;
            }

            // Load a skill into the dragClip
            Globals.instance.LoadAbilityImage(skillName, dragClip);

            // Store the skill
            dragClip.skillName = skillName;

            // Enable dragging
            return true;
        }

        private function onDropMySkills(me:MovieClip, dragClip:MovieClip) {
            var skillName = dragClip.skillName;

            // Tell the server about this
            tellServerWeWant(me.getSkillSlot(), skillName);
        }

        private function onDropBanningArea(me:MovieClip, dragClip:MovieClip) {
            var skillName = dragClip.skillName;

            // Tell the server to ban this skill
            tellServerToBan(skillName);
        }
    }
}