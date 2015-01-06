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

        /*
            CONSTANTS
        */

        // The version we are running
        private var versionNumber:String;

        // Max players to deal with
        private var MAX_PLAYERS:Number = 10;

        // The scaling factor
        private var scalingFactor:Number;

        // Have we gotten any state info before?
        private var firstTimeState:Boolean = true;

        // Stage info
        private static var STAGE_WAITING:Number = 0;
        private static var STAGE_VOTING:Number = 1;
        private static var STAGE_BANNING:Number = 2;
        private static var STAGE_PICKING:Number = 3;
        private static var STAGE_PLAYING:Number = 4;

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

		// called by the game engine when this .swf has finished loading
		public function onLoaded():void {
			trace('\n\nLoD new hud loading...');

			// Fix scaling
			fixScreenScaling();

			// Make us visible
			this.visible = true;

            // Prepare UI
            prepareUI()

            // Load the version
            var versionFile:Object = globals.GameInterface.LoadKVFile('addoninfo.txt');
            versionNumber = versionFile.version;

            // Subscribe to the state info
            this.gameAPI.SubscribeToGameEvent("lod_state", onGetStateInfo); // Contains most of the game state
            this.gameAPI.SubscribeToGameEvent("lod_slave", handleSlave);    // Someone has updated a voting option

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
        }

        // Prepares the UI, waiting for state info
        private function prepareUI():void {
            // Hide all the UI stuff
            hideAllUI();

            // Add accept button to versionUI
            var btn:MovieClip = Util.smallButton(versionUI.acceptButton, '#versionAccept', true, true);
            btn.addEventListener(MouseEvent.CLICK, onVersionInfoClosed);

            // Wait for the game to be ready
            waitForGame();
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
                } else {
                    trace('LoD: Version checks out!');

                    // Show success page
                    versionUI.gotoAndStop(1);
                }

                // Append version info
                versionUI.helpField.text += 'Server: ' + args.v + '\nYour Client: ' + ourVersion;
            }

            // Update the UI
            updateUI();
        }

        // Updates the UI based on the current state
        private function updateUI():void {
            // Don't do anything if the versionUI is visible
            if(versionUI.visible) return;

            // Ensure we have state info
            if(!lastState) return;

            // Do we need to build from scratch?
            var fromScatch = currentStage == lastState.s;
            currentStage = lastState.s;

            switch(lastState.s) {
                case STAGE_VOTING:
                    buildVotingUI(fromScatch);
                    break;

                default:
                    trace('Unknown stage: ' + lastState.s);
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
                votingUI.setup(options, isSlave);
            }

            // Update option values
            for(var i=0; i<lastState.o.length; i+=2) {
                // Grab the data
                var a = Util.decodeChar(lastState.o, i);
                var b = Util.decodeChar(lastState.o, i + 1);

                // Update the info
                votingUI.updateSlave(a, b);
            }
        }

        // Fired when the server sends us a slave vote update
        private function handleSlave(args:Object):void {
            votingUI.updateSlave(args.opt, args.nv);
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

		// Make an ability icon
        public function abilityIcon(container:MovieClip, ability:String):MovieClip {
            // Create it
            var obj:MovieClip = new DotaAbility(ability);//new dotoClass();
            container.addChild(obj);

            // Add image
            globals.LoadAbilityImage(ability, obj.ability.AbilityArt);

            // Add the cover command
            obj.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
            obj.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);

            // Return the button
            return obj;
        }

        // When someone hovers over a skill
        private function onSkillRollOver(e:MouseEvent):void {
            // Don't show stuff if we're dragging
            //if(EasyDrag.isDragging()) return;

            // Grab what we rolled over
            var s:Object = e.target;

            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(s.width*scalingFactor*0.5, 0));

            var offset = 0;
            if(lp.x < stage.stageWidth/2) {
                offset = s.width*2;
            }

            // Workout where to put it
            lp = s.localToGlobal(new Point(offset, 0));

            // Decide how to show the info
            if(lp.x < stage.stageWidth/2) {
                // Face to the right
                globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip(lp.x, lp.y, s.skillName);
            } else {
                // Face to the left
                globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, s.skillName);
            }
        }

        // When someone stops hovering over a skill
        private function onSkillRollOut(e:MouseEvent):void {
            // Hide the skill info pain
            globals.Loader_heroselection.gameAPI.OnSkillRollOut();
        }

        // Grabs the hero dock
        private function getDock():MovieClip {
            return globals.Loader_shared_heroselectorandloadout.movieClip.heroDock;
        }
	}
}
