package  {
    // Flash stuff
	import flash.display.MovieClip;

    // Input detection
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

	// Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // For showing the info pain
    import flash.geom.Point;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class lod extends MovieClip {
		/*
            DOTA BASED STUFF
        */
		public var gameAPI:Object;
        public static var GameAPI:Object;
		public var globals:Object;
        public static var Globals;
		public var elementName:String;

		/*
            STAGE MOVIECLIPS
        */

        // The mask that shows screensize
		public var tempMask:MovieClip;

        // The voting UI
        public var votingUI:MovieClip;

        // The waiting screen
        public var waitingUI:MovieClip;

        // The version notification UI
        public var versionUI:MovieClip;

        // The left help screen
        public var pickingHelp:MovieClip;

        // The right help screen (this will be positioned dynamically)
        public var pickingHelpFilters:MovieClip;

        // The selection movieclip
        public var selectionUI:MovieClip;

        /*
            CONSTANTS
        */

        // The version we are running
        private var versionNumber:String;

        // Max players to deal with
        private var MAX_PLAYERS:Number = 10;

        // How many players are on a team
        private static var MAX_PLAYERS_TEAM = 5;

        // The scaling factor
        private static var scalingFactor:Number;

        // Have we gotten any state info before?
        private var firstTimeState:Boolean = true;

        // Stage info
        private static var STAGE_WAITING:Number = 0;
        private static var STAGE_VOTING:Number = 1;
        private static var STAGE_BANNING:Number = 2;
        private static var STAGE_PICKING:Number = 3;
        private static var STAGE_PLAYING:Number = 4;

        // Stage sizing
        private static var stageWidth:Number;
        private static var stageHeight:Number;

        // Slot type stuff
        public static var SLOT_TYPE_ABILITY:String = '1';
        public static var SLOT_TYPE_ULT:String = '2';
        public static var SLOT_TYPE_EITHER:String = '3';
        public static var SLOT_TYPE_NEITHER:String = '4';

        // Dragging constants
        public static var DRAG_TYPE_SKILL:Number = 1;
        public static var DRAG_TYPE_SLOT:Number = 2;

        /*
            GLOBAL VARIABLES
        */

		// List of heroes we already built a skill list for
		public var builtHeroes:Object;

		// Containers for ability icons
		public static var abilityIcons:Array;

        // The last state we got
        private var lastState:Object;

        // The current loaded stage on the client (-1 for no stage)
        private var currentStage:Number = -1;

        // Are we a slave?
        private var isSlave:Boolean = false;

        // How many skill slots each player gets
        private static var MAX_SLOTS:Number = 4;

        // Should we hide skills?
        private static var hideSkills:Boolean = false;

        // The team number we are on
        private var myTeam:Number = 0;

        // Access to the skills at the top
        private var topSkillList:Array = [];

        // Display timer
        private static var displayTimer:Timer;

        // Is this source1?
        private static var source1:Boolean = false;

        // Should we ban troll combos?
        private static var banTrollCombos:Boolean = false;

        // List of banned skills nawwwww
        private static var bannedSkills:Object;

        // Key bindings
        private var keyBindings:Array;

        /*
            SKILL LIST STUFF
        */

        // Have we setup the post voting stuff?
        private var initPostVoting:Boolean = false;

        // Stores bans
        public static var banList:Object;

        // skillName --> skillID
        private static var skillLookup:Object;

        // skillID --> skillName
        private static var skillLookupReverse:Object;

        // Which tabs are allowed
        private static var allowedTabs:Object;

        // Stores the heroes we can draft from
        private static var validDraftSkills;

        // Stores the owning heroID of each skill
        private var skillOwningHero:Object;

        // Skills that are banned with our local combos
        private static var bannedCombos:Object;

        /*
            CLEANUP STUFF
        */

        // Stores the top panels so we can remove them
        public static var injectedMovieClips:Array;

        // Stores if we have patched hero icons or not
        private var patchedHeroIcons:Boolean;

        /*
            ENCRYPTION STUFF
        */

        // What is our magic decoder?
        private var decodeWith:Number = -1;

        // What is the number we used to request our magic number
        private var encodeWith:Number = Math.floor(Math.random()*50 + 50);

		// called by the game engine when this .swf has finished loading
		public function onLoaded():void {
			trace('\n\nLoD new hud loading...');

            // Fix scaling
			fixScreenScaling();

			// Make us visible
			this.visible = true;

            // Store static refereces
            Globals = globals;
            GameAPI = gameAPI;

            // Prepare UI
            prepareUI();

            // Load bans
            loadBansFile();

            // Load the version
            var versionFile:Object = globals.GameInterface.LoadKVFile('addoninfo.txt');
            versionNumber = versionFile.version;

            // Ask for decoding info
            requestDecodingNumber();

            // Reset vars
            bannedSkills = {};
            bannedCombos = {};
            keyBindings = [];

            // Subscribe to the state info
            this.gameAPI.SubscribeToGameEvent("lod_ban", onSkillBanned);                                    // A skill was banned
            this.gameAPI.SubscribeToGameEvent("lod_state", onGetStateInfo);                                 // Contains most of the game state
            this.gameAPI.SubscribeToGameEvent("lod_slave", handleSlave);                                    // Someone has updated a voting option
            this.gameAPI.SubscribeToGameEvent("lod_decode", handleDecode);                                  // Server sent us info on how to decode skill values
            this.gameAPI.SubscribeToGameEvent("lod_skill", onSkillPicked);                                  // Someone has picked a new skill
            this.gameAPI.SubscribeToGameEvent("lod_swap_slot", onSlotSwapped);                              // Someone has swapped two slots
            this.gameAPI.SubscribeToGameEvent("lod_msg", handleMessage);                                    // Server sent a message
            this.gameAPI.SubscribeToGameEvent("dota_player_update_selected_unit", onUnitSelectionUpdated);  // The player changed the unit they had selected

            // Handle keyboard input
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyBoardDown);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyBoardDown, false, 0, true);

            // Handle the scoreboard stuff
            handleScoreboard();

			// Load EasyDrag
            EasyDrag.init(stage);

            // Setup display timer
            updateDisplayTimer();

            trace('Finished loading LoD hud, running version: ' + getLodVersion() + '\n\n');
		}

		// Called by the game engine after onLoaded and whenever the screen size is changed
		public function onScreenSizeChanged():void {
			// By default, your 1024x768 swf is scaled to fit the vertical resolution of the game
			//   and centered in the middle of the screen.
			// You can override the scaling and positioning here if you need to.
			// stage.stageWidth and stage.stageHeight will contain the full screen size.

			// Fix the scaling
			fixScreenScaling();
		}

		// Fixes the scaling on the screen
		private function fixScreenScaling():void {
			// Work out the scale
			var scale:Number = stage.stageHeight / 768;

			// Apply the new scale
			this.scaleX = scale;
			this.scaleY = scale;

			// Workout how much of the screensize we can actually use
			var ourWidth = stage.stageHeight*4/3;

			// Update the position of this hud (we want the 4:3 section centered)
			x = (stage.stageWidth - ourWidth) / 2;
			y = 0;

            // Store size
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;

			// Store the scaling factor
			scalingFactor = scale;

            // Move the picking help into position
            var dock:MovieClip = getDock();
            var rcPos = this.globalToLocal(dock.filterButtons.RolesCombo.localToGlobal(new Point(0,0)));
            pickingHelpFilters.x = rcPos.x;
            pickingHelpFilters.y = rcPos.y;
		}

        // Hides all the UI stuff
        private function hideAllUI():void {
            // Hide the mask
            tempMask.visible = false;

            // Hide the voting UI
            votingUI.visible = false;

            // Hide waiting UI
            waitingUI.visible = false;

            // Hide version UI
            versionUI.visible = false;

            // Hide the left picking help
            pickingHelp.visible = false;

            // Hide the right picking help
            pickingHelpFilters.visible = false;

            // Hide the selection UI
            selectionUI.visible = false;
        }

        // Nukes all the UI
        private function nukeUI():void {
            // Delete everything
            Util.empty(this);
        }

        // Cleans up the hud
        private function cleanupHud():void {
            // Hide all UI elements
            hideAllUI();

            // Cleanup injected stuff
            if(injectedMovieClips != null) {
                for(var i in injectedMovieClips) {
                    injectedMovieClips[i].parent.removeChild(injectedMovieClips[i]);
                }
            }

            // Reset the array
            injectedMovieClips = [];

            // Fix the positions of the hero icons
            resetHeroIcons();
        }

        // Prepares the UI, waiting for state info
        private function prepareUI():void {
            // Clean the hud ready for use
            cleanupHud();

            // Add accept button to versionUI
            var btn:MovieClip = Util.smallButton(versionUI.acceptButton, '#versionAccept', true, true);
            btn.addEventListener(MouseEvent.CLICK, onVersionInfoClosed, false, 0, true);

            // Wait for the game to be ready
            waitForGame();
        }

        // Loads in the skills file
        private function loadSkillsFile():void {
            // Load in the skill list
            var skillKV = globals.GameInterface.LoadKVFile('scripts/kv/abilities.kv');
            var tempSkillList:Object = skillKV.skills;

            // Create the object
            skillLookup = {};
            skillLookupReverse = {};

            // Tabs to allow (this will be sent from the server eventually)
            allowedTabs = {
                main: true,
                neutral: true,
                wraith: true
            };

            var tabList = [
                'main',
                'neutral',
                'wraith'
            ];

            // Loop over all tabs
            for(var tabName:String in tempSkillList) {
                // Grab all the skills in this tab
                var skills:Object = tempSkillList[tabName];

                // Loop over all skills
                for(var skillName:String in skills) {
                    // Should we include this skill?
                    var doInclude = true;

                    // Grab the skill's index
                    var skillIndex = skills[skillName];

                    // Grab the s1 version of the skill
                    var s1Skill = String(skillIndex).replace('_s1', '');

                    // Check if this is a source1 only skill
                    if(s1Skill != skillIndex) {
                        // Copy it across
                        skillIndex = s1Skill;

                        // Check if we can include it
                        if(!source1) {
                            doInclude = false;
                        }
                    }

                    // If we should include it, do it
                    if(doInclude) {
                        if(!isNaN(parseInt(skillIndex))) {
                            skillLookup[skillName] = parseInt(skillIndex);
                            skillLookupReverse[parseInt(skillIndex)] = skillName;
                        }
                    }
                }
            }

            // Load hero KV
            var heroKV:Object = globals.GameInterface.LoadKVFile('scripts/npc/npc_heroes.txt');

            var key:String;

            // Build list of skill owners
            skillOwningHero = {};
            for(key in heroKV) {
                // Validate key
                if(key == 'Version' || key == 'npc_dota_hero_base') continue;

                // Grab the entry
                var entry:Object = heroKV[key];

                // Ensure it has a heroID
                if(entry.HeroID) {
                    // Loop over all possible skills
                    for(var i:Number=1;i<=16;i++) {
                        var ab:String = entry['Ability'+i];
                        if(ab) {
                            // Store it
                            skillOwningHero[ab] = entry.HeroID;
                        }
                    }
                }
            }

            // Add in the override owners
            var ownersKV = globals.GameInterface.LoadKVFile('scripts/kv/owners.kv');
            for(key in ownersKV) {
                skillOwningHero[key] = parseInt(ownersKV[key]);
            }

            // Rebuild the skill list
            selectionUI.Rebuild(tabList, skillKV.tabs, source1, onDropBanningArea);
        }

        private function updateDisplayTimer():void {
            // Ensure this timer is still need
            if(selectionUI == null) return;

            if(lastState != null) {
                var timerEnd:Number = lastState.t;
                var timerDisplay:String;

                // Check when the timer ends
                if(timerEnd == -1) {
                    // No timer yet
                    timerDisplay = '0:00';
                } else {
                    // Workout how long left
                    var now:Number = globals.Game.Time();
                    var timeLeft = timerEnd - now;

                    if(timeLeft > 0) {
                        timerDisplay = Util.sexyTime(timeLeft);
                    } else {
                        timerDisplay = '0:00';
                    }
                }

                // Update the display
                selectionUI.timerField.text = timerDisplay;
            }

            // Update in 100ms
            if(displayTimer != null) {
                displayTimer.stop();
                displayTimer = null;
            }

            // This timer will update the display timer every 100ms
            displayTimer = new Timer(100, 1);
            displayTimer.addEventListener(TimerEvent.TIMER, updateDisplayTimer, false, 0, true);
            displayTimer.start();
        }

        // Returns a skill name, based on a skill number
        private static function getSkillName(skillNumber:Number):String {
            return skillLookupReverse[skillNumber] || 'nothing';
        }

        // Returns the ID (or -1) of the hero that owns this skill
        private function GetSkillOwningHero(skillName:String) {
            // Do we know this skill?
            if(skillOwningHero[skillName]) {
                // Yes, return the owner
                return skillOwningHero[skillName];
            } else {
                // Nope, go cry :(
                return -1;
            }
        }

        // Checks if a given skill is valid, or not
        public static function isValidSkill(skillName:String):Boolean {
            // Ensure a skill is passed
            if(!skillName) return false;

            // Check if there is an index for it
            return skillLookup[skillName] != null;
        }

        // Returns if a skill is banned
        public static function isSkillBanned(skillName:String):Boolean {
            if(bannedSkills[skillName]) return true;
            return false;
        }

        // Returns if this is a valid draft skill
        public static function isValidDraftSkill(skillName:String):Boolean {
            if(validDraftSkills == null) return true;
            return validDraftSkills[skillName] != null;
        }

        // Returns if this is a troll skill
        public static function isTrollSkill(skillName:String):Boolean {
            if(!banTrollCombos) return false;

            if(bannedCombos[skillName]) return true;

            return false;
        }

        // Checks if a tab is allowed
        public static function isTabAllowed(tab:String):Boolean {
            // Checks if a tab is allowed
            return allowedTabs[tab] != null && allowedTabs[tab] != false;
        }

        // Loads in the bans stuff
        private function loadBansFile():void {
            var skillName:String, skillName2:String, group:Object;

            // Reset the ban list
            banList = {};

            // Load in the bans KV
            var tempBanList:Object = globals.GameInterface.LoadKVFile('scripts/kv/bans.kv');

            // Bans a combo
            var banCombo = function(a:String, b:String) {
                // Ensure the ban lists exist
                banList[a] = banList[a] || {};
                banList[b] = banList[b] || {};

                // Store the bans
                banList[a][b] = true;
                banList[b][a] = true;
            };

            // Store banned combinations
            for(skillName in tempBanList.BannedCombinations) {
                // Grab the group
                group = tempBanList.BannedCombinations[skillName];

                for(skillName2 in group) {
                    banCombo(skillName, skillName2);
                }
            }

            // Store category bans
            for(skillName in tempBanList.CategoryBans) {
                // Grab the category
                var cat:String = tempBanList.CategoryBans[skillName];

                for(skillName2 in (tempBanList.Categories[cat] || {})) {
                    banCombo(skillName, skillName2);
                }
            }

            // Ban the group bans
            for(var groupName:String in tempBanList.BannedGroups) {
                // Grab the group
                group = tempBanList.BannedGroups[groupName];

                for(skillName in group) {
                    for(skillName2 in group) {
                        banCombo(skillName, skillName2);
                    }
                }
            }
        }

        // Waits for the game to be ready to play
        private function waitForGame() {
            if(selectionUI == null) return;

            // Check the state
            if(globals.Game.GetState() >= 2) {
                // Show waiting UI
                waitingUI.visible = true
                return;
            }

            // Start timer to check for an update
            var timer = new Timer(100, 1);
            timer.addEventListener(TimerEvent.TIMER, waitForGame, false, 0, true);
            timer.start();
        }

        // Updates the UI based on the current state
        private function updateUI():void {
            var i:Number;

            // Ensure we have state info
            if(!lastState) return;

            var playerID:Number = globals.Players.GetLocalPlayer();
            var isSpectator:Boolean = globals.Players.IsSpectator(playerID);

            // Ensure we have a decoding numbe
            if(!isSpectator && decodeWith == -1) {
                // Ask for decoding number again
                requestDecodingNumber();
                return;
            }

            // Patch picking icons
            if(lastState.s > STAGE_VOTING) {
                // Do we need to update the filters?
                var needUpdate:Boolean = false;

                // Check if we need to do post voting stuff
                if(!initPostVoting) {
                    // Done
                    initPostVoting = true;

                    // Store useful stuff
                    MAX_SLOTS = lastState.slots;
                    hideSkills = lastState.hideSkills == 1;
                    source1 = lastState.source1 == 1;
                    banTrollCombos = lastState.trolls == 1;

                    // Patch key bindings
                    keyBindings = ['Q', 'W', 'E', 'D', 'F', 'R'];
                    keyBindings[MAX_SLOTS-1] = 'R';

                    // Load up the skills file
                    loadSkillsFile();

                    // Setup slots
                    selectionUI.setupSkillList(lastState.slots, lastState['t' + playerID], onDropMySkills);

                    // Is there a draft for us?
                    if(lastState['s'+playerID] != '') {
                        // Build a list of valid drafting skills
                        validDraftSkills = {};

                        // Build a list of the heroes we are allowed to use
                        var myHeroes:Object = {};
                        var h = lastState['s'+playerID].split('|');
                        for(var key in h) {
                            myHeroes[h[key]] = true;
                        }

                        for(var skillID in skillLookupReverse) {
                            // Grab the skill
                            skillName = skillLookupReverse[skillID];

                            // Find the owner of this skill
                            var owner:Number = GetSkillOwningHero(skillName);

                            // Check if this is one of our heroes
                            if(myHeroes[owner]) {
                                // Yep -- Store it
                                validDraftSkills[skillName] = true;
                            }
                        }

                        // We need an update!
                        needUpdate = true;
                    } else {
                        // Disable draft skills
                        validDraftSkills = null;
                    }

                    // Nuke the voting ui
                    Util.empty(votingUI);
                    this.removeChild(votingUI);
                }

                // Check if hero icons need to be patched
                if(!patchedHeroIcons) {
                    // We have now patched hero icons
                    patchedHeroIcons = true;

                    // Grab the dock
                    var dock:MovieClip = getDock();

                    // Spawn player skill lists
                    if(lastState.hideSkills) {
                        // Readers beware: The skills are encoded, changing this hook is a waste of your time!
                        if(myTeam == 3) {
                            // We are on dire
                            hookSkillList(dock.direPlayers, 5);
                        } else if(myTeam == 2) {
                            // We are on radiant
                            hookSkillList(dock.radiantPlayers, 0);
                        }
                    } else {
                        // Hook them both
                        hookSkillList(dock.radiantPlayers, 0);
                        hookSkillList(dock.direPlayers, 5);
                    }
                }

                // Have we changed local slots? (used for updating filters)
                var changedLocalSlots:Boolean = false;

                // Update skills
                for(i=0; i<10; i++) {
                    for(var j=0; j<MAX_SLOTS; j++) {
                        // Grab the skill, and decode if needed
                        var skillNumber = lastState[String(i)+String(j+1)];
                        if(skillNumber != -1) {
                            // Attempt to decode
                            if(hideSkills) {
                                skillNumber = skillNumber - decodeWith;
                            }
                        }

                        // Grab the skill name
                        var skillName = getSkillName(skillNumber);

                        // Attempt to grab the slot
                        var slot = getSkillIcon(i, j);
                        if(slot != null) {
                            slot.setSkillName(skillName);
                        }

                        // Is this skill for us?
                        if(i == parseInt(lastState[playerID])) {
                            // Put the skill into the slot
                            if(selectionUI.skillIntoSlot(j, skillName)) {
                                // A slot was changed
                                changedLocalSlots = true;
                            }
                        }
                    }
                }

                // Did we change any slots?
                if(changedLocalSlots) {
                    // Update our local ban list
                    updateLocalBans();

                    // We need to update filters
                    needUpdate = true;
                }

                // Update bans
                var b = lastState.b.split('|');
                for(key in b) {
                    skillNumber = parseInt(b[key]);
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
                    selectionUI.updateFilters();
                }
            }

            // Don't do anything if the versionUI is visible
            if(versionUI.visible) return;

            // Do we need to build from scratch?
            var fromScratch = currentStage != lastState.s;
            currentStage = lastState.s;

            switch(lastState.s) {
                case STAGE_VOTING:
                    buildVotingUI(fromScratch);
                    break;

                case STAGE_BANNING:
                    buildBanningUI(fromScratch);
                    break;

                case STAGE_PICKING:
                    buildPickingUI(fromScratch);
                    break;

                case STAGE_PLAYING:
                    if(fromScratch) {
                        hideAllUI();
                        nukeUI();
                    }
                    break;

                default:
                    trace('Unknown stage: ' + lastState.s);
                    hideAllUI();
                    break;
            }
        }

        // Builds the banning UI
        private function buildBanningUI(fromScratch:Boolean):void {
            if(fromScratch) {
                hideAllUI();
                selectionUI.visible = true;
                selectionUI.hideUncommonStuff();
                selectionUI.banningArea.visible = true;
            }
        }

        // Builds the picking UI
        private function buildPickingUI(fromScratch:Boolean):void {
            if(fromScratch) {
                hideAllUI();
                selectionUI.visible = true;
                selectionUI.hideUncommonStuff();
                selectionUI.yourSkillList.visible = true;
            }
        }

        // Builds the voting UI
        private function buildVotingUI(fromScratch:Boolean):void {
            if(fromScratch) {
                // Show correct UI
                hideAllUI();
                votingUI.visible = true;

                // Workout if we are the slave, or not
                isSlave = lastState.slaveID != -1 && lastState.slaveID != globals.Players.GetLocalPlayer();

                // Load the current options list
                var options:Object = globals.GameInterface.LoadKVFile('scripts/kv/voting.kv');

                // Rebuild the voting UI
                votingUI.setup(options, isSlave, updateVote, finishedVoting);
            }

            // Set the values
            if(fromScratch || isSlave) {
                // Update option values
                for(var i=0; i<lastState.o.length; i+=2) {
                    // Grab the data
                    var a = Util.decodeChar(lastState.o, i);
                    var b = Util.decodeChar(lastState.o, i + 1);

                    // Update the info
                    votingUI.updateSlave(a, b);
                }
            }
        }

        // Called when the version info pain is closed
        private function onVersionInfoClosed():void {
            // Hide the versionUI
            versionUI.visible = false;

            // Build the UI
            updateUI();
        }

        // Returns the current version we are running
        public function getLodVersion() {
            return versionNumber;
        }

        // Do scoreboard stuff
        private function handleScoreboard():void {
            // Reset which heroes have been built
            builtHeroes = {};

            // Builds the skill lists
            buildSkillList();

            // Patch the scoreboard
            scoreboardPatch();

            // Register for events
            this.gameAPI.SubscribeToGameEvent("npc_spawned", onNPCSpawned);
        }

		// Patches the scoreboard
		private function scoreboardPatch():void {
			var i;

			if(abilityIcons != null) {
				for(i=0; i<abilityIcons.length; ++i) {
					var ab:MovieClip = abilityIcons[i];

					if(ab != null) {
						ab.parent.removeChild(ab);
					}
				}
			}

			// Create store for ability icons
			abilityIcons = [];

			// Grab the scoreboard
			var scoreboard:MovieClip = globals.Loader_scoreboard.movieClip.scoreboard.scoreboard_anim;

			for(i=0; i<MAX_PLAYERS; ++i) {
				var newCon:MovieClip = new MovieClip();
				abilityIcons[i] = newCon;

				var con:MovieClip = scoreboard['Player' + i];
				con.addChild(newCon);

				newCon.x = 768/2 - 80;//scoreboard.width;
			}

			//var inject:MovieClip = new backgroundMask();

			//scoreboard.addChild(inject);
		}

        // Rebuilds the UI for the given hero
        private function rebuildForHero(playerID:Number):void {
            var i:Number;

            if(selectionUI == null) return;

            // Grab a hero
            var hero:Number = globals.Players.GetPlayerHeroEntityIndex(playerID);

            // Ensure it's a hero
            if(hero == -1 || !globals.Entities.IsHero(hero)) return;

            // Create an array to store abilities
            var abilityList:Array = [];

            // Workout how many abilities this hero has
            var abilityCount:Number = globals.Entities.GetAbilityCount(hero);

            // Number of found abilities
            var foundAbilities = 0;

            // Loop over all abilities
            for(i=0; i<abilityCount; ++i) {
                // Grab an abilityID
                var abilityID:Number = globals.Entities.GetAbility(hero, i);

                // Ensure a valid ability
                if(abilityID == -1 || globals.Abilities.IsHidden(abilityID)) continue;

                // Print out the name
                var abilityName = globals.Abilities.GetAbilityName(abilityID);

                // Ignore attribute bonus
                if(abilityName == 'attribute_bonus') continue;

                // Store it
                abilityList.push(abilityName);

                // Increase number of found abilities
                foundAbilities++;
            }

            // Did we find any abilities?
            if(foundAbilities > 0) {
                // Empty old icons
                Util.empty(abilityIcons[playerID]);

                // Store new icons
                for(i=0; i<abilityList.length; ++i) {
                    var ab:MovieClip = abilityIcon(abilityIcons[playerID], abilityList[i]);
                    ab.scaleX = 64/256;
                    ab.scaleY = 64/256;
                    ab.x = i*ab.width;
                    ab.y = 0;
                }
            } else {
                // Retry in 10 seconds
                var builder = new Timer(10000, 1);
                builder.addEventListener(TimerEvent.TIMER, function() {
                    rebuildForHero(playerID);
                });
                builder.start();
            }
        }

		// Builds the skill lists
		private function buildSkillList():void {
			// Grab all the heroes
			var heroes:Array = globals.Entities.GetAllHeroEntities();

			for(var i:Number=0; i<MAX_PLAYERS; ++i) {
                (function() {
                    // Store playerID
                    var playerID = i;

                    // Grab a hero
                    var hero:Number = globals.Players.GetPlayerHeroEntityIndex(playerID);

                    // Ensure it's a hero
                    if(hero == -1 || !globals.Entities.IsHero(hero)) return;

                    // Use player names to find the correct slots
                    var nameCompare = globals.Players.GetPlayerName(playerID);
                    playerID = -1;
                    for(var k=0; k<10; ++k) {
                        var name1:String = globals.Loader_scoreboard.movieClip.scoreboard.scoreboard_anim['Player' + k].PlayerName.textField.text;

                        if(name1 == nameCompare) {
                            playerID = k;
                            break;
                        }
                    }

                    if(playerID == -1) return;

                    // Only process each hero once
                    if(builtHeroes[hero]) return;
                    builtHeroes[hero] = true;

                    // Build the list for this player
                    rebuildForHero(playerID);
                })();
			}
		}

		// An NPC spawned, hook it for skills
		private function onNPCSpawned(keys:Object):void {
            // Update the skill list
			buildSkillList();
		}

        // Stores a skill icon
        private function storeSkillIcon(playerID:Number, slotID:Number, reference:MovieClip):void {
            // Ensure a slot exists for this player
            if(!topSkillList[playerID]) topSkillList[playerID] = [];

            // Store the reference
            topSkillList[playerID][slotID] = reference;
        }

        // Gets a skill icon for the given player and slot
        private function getSkillIcon(playerID:Number, slotID:Number) {
            // Check if a store for this player exists
            if(!topSkillList[playerID]) return null;

            // Return the skill if it exists
            return topSkillList[playerID][slotID];
        }

        // Adds the skill lists to a given mc
        private function hookSkillList(players:MovieClip, playerIdStart):void {
            // Ensure our reference to players isn't null
            if(players == null) {
                trace('\n\nWARNING: Null reference passed to hookSkillList!\n\n');
                return;
            }

            // The playerID we are up to
            var playerID:Number = playerIdStart;

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
                sl.setColor(playerID);

                // Store it
                injectedMovieClips.push(sl);

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
                    storeSkillIcon(playerID, j, ps);
                }

                // Center it perfectly
                sl.x = 0;
                sl.y = 22;

                // Move the icon up a little
                con.heroIcon.y = -15;

                // Store this skill list into the container
                con.addChild(sl);

                // Move onto the next playerID
                playerID++;
            }
        }

        private function resetHeroIcons():void {
            // Grab the dock
            var dock:MovieClip = getDock();

            // Reset the positions
            resetHeroIconY(dock.radiantPlayers);
            resetHeroIconY(dock.direPlayers);

            // Hero icons are no longer patched
            patchedHeroIcons = false;
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

		// Make an ability icon
        public static function abilityIcon(container:MovieClip, ability:String):MovieClip {
            // Create it
            var obj:MovieClip = new DotaAbility();//new dotoClass();
            obj.setSkillName(ability);
            container.addChild(obj);

            // Return the button
            return obj;
        }

        // When someone hovers over a skill
        public static function onSkillRollOver(e:MouseEvent):void {
            // Don't show stuff if we're dragging
            if(EasyDrag.isDragging()) return;

            // Grab what we rolled over
            var s:Object = e.target;

            // Ensure there is a skill to show
            if(!s.skillName) return;

            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(s.width*scalingFactor*0.5, 0));

            var offset = 0;
            if(lp.x < stageWidth/2) {
                offset = s.width * scalingFactor;
            }

            // Workout where to put it
            lp = s.localToGlobal(new Point(0, 0));

            // Decide how to show the info
            if(lp.x+offset < stageWidth/2) {
                // Face to the right
                Globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip(lp.x+offset, lp.y, s.skillName);
            } else {
                // Face to the left
                Globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, s.skillName);
            }
        }

        // When someone stops hovering over a skill
        public static function onSkillRollOut(e:MouseEvent):void {
            // Hide the skill info pain
            Globals.Loader_heroselection.gameAPI.OnSkillRollOut();
        }

        // Updates local bans
        private function updateLocalBans():void {
            // Reset banned combos
            bannedCombos = {};

            // Loop over all slots
            for(var i:Number=0; i<MAX_SLOTS; i++) {
                // Grab a slot
                var skill:String = selectionUI.getSkillInSlot(i);

                // Validate the skill
                if(skill != null) {
                    // Are there any banned combos for this skill?
                    if(banList[skill] != null) {
                        // Add to bans
                        for(var skill2:String in banList[skill]) {
                            // Store the ban
                            bannedCombos[skill2] = true;
                        }
                    }

                }
            }
        }

        /*
            FIXES
        */

        // When the unit selection is updated
        private function onUnitSelectionUpdated():void {
            var fixerTimer = new Timer(1);
            fixerTimer.addEventListener(TimerEvent.TIMER, fixHotkeys, false, 0, true);
            fixerTimer.start();
        }

        // Fixes the hot keys
        private function fixHotkeys():void {
            // Set the text
            for(var i:Number=0; i<6; i++) {
                globals.Loader_actionpanel.movieClip.middle.abilities['abilityBind'+i].label.text = keyBindings[i];
            }
        }

        /*
            HELPER METHODS
        */

        // Adds chat to the chat window
        public static function addChatMessage(msg:String):void {
            // Attend to chat
            Globals.Loader_shared_heroselectorandloadout.movieClip.appendChatText(msg);
        }

        // Grabs the hero dock
        private function getDock():MovieClip {
            return globals.Loader_shared_heroselectorandloadout.movieClip.heroDock;
        }

        /*
            SEVER EVENT CALLBACKS
        */

        // Handles the state info
        private function onGetStateInfo(args:Object):void {
            //trace('Current stage: ' + args.s);

            // Store the state info
            lastState = args;

            // Grab our playerID
            var playerID = globals.Players.GetLocalPlayer();

            // Check if this is our first time through
            if(firstTimeState) {
                // No longer our first time
                firstTimeState = false;

                // Hide the waiting UI
                waitingUI.visible = false;

                // Show version info
                versionUI.visible = true;

                // Ensure there is version info
                if(!args.v) args.v = '';

                // Compare version info
                var ourVersion:String = getLodVersion();
                if(args.v != ourVersion) {
                    trace('LoD: Version mismatch! Server: ' + args.v + ' VS Us: ' + ourVersion);

                    // Show error page
                    versionUI.gotoAndStop(2);

                    // Update header
                    versionUI.header.text = "#outDated";
                } else {
                    trace('LoD: Version checks out!');

                    // Show success page
                    versionUI.gotoAndStop(1);

                    // Update header
                    versionUI.header.text = "#uptoDate";
                }

                // Append version info
                versionUI.helpField.text += 'Server: ' + args.v + '\nYour Client: ' + ourVersion;
            }

            // Update the UI
            updateUI();
        }

        // Fired when the server sends us a slave vote update
        private function handleSlave(args:Object):void {
            if(initPostVoting) return;
            votingUI.updateSlave(args.opt, args.nv);
        }

        // Fired when the server sends us a decoding code
        private function handleDecode(args:Object):void {
            // Was this me? (or everyone)
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID) {
                // Store the new decoder
                decodeWith = args.code - encodeWith;

                // Store teamID
                myTeam = parseInt(args.team);
            }
        }

        // Fired when a skill is picked by someone
        private function onSkillPicked(args:Object) {
            // Grab skill number
            var skillNumber:Number = parseInt(args.skillID);

            // Attempt to decode
            if(hideSkills) {
                skillNumber = skillNumber - decodeWith;
            }

            // Grab the skill name
            var skillName:String = getSkillName(skillNumber);

            // Did we fail to decode?
            if(skillName == null) return;

            // Attempt to find the skill
            var topSkill = getSkillIcon(args.playerSlot, args.slotNumber);
            if(topSkill != null) {
                topSkill.setSkillName(skillName);
            } else {
                trace('WARNING: Failed to find playerID '+args.playerID+', slot '+args.playerSlot);
            }

            // Was this me?
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID) {
                // It is me
                selectionUI.skillIntoSlot(args.slotNumber, skillName);

                // Update local bans
                updateLocalBans();

                // Update the filters
                selectionUI.updateFilters();
            }
        }

        private function onSlotSwapped(args:Object) {
            // Was this me?
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID) {
                selectionUI.onSlotSwapped(args.slot1, args.slot2);
            }
        }

        // Fired when the server sends us an error
        private function handleMessage(args:Object):void {
            // Was this me? (or everyone)
            var playerID = globals.Players.GetLocalPlayer();
            if(playerID == args.playerID || args.playerID == -1) {
                // Add the text to chat
                addChatMessage(args.msg);
            }
        }

        /*
            SERVER COMMANDS
        */

        // Updates a user's vote with the server
        private function updateVote(optNumber:Number, myChoice:Number):void {
            gameAPI.SendServerCommand("lod_vote \""+optNumber+"\" \""+myChoice+"\"");
        }

        // Finishes voting
        private function finishedVoting():void {
            gameAPI.SendServerCommand("finished_voting");
        }

        // Requests the decoding number
        private function requestDecodingNumber():void {
            // Send the request
            gameAPI.SendServerCommand("lod_decode \""+encodeWith+"\"");
        }

        // Tell the server to put a skill into a slot
        private function tellServerWeWant(slotNumber:Number, skillName:String):void {
            // Send the message to the server
            gameAPI.SendServerCommand("lod_skill \""+slotNumber+"\" \""+skillName+"\"");
        }

        // Tell the server to put a skill into a slot
        private function tellServerToSwapSlots(slot1:Number, slot2:Number):void {
            // Send the message to the server
            gameAPI.SendServerCommand("lod_swap_slots \""+slot1+"\" \""+slot2+"\"");
        }

        // Tell the server to ban a given skill
        private function tellServerToBan(skill:String):void {
            // Send the message to the server
            gameAPI.SendServerCommand("lod_ban \""+skill+"\"");
        }

        // Request more time from the server
        public static function requestMoreTime():void {
            GameAPI.SendServerCommand("lod_more_time");
        }

        // Locks our skills
        public static function lockSkills():void {
            GameAPI.SendServerCommand("lod_lock_skills");
        }

        // Fired when the server bans a skill
        private function onSkillBanned(args:Object) {
            // Grab the skill
            var skillName:String = args.skill;

            // Store this skill as banned
            bannedSkills[skillName] = true;

            // Update Filters
            selectionUI.updateFilters();
        }

        /*
            LISTENER EVENTS
        */

        // Listens for keyboard presses
        private function onKeyBoardDown(e:KeyboardEvent):void {
            // Cleanup
            if(selectionUI == null) {
                return;
            }

            if(e.keyCode == Keyboard.CONTROL) {
                // Toggle the hero icons
                selectionUI.toggleHeroIcons();
            }
        }

        /*
            DRAGGING EVENTS
        */

        // We are trying to drag an actual skill
        public static function skillSlotDragBegin(me:MovieClip, dragClip:MovieClip):Boolean {
            // Grab the name of the skill
            var skillName = me.getSkillName();

            // Can we even drag this skill?
            if(skillName == 'nothing') {
                // Stop the drag
                return false;
            }

            // Load a skill into the dragClip
            Globals.LoadAbilityImage(skillName, dragClip);

            // Store the skill
            dragClip.skillName = skillName;

            // Store that it is a skill drag
            dragClip.dragType = DRAG_TYPE_SKILL;

            // Enable dragging
            return true;
        }

        // Something is dragged into a slot
        private function onDropMySkills(me:MovieClip, dragClip:MovieClip) {
            if(dragClip.dragType == DRAG_TYPE_SKILL) {
                // A skill is being dragged into a slot
                var skillName:String = dragClip.skillName;

                // Tell the server about this
                tellServerWeWant(me.getSkillSlot(), skillName);
            } else if(dragClip.dragType == DRAG_TYPE_SLOT) {
                // A slot is being dragged into a slot
                var slot1:Number = dragClip.slotNumber;
                var slot2:Number = me.getSkillSlot();

                // Tell the server to swap slots
                tellServerToSwapSlots(slot1, slot2);
            }
        }

        // Something is being dragged into the banning area
        private function onDropBanningArea(me:MovieClip, dragClip:MovieClip) {
            if(dragClip.dragType == DRAG_TYPE_SKILL) {
                var skillName = dragClip.skillName;

                // Tell the server to ban this skill
                tellServerToBan(skillName);
            }
        }
	}
}
