Legends of Dota
=====

###About###
 - Please stand by while this repo is fixed ;)
 - Pick your skills to build an overpowered masterpiece!
 - Test out different combinations!
 - Create unique and creative heros to dominate your opponent.

###Current Features###
 - Picking Interface
 - Basic Voting Interface
 - Basic Banning Interface (You can ban skills and a hero)
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

###Starting a source1 server###
 - Do not contact me for additional help
 - If you get stuck, google it! Here is how: [Click this link](http://tinyurl.com/opvfh46)
 - Here is the file structure for your own server! Start by making a blank folder somewhere, possibly called `mySexyServer`
  - **server.bat** (You will create this yourself, the contents are specified below)
  - **srcds.exe** ([Download the SRCDS for your OS here](https://forums.alliedmods.net/showthread.php?p=2110203))
  - **bin/** (Simply copy your `Steam/steamapps/common/dota 2 beta/bin` folder in)
  - **dota/** (Simply copy your `Steam/steamapps/common/dota 2 beta/dota` folder in)
  - **dota/addons/d2fixups** ([Download from the first post here](https://forums.alliedmods.net/showthread.php?t=209965))
  - **dota/addons/lod** (You can get this by downloading the ZIP on the right side of this repo)
  - **dota/addons/sourcemod** ([Download the latest snapshot in the 1.7 dev branch](http://www.sourcemod.net/snapshots.php))
  - **dota/addons/sourcemod/plugins/ffa.smx** (This can be found in sourcemod/plugins folder of the LegendsOfDota repo, you might want to delete / disable all the other plugins that ship with sourcemod, since they aren't needed)
  - **dota/addons/metamod** ([The latest snapshot in the 1.11 dev branch](https://www.sourcemm.net/snapshots))
 - The following goes into a batch file, place this match file into the same folder as srcds, call it `server.bat`

        @echo off
        cls
        echo Protecting srcds from crashes...
        echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
        title Legends of Dota watchdog
        :srcds
        echo (%time%) srcds started.
        start /wait srcds -console -game dota +maxplayers 24 +hostport 27016 -condebug -dev +dota_local_addon_enable 1 +dota_local_addon_game lod +dota_force_gamemode 15 +map dota_fixed
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
 - You will be put onto the team with the least players, or radiant if they have the same number of players
 - You can force your team by adding `R`, `D` or `S` to your name, for Radiant, Dire and Spectator

        "dedicated" {
        }

 - Create `cfg/addbots.kv` if you want bots to be added (assuming sourcemod is setup correctly)

        "dedicated" {
        }

 - You should see the following messages, depending on what you selected:
 - `Loaded LoD dedicated file!`
 - `Loaded LoD allocation code!`
 - `Loaded LoD bot allocation code`
 - If you're still having troubles, you can look [here](https://github.com/ash47/Frota#more-srcds-setup-help) for more tips.

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
