package  {
    // Flash Libraries
    import flash.display.MovieClip;

    // For showing the info pain
    import flash.geom.Point;
    import flash.events.MouseEvent;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;

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
        private static var realScreenWidth = 640;
        private static var realScreenHeight = 480;

        // Stores the scaling factor
        private static var scalingFactor = 1;

        // When the hud is loaded
        public function onLoaded():void {
            // Tell everyone we're loading
            trace('\n\nLegends of Dota hud is loading...');

            // Spawn player skill lists
            hookSkillList(globals.Loader_shared_heroselectorandloadout.movieClip.heroDock.radiantPlayers);
            hookSkillList(globals.Loader_shared_heroselectorandloadout.movieClip.heroDock.direPlayers);

            // Hook resizing
            Globals.instance.resizeManager.AddListener(this);
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
        }

        // Adds the skill lists to a given mc
        private function hookSkillList(players:MovieClip) {
            // Ensure our reference to players isn't null
            if(players == null) {
                trace('\n\nWARNING: Null reference passed to hookSkillList!\n\n');
                return;
            }

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
                sl.y = -24;

                // Store this skill list into the container
                con.addChild(sl);
            }
        }

        // When someone hovers over a skill
        private function onSkillRollOver(e:MouseEvent) {
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
        private function onSkillRollOut(e:MouseEvent) {
            // Hide the skill info pain
            globals.Loader_heroselection.gameAPI.OnSkillRollOut();
        }
    }
}