package  {
	// Flash Libraries
	import flash.display.MovieClip;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;
    import scaleform.clik.events.ButtonEvent;

    // Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // For chrome browser
    import flash.utils.getDefinitionByName;

    //import scaleform.clik.controls.Button;
    import fl.controls.Button;
    import flash.events.MouseEvent;

	public class test extends MovieClip {
		// Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // Play area stuff
        public var playClip:MovieClip;
        public var playMain:MovieClip;
        public var customTabNum:int = 1337;

        // These vars determain how much of the stage we can use
        // They are updated as the stage size changes
        public var maxStageWidth:Number = 1366;
        public var maxStageHeight:Number = 768;

        // Stores a page
        public var chrome_html:MovieClip;

        // Function to repeat a string many times
        public function strRep(str, count) {
            var output = "";
            for(var i=0; i<count; i++) {
                output = output + str;
            }

            return output;
        }

        public function isPrintable(t) {
        	if(t == null || t is Number || t is String || t is Boolean || t is Function || t is Array) {
        		return true;
        	}
        	// Check for vectors
        	if(flash.utils.getQualifiedClassName(t).indexOf('__AS3__.vec::Vector') == 0) return true;

        	return false;
        }

        public function PrintTable(t, indent=0, done=null) {
        	var i:int, key, key1, v:*;

        	// Validate input
        	if(isPrintable(t)) {
        		trace("PrintTable called with incorrect arguments!");
        		return;
        	}

        	if(indent == 0) {
        		trace(t.name+" "+t+": {")
        	}

        	// Stop loops
        	done ||= new flash.utils.Dictionary(true);
        	if(done[t]) {
        		trace(strRep("\t", indent)+"<loop object> "+t);
        		return;
        	}
        	done[t] = true;

        	// Grab this class
        	var thisClass = flash.utils.getQualifiedClassName(t);

        	// Print methods
			for each(key1 in flash.utils.describeType(t)..method) {
				// Check if this is part of our class
				if(key1.@declaredBy == thisClass) {
					// Yes, log it
					trace(strRep("\t", indent+1)+key1.@name+"()");
				}
			}

			// Check for text
			if("text" in t) {
				trace(strRep("\t", indent+1)+"text: "+t.text);
			}

			// Print variables
			for each(key1 in flash.utils.describeType(t)..variable) {
				key = key1.@name;
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
			}

			// Find other keys
			for(key in t) {
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
        	}

        	// Get children
        	if(t is MovieClip) {
        		// Loop over children
	        	for(i = 0; i < t.numChildren; i++) {
	        		// Open bracket
					trace(strRep("\t", indent+1)+t.name+" "+t+": {");

					// Recurse!
	        		PrintTable(t.getChildAt(i), indent+1, done);

	        		// Close bracket
					trace(strRep("\t", indent+1)+"}");
	        	}
        	}

        	// Close bracket
        	if(indent == 0) {
        		trace("}");
        	}
        }

		// For testing only
		public function test() : void {
			//trace("injected by ash47!\n\n\n");
			PrintTable(this);
		}

		public function onLoaded() : void {
			trace("injected by ash47!\n\n\n");

			this.gameAPI.OnReady();
         	Globals.instance.resizeManager.AddListener(this);

         	// Create timer to inject
         	var injectTimer:Timer = new Timer(1000, 1);
            injectTimer.addEventListener(TimerEvent.TIMER, logTest);
            injectTimer.start();
		}

		public function onResize(re:ResizeManager) : * {
			trace("Injected by Ash47!\n\n\n");
			x = 0;
			y = 0;
			visible = true;

			this.scaleX = re.ScreenWidth/maxStageWidth;
            this.scaleY = re.ScreenHeight/maxStageHeight;
		}

        public function onClickerClicked(obj:Object) {
            trace("Pressed!");

            /*globals.Loader_lobby_settings.movieClip.setLocalLobby(false, true);
            globals.Loader_lobby_settings.movieClip.LobbySettings.custom.visible = true;

            globals.Loader_lobby_settings.movieClip.clearCustomMaps();
            globals.Loader_lobby_settings.movieClip.addCustomMap("nian3");
            globals.Loader_lobby_settings.movieClip.addCustomGame(0, "Custom Spell Power");

            globals.Loader_lobby_settings.movieClip.AllowCustomGames = true;

            globals.Loader_lobby_settings.movieClip.CustomMapName = "nian3";
            //globals.Loader_lobby_settings.movieClip.nCustomGameIndex = 0;*/

            //globals.Loader_dashboard_overlay.movieClip.showCustomGameModeFlyout("1", false, false, "4");
            //globals.Loader_dashboard_overlay.movieClip.onCustomGameCreateLobbyButtonClicked(null);

            //globals.Loader_dashboard_overlay.movieClip.customGameMenu.visible = true;
            //globals.Loader_dashboard_overlay.movieClip.customLobbyMenu.visible = true;
            //globals.Loader_dashboard_overlay.movieClip.ignoreClick = true;

            //PrintTable(globals);

            //globals.Loader_play.movieClip.PlayWindow.PlayMain.CustomGameQuickJoinStatus.visible = true;
            //globals.Loader_play.movieClip.setCurrentTab(12);

            //globals.Loader_play.movieClip.setCustomGameModeListRow(0, "Custom Spell Power", "A gamemode by Ash47 where everything is OP.", "28090256", true, "5/25", "15");

            var i = 0;
            while(i < globals.Loader_play.movieClip.numNavTabs) {
                trace(i);
                globals.Loader_play.movieClip.PlayWindow.PlayMain.Nav["tab" + i].enabled = true;
                globals.Loader_play.movieClip.PlayWindow.PlayMain.Nav["tab" + i].visible = true;
                i++;
            }

            globals.Loader_play.movieClip.setCustomLobbyListRow(0, "Custom Spell Power", "An awesome lobby!", "5/10", true, "15", "32", 28090256, "Ash47");

            //globals.Loader_dashboard_overlay.gameAPI.CustomGame_CreateLobby();

            globals.Loader_workshop.movieClip.workshop.workshop_internal.publish_file.selectSubmissionType.customgame.visible = true;
            //globals.Loader_workshop.movieClip.customGame_addFolder("csp");
            //globals.Loader_workshop.gameAPI.OnCustomGameFolderComboChanged("csp");

            //publish_file.importCustomGame.importButton
        }

		public function logTest(e:TimerEvent) {
			trace("Injected by Ash47!\n\n\n");

			//PrintTable(globals);

			/*var steamID = globals.Loader_friends.movieClip.friends_main.friends.AddFriendsDialog.yourfriendid.textField.text.substring(12);
			trace(steamID);
			var playerName = globals.Loader_profile_mini.movieClip.ProfileMini_main.ProfileMini.Persona.Player.PlayerNameOnline.text;
			trace(playerName);

			var chat = globals.Loader_chat.movieClip.chat_main.chat.participantsList.ParticipantEntry0;
			trace(chat.PlayerName);
			trace(chat.PlayerName.text);
			trace(chat.PlayerName.value);
			trace(chat.steamID);*/

            //globals.Loader_dashboard_overlay.movieClip.onCustomLobbyCreateLobbyButtonClicked();

            //globals.Loader_dashboard_overlay.movieClip.customLobbyMenu.visible = true;
            //globals.Loader_dashboard_overlay.movieClip.customLobbyMenu.enabled = true;

            //globals.Loader_worldmap.movieClip.CustomGameDialog.visible = true;
            //globals.Loader_worldmap.movieClip.CustomGameDialog.enabled = true;

            var clicker = new Button();
            addChild(clicker);
            clicker.x = 4;
            clicker.y = 64;
            clicker.scaleX = 0.5;
            clicker.scaleY = 0.5;
            clicker.label = "Inject";
            clicker.addEventListener(MouseEvent.CLICK, onClickerClicked);

            //globals.Loader_lobby_settings.movieClip.setLocalLobby(false, true);
            //globals.Loader_lobby_settings.movieClip.LobbySettings.custom.visible = true;

			// Hook vars
			playClip = globals.Loader_play.movieClip;
			playMain = playClip.PlayWindow.PlayMain;

			var ymax = 0;
			var xmin = 1000;

			for(var i=0; i<playClip.numNavTabs; i++) {
				var clip = playMain.Nav["tab"+i];
				if(clip.y > ymax) {
					ymax = clip.y;
				}

				if(clip.x < xmin) {
					xmin = clip.x;
				}
			}

			/*var customLobby = new test_class();
			playMain.addChild(customLobby);
			customLobby.x = xmin+16;
			customLobby.y = ymax;

			customLobby.addEventListener(ButtonEvent.CLICK, onCustomLobbyClicked);

			// Fix issue with tab not existing
			playMain.Nav["tab"+customTabNum] = {
				selected: false
			};*/

			// Create chrome window
			//InitChromeHTMLRenderTarget();
		}

		public function onCustomLobbyClicked(obj:Object) {
			// Change to correct tab
			playClip.setCurrentTab(1);
			playClip.setCurrentTab(customTabNum);
		}

		public function InitChromeHTMLRenderTarget() : * {
			var rtClass:Class = null;
			var i:* = 0;
			if(this.chrome_html == null)
			{
				rtClass = getDefinitionByName("ChromeHTML") as Class;
				this.chrome_html = new rtClass() as MovieClip;
				this.chrome_html.name = "chrome_html";
				this.addChild(this.chrome_html);
				/*this.chrome_html.FocusInCallback = this.onHTMLFocusIn;
				this.chrome_html.FocusOutCallback = this.onHTMLFocusOut;
				this.chrome_html.KeyDownCallback = this.onHTMLKeyDown;
				this.chrome_html.KeyUpCallback = this.onHTMLKeyUp;
				this.chrome_html.MouseMoveCallback = this.onHTMLMouseMove;
				this.chrome_html.MouseDownCallback = this.onHTMLMouseDown;
				this.chrome_html.MouseUpCallback = this.onHTMLMouseUp;
				this.Today.sbv.addEventListener(Event.SCROLL,this.onHTMLVertScrollBarChanged);
				this.Today.sbh.addEventListener(Event.SCROLL,this.onHTMLHorzScrollBarChanged);
				this.Today.setChildIndex(this.Today.innerShadow,this.Today.numChildren-1);
				this.chrome_html.addEventListener(TextEvent.TEXT_INPUT,this.onHTMLTextInput);*/
			}
			//this.chrome_html.y = this.Today.sbv.y;
			this.chrome_html.visible = true;
			this.chrome_html["lastScreenWidth"] = Globals.instance.resizeManager.ScreenWidth;
			this.chrome_html["lastScreenHeight"] = Globals.instance.resizeManager.ScreenHeight;
			//this.gameAPI.SetHTMLBrowserSize(this.chrome_html.width,this.chrome_html.height,Globals.instance.resizeManager.ScreenWidth,Globals.instance.resizeManager.ScreenHeight);

			trace("\n\n\nKeys:");
			for(var key in this.chrome_html) {
				trace(key);
			}
		}
	}

}
