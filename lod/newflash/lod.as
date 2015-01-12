package  {
    // Flash stuff
	import flash.display.MovieClip;

    // Other events
	import flash.events.MouseEvent;

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
        private static var MAX_SLOTS = 4;

        // The team number we are on
        private var myTeam:Number = 0;

        // Access to the skills at the top
        private var topSkillList:Array = [];

        /*
            SKILL LIST STUFF
        */

        // Have we loaded the skill list yet?
        private var loadedSkillList:Boolean = false;

        // Stores bans
        private var banList:Object;

        // skillName --> skillID
        private static var skillLookup:Object;

        // Which tabs are allowed
        private static var allowedTabs:Object;

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

            // Store static globals
            Globals = globals;

            // Prepare UI
            prepareUI();

            // Load bans
            loadBansFile();

            // Load the version
            var versionFile:Object = globals.GameInterface.LoadKVFile('addoninfo.txt');
            versionNumber = versionFile.version;

            // Ask for decoding info
            requestDecodingNumber();

            // Subscribe to the state info
            this.gameAPI.SubscribeToGameEvent("lod_state", onGetStateInfo); // Contains most of the game state
            this.gameAPI.SubscribeToGameEvent("lod_slave", handleSlave);    // Someone has updated a voting option
            this.gameAPI.SubscribeToGameEvent("lod_decode", handleDecode);  // Server sent us info on how to decode skill values

            // Handle the scoreboard stuff
            //handleScoreboard();

			//this.gameAPI.SubscribeToGameEvent("ops", onGetOptions);

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
            btn.addEventListener(MouseEvent.CLICK, onVersionInfoClosed);

            // Wait for the game to be ready
            waitForGame();
        }

        // Loads in the skills file
        private function loadSkillsFile():void {
            // Check if the skill list needs to be loaded
            if(loadedSkillList) return;

            // Skill list is now loaded
            loadedSkillList = true;

            // Load in the skill list
            var skillKV = globals.GameInterface.LoadKVFile('scripts/kv/abilities.kv');
            var tempSkillList:Object = skillKV.skills;

            // Create the object
            skillLookup = {};

            // Tabs to allow (this will be sent from the server eventually)
            allowedTabs = {
                main: true//,
                //neutral: true,
                //wraith: true
            };

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
                        if(!lastState.s1) {
                            doInclude = false;
                        }
                    }

                    // If we should include it, do it
                    if(doInclude) {
                        if(!isNaN(parseInt(skillIndex))) {
                            skillLookup[skillName] = parseInt(skillIndex);
                        }
                    }
                }
            }

            // Rebuild the skill list
            selectionUI.Rebuild(skillKV.tabs, lastState.s1);
        }

        // Checks if a given skill is valid, or not
        public static function isValidSkill(skillName:String):Boolean {
            // Ensure a skill is passed
            if(!skillName) return false;

            // Check if there is an index for it
            return skillLookup[skillName] != null;
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

        // Handles the state info
        private function onGetStateInfo(args:Object):void {
            trace('Got state info :)');
            trace('Current stage: ' + args.s);

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

        // Updates the UI based on the current state
        private function updateUI():void {
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
                // Store useful stuff
                MAX_SLOTS = lastState.slots;

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

                // Load up the skills file
                loadSkillsFile();
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
                    hideAllUI();
                    selectionUI.visible = true;
                    break;

                case STAGE_PICKING:
                    hideAllUI();
                    selectionUI.visible = true;
                    break;

                default:
                    trace('Unknown stage: ' + lastState.s);
                    hideAllUI();
                    break;
            }
        }

        // Builds the voting UI
        private function buildVotingUI(fromScratch:Boolean) {
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

        // Fired when the server sends us a slave vote update
        private function handleSlave(args:Object):void {
            votingUI.updateSlave(args.opt, args.nv);
        }

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

                    var builder = new Timer(2000, 1);
                    builder.addEventListener(TimerEvent.TIMER, function() {
                        // Workout how many abilities this hero has
                        var abilityCount:Number = globals.Entities.GetAbilityCount(hero);

                        // Number of found abilities
                        var foundAbilities = 0;

                        // Loop over all abilities
                        for(var j:Number=0; j<abilityCount; ++j) {
                            // Grab an abilityID
                            var abilityID:Number = globals.Entities.GetAbility(hero, j);

                            // Ensure a valid ability
                            if(abilityID == -1 || globals.Abilities.IsHidden(abilityID)) continue;

                            // Print out the name
                            var abilityName = globals.Abilities.GetAbilityName(abilityID);

                            // Ignore attribute bonus
                            if(abilityName == 'attribute_bonus') continue;

                            var ab:MovieClip = abilityIcon(abilityIcons[playerID], abilityName);
                            ab.scaleX = 64/256;
                            ab.scaleY = 64/256;
                            ab.x = foundAbilities*ab.width*0.5;
                            ab.y = 0;

                            // Increase number of found abilities
                            foundAbilities++;
                        }
                    });
                    builder.start();
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
                    //EasyDrag.dragMakeValidFrom(ps, skillSlotDragBegin);

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
            //if(EasyDrag.isDragging()) return;

            // Grab what we rolled over
            var s:Object = e.target;

            // Ensure there is a skill to show
            if(!s.skillName) return;

            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(s.width*scalingFactor*0.5, 0));

            var offset = 0;
            if(lp.x < stageWidth/2) {
                offset = s.width*2;
            }

            // Workout where to put it
            lp = s.localToGlobal(new Point(offset, 0));

            // Decide how to show the info
            if(lp.x < stageWidth/2) {
                // Face to the right
                Globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip(lp.x, lp.y, s.skillName);
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

        // Grabs the hero dock
        private function getDock():MovieClip {
            return globals.Loader_shared_heroselectorandloadout.movieClip.heroDock;
        }
	}
}
