Legends of Dota
=====

###About###
 - Pick your skills to build an overpowered masterpiece!
 - Test out different combinations!
 - Create unique and creative heros to dominate your opponent.

###Want to show your support?###
[![Donate](https://www.paypalobjects.com/en_AU/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2S6LTGPBK4YEA)

###Current Features###
 - Picking Interface
 - Basic Option Selection Interface
 - Basic Banning Interface (You can ban skills)
 - Unlimited skill selection time
 - Option to have between 4 and 6 slots
 - Option to have between 0 and 6 regular abilities
 - Option to have between 0 and 6 ultimate abilities
 - Option to change starting level
 - Option to enable easy mode
 - Option to hide enemy team's draft from the picking screen (This is hard to implement)
 - Option to select number of skills to ban and allow only host to ban skills
 - Limited Wraith Night Skills
 - Limited Neutral Skills
 - Game Variants
  - All Pick, provides the full hero pool
  - Single Draft, everyone gets a random choice of 10 heroes (You can only use the skills from these heroes)
  - Mirror Draft, both teams get the same hero pool
  - All Random, everyone gets a random hero and random spells

###Workshop Version###
 - There is a less good workshop version available [here](http://steamcommunity.com/sharedfiles/filedetails/?id=296590332)
 - It is running the older version of dota 2, which means old spells, old map, no bounty rune, etc

###Setting up your local client to connect to a source1 server###
 - **DO THIS ONCE, REPEAT WHEN YOU NEED TO UPDATE**
  - Close dota 2 (it won't load most updates / mods that are installed with this method unless you restart dota 2)
  - Download [The latest release from here](https://github.com/ash47/LegendsOfDota/releases)
  - Extract ONLY the `lod` folder into your `dota 2 beta/dota/addons` folder (creating addons if it doesn't exist)
  - If there are any other folders inside your `addons` folder, please either delete them, or move them into another folder (such as `addons_disabled`)
 - **DO THIS ONCE**
  - Open `dota 2 beta/dota/gameinfo.txt`
  - Add `Game       |gameinfo_path|addons/lod` without quotes on a new line BELOW the final "Game" entry (inside of SearchPaths) [Click here if you don't know how to follow instructions](http://pastebin.com/MbSEpeLG)

###Connecting to a source1 server###
 - We will use my personal server as an example
 - Launch NORMAL dota 2 (no workshop tools!)
 - Open your console and type the following:
 - `connect lod.ash47.net:27016`
 - Alternatively, simply visit `steam://connect/lod.ash47.net:27016` in your browser
 - If you do not see the standard `Please wait while we waste your time` screen, you have installed Legends of Dota incorrectly, ensure `dota 2 beta/dota/addons/lod/addoninfo.txt` exists. Ensure you did the gameinfo step. Ensure you restarted dota 2.

###List of public source1 servers###
 - Ash47 1st **lod.ash47.net:27015**
 - Ash47 2nd **lod.ash47.net:27016**
 - Ash47 3rd **lod.ash47.net:27017**
 - Ash47 4th **lod.ash47.net:27018**

###Starting a source1 server###
 - Do not contact me for additional help
 - If you get stuck, google it! Here is how: [Click this link](http://tinyurl.com/opvfh46)
 - Here is the file structure for your own server! Start by making a blank folder somewhere, possibly called `mySexyServer`
  - **server.bat** (You will create this yourself, the contents are specified below)
  - **srcds.exe** ([Download the SRCDS for your OS here](https://forums.alliedmods.net/showthread.php?p=2110203))
  - **bin/** (Simply copy your `Steam/steamapps/common/dota 2 beta/bin` folder in)
  - **dota/** (Simply copy your `Steam/steamapps/common/dota 2 beta/dota` folder in)
  - **dota/addons/d2fixups** ([Download from the first post here](https://forums.alliedmods.net/showthread.php?t=209965))
  - **dota/addons/lod** (Download the latest release from the releases section above)
  - **dota/addons/sourcemod** ([Download the latest snapshot in the 1.7 dev branch](http://www.sourcemod.net/snapshots.php))
  - **dota/addons/sourcemod/plugins/ffa.smx** (This can be found in sourcemod/plugins folder of the LegendsOfDota repo, you might want to delete / disable all the other plugins that ship with sourcemod, since they aren't needed)
  - **dota/addons/metamod** ([The latest snapshot in the 1.11 dev branch](https://www.sourcemm.net/snapshots))
  - **dota/maps/dota.bsp** (You need to grab the dota_fixed.bsp in the maps directory from this repo, rename it to dota.bsp and replace the existing one. The map is the same, only patched to work with custom games on source1. Note: You only need to do this on servers, NOT clients.)
 - The following goes into a batch file, place this match file into the same folder as srcds, call it `server.bat`

        @echo off
        cls
        echo Protecting srcds from crashes...
        echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
        title Legends of Dota watchdog
        :srcds
        echo (%time%) srcds started.
        start /wait srcds -console -game dota +maxplayers 24 +hostport 27016 -condebug -dev +dota_local_addon_enable 1 +dota_local_addon_game lod +dota_force_gamemode 15 +map dota
        echo (%time%) WARNING: srcds closed or crashed, restarting.
        goto srcds


 - Getting metamod to load
  - You will need to do the `dota/gameinfo.txt` step that is mentioned [here](https://wiki.alliedmods.net/Installing_metamod:source)
 - Mounting Legends of Dota
  - You will need to add "Game  |gameinfo_path|addons/lod" without quotes to the end of your `dota/gameinfo.txt` file, the end result is something like this


            "GameInfo"
            {
                game    "DOTA 2"
                gamelogo 1
                type multiplayer_only
                nomodels 1
                nohimodel 1
                nocrosshair 0
                GameData        "dota.fgd"
                SupportsDX8 0
                FileSystem
                {
                    SteamAppId              816     // This will mount all the GCFs we need (240=CS:S, 220=HL2).
                    ToolsAppId              211     // Tools will load this (ie: source SDK caches) to get things like materials\debug, materials\editor, etc.
                    //
                    // The code that loads this file automatically does a few things here:
                    //
                    // 1. For each "Game" search path, it adds a "GameBin" path, in <dir>\bin
                    // 2. For each "Game" search path, it adds another "Game" path in front of it with _<langage    at the end.
                    //    For example: c:\hl2\cstrike on a french machine would get a c:\hl2\cstrike_french path added to it.
                    // 3. For the first "Game" search path, it adds a search path called "MOD".
                    // 4. For the first "Game" search path, it adds a search path called "DEFAULT_WRITE_PATH".
                    //
                    //
                    // Search paths are relative to the base directory, which is where hl2.exe is found.
                    //
                    // |gameinfo_path| points at the directory where gameinfo.txt is.
                    // We always want to mount that directory relative to gameinfo.txt, so
                    // people can mount stuff in c:\mymod, and the main game resources are in
                    // someplace like c:\program files\valve\steam\steamapps\<username>\half-life 2.
                    //
                    SearchPaths
                    {
                        GameBin             |gameinfo_path|addons/metamod/bin
                        Game                |gameinfo_path|.
                        Game                platform
                        Game                |gameinfo_path|addons/lod
                    }
                }
            }


 - If you want to be put onto a team automatically, you will need the follow files created, depending on what you eant your server to do
 - dedicated.kv is required for all dedicated server functions, it will load the bans file and stop noobs from playing
 - Create cfg/dedicated.kv

        "dedicated" {
        }

 - Create `cfg/allocation.kv` if you want to be allocated into a team automatically

        "dedicated" {
        }

 - You will be put onto the team with the least players, or radiant if they have the same number of players
 - You can force your team by adding `R`, `D` or `S` to the start of your steam name, for Radiant, Dire and Spectator
 - Once allocated to a team, it can not be changed until the server is restarted
 - Create `cfg/addbots.kv` if you want bots to be added (assuming sourcemod is setup correctly)

        "dedicated" {
        }

 - You should see the following messages, depending on what you selected:
 - `Loaded LoD dedicated file!`
 - `Loaded LoD allocation code!`
 - `Loaded LoD bot allocation code`
 - If you're still having troubles, you can look [here](https://github.com/ash47/Frota#more-srcds-setup-help) for more tips.
 - You may be interested in [Legends of Dota Watch Dog](https://github.com/ash47/LoDWatchDog) -- This is a lightweight app that restarts SRCDS each time it crashes

###More SRCDS Setup Help###
 - To debug, try adding **-condebug** to the SRCDS launch parameters, this will log all the server output to server/dota/console.log, you can check for errors in there
 - Verify you have installed metamod and d2fixups correctly, you can do this by adding **+meta list** to your launch parameters, starting the server, then checking your dota/console.log. You should see these two lines:
  - Listing 1 plugin:
  - [01] Dota 2 Fixups (1.9.2) by Nicholas Hastings
 - If you don't see these two, then you have installed either metamod, or d2fixups incorrectly
 - Note: If you installed sourcemod, you might also see sourcemod in that list
 - If you see >> Unknown command "meta" << it means metamod is installed incorrectly, verify you added it to [gameinfo.txt](http://wiki.alliedmods.net/Installing_Metamod:Source#GameInfo)
 - You can verify sourcemod is installed correctly by typing the following into the console
  - sm plugins list
 - If you get >> Unknwon command "sm" << it means sourcemod is not installed correctly
 - You should see the FFA plugin listed if all is good
 - You can test FFA with the following command
  - sm_gmod
 - Again, it should say the command exists
 - To manually add bots
  - sm_gmode 1
  - dota_bot_populate

###Starting a server - FAQ###
 - **I need help**
  - Do NOT contact me
  - Drop your questions [here](http://steamcommunity.com/workshop/filedetails/discussion/296590332/620703493310739146/)
 - **The server doesn't work**
  - Check the d2fixups topic, there is a small chance that when you have tried to setup the server, everything is broken, because of a recent update, be patent, and don't spam the devs, they will fix things when they have time
 - **Bots don't spawn**
  - There is plenty of help above
 - **My game crashes when I connect**
  - Ensure you installed the patched dota.bsp into your server, it is REQUIRED now

###Server Commands###
 - `lod_sethost` While in the waiting / loading period, this can be used to set the ID of the hoster.
 - `lod_ids` Lists playerIDs matches with steamIDs and player names.
 - `lod_survival` Loads the survival gamemode (It will autostart when the match begins, it will also disable bots).
 - `lod_nobots` Stops bots from spawning (it wont remove bots, if they have already spawned).
 - `lod_cycle` Enable cycling builds.
 - `lod_applybuild(targetID, sourceID)` Makes the person with the targetID get the build from the person with sourceID.
 - `lod_printbuilds` Prints all builds.
 - `lod_editskill(playerID, skillSlot, skillName)` Edits the given skill for the given player
 - `lod_allocate(steamID64, teamID)` Sets the allocation to be used with the given player
 - `lod_show_allocate` Shows all current allocations

###Other Commands###
 - These require sourcemod plugins, and are some what experimental!
 - `sm_gmode(gamemodeID)` Sets the gamemode ID. (this is used to load all pick after the game starts, to allow bots)
 - `clear_playerid(playerID)` Clears a player from the given slot
 - `read_playerid(playerID)` Prints out the 8 bits in the slot for the given playerID (usully SteamID followed by 1)
 - `set_playerid(playerID, steamID32)` Puts the player with the given steamID into the given slot

###Compiling Legends of Dota###
 - This gamemode has a huge chunk generated by scripts
 - This gamemode has files that are relevant to different versions of the mod, and hence, should not be distrubuted with every version
 - You will need node.js installed
 - Copy `script_generator/settings_example.json` to `script_generator/settings.json` and fill in the `dotaDir` location, this is the path to your `dota 2 beta`, ending in a slash (/)
 - You will need to stage the directories, this creates virtual links to all the files, one for each build we offer, to do this, simply run `stage.bat` (this might need admin permissions)
 - `compile.bat` is used to compile script changes in the script_generator folder, you do not need to restage the changes

###Can I translate this into my language?###
 - Yes!
 - Open `script_generator/CUSTOM/addon_<your langage>.txt`
 - You can reference `addon_english.txt`
 - You might need to save it as unicode, if non standard characters are used
 - Any strings you don't fill in, will be auto copied in from the english file anyways when the gamemode is compiled
 - Note to Ash47: You need to add new languages to the `stage.bat` file!
