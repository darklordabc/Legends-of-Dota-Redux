package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	// Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // For showing the info pain
    import flash.geom.Point;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class lod extends MovieClip {
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		// The mask
		public var tempMask:MovieClip;

		// List of heroes we already built a skill list for
		public var builtHeroes:Object;

		// Max players to deal with
		public var MAX_PLAYERS:Number = 10;

		// The scaling factor
		private var scalingFactor:Number;

		// Containers for ability icons
		public static var abilityIcons:Array;

		public function lod() {}

		// called by the game engine when this .swf has finished loading
		public function onLoaded():void {
			trace('LoD new hud loading...');

			// Fix scaling
			fixScreenScaling();

			// Make us visible
			this.visible = true;

			// Hide the mask
			tempMask.visible = false;

			// Reset which heroes have been built
			builtHeroes = {};

			// Builds the skill lists
			buildSkillList();

			// Patch the scoreboard
			scoreboardPatch();

			// Register for events
			this.gameAPI.SubscribeToGameEvent("npc_spawned", onNPCSpawned);
			//this.gameAPI.SubscribeToGameEvent("ops", onGetOptions);
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

                    // Maps colors to IDs
                    var colorMap = {
                        4294931763: 0,
                        4290772838: 1,
                        4290707647: 2,
                        4278972659: 3,
                        4278217727: 4,
                        4290938622: 5,
                        4282889377: 6,
                        4294433125: 7,
                        4280386304: 8,
                        4278217124: 9
                    };

                    playerID = colorMap[globals.Players.GetPlayerColor(playerID)];
                    if(playerID == null) return;

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
	}
}
