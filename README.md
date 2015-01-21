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
 - You'll need to setup a source1 server, google it! Here is how: [Click this link](http://tinyurl.com/opvfh46)
 - You will need SRCDS from [here](https://forums.alliedmods.net/showthread.php?p=2110203)
 - You need the following installed
  - addons/d2fixups ([Download from the first post here](https://forums.alliedmods.net/showthread.php?t=209965))
  - addons/lod (You can get this by downloading the ZIP on the right side of this repo)
  - addons/sourcemod ([Download the latest snapshot in the 1.7 dev branch](http://www.sourcemod.net/snapshots.php))
  - addons/sourcemod/plugins/ffa.smx (This can be found in sourcemod/plugins folder of the LegendsOfDota repo, you might want to delete / disable all the other plugins that ship with sourcemod, since they aren't needed)
  - addons/metamod ([The latest snapshot in the 1.11 dev branch](https://www.sourcemm.net/snapshots))
 - The following goes into a batch file, place this match file into the same folder as srcds

        @echo off
        cls
        echo Protecting srcds from crashes...
        echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
        title Legends of Dota watchdog
        :srcds
        echo (%time%) srcds started.
        start /wait srcds -console -game dota +maxplayers 24 +hostport 27016 -condebug -dev +exec custom +map dota_fixed
        echo (%time%) WARNING: srcds closed or crashed, restarting.
        goto srcds

 - Getting metamod to load
  - You will need to do the gameinfo.txt step that is mentioned [here](https://wiki.alliedmods.net/Installing_metamod:source)
 - Mounting Legends of Dota
  - You will need to add "Game  |gameinfo_path|addons/lod" without quotes to the end of your gameinfo.txt file, the end result is something like this

> "GameInfo"
> {
>     game    "DOTA 2"
>     gamelogo 1
>     type multiplayer_only
>     nomodels 1
>     nohimodel 1
>     nocrosshair 0
>     GameData        "dota.fgd"
>     SupportsDX8 0
>     FileSystem
>     {
>         SteamAppId              816     // This will mount all the GCFs we need (240=CS:S, 220=HL2).
>         ToolsAppId              211     // Tools will load this (ie: source SDK caches) to get things like materials\debug, materials\editor, etc.
>         //
>         // The code that loads this file automatically does a few things here:
>         //
>         // 1. For each "Game" search path, it adds a "GameBin" path, in <dir>\bin
>         // 2. For each "Game" search path, it adds another "Game" path in front of it with _<langage> at the end.
>         //    For example: c:\hl2\cstrike on a french machine would get a c:\hl2\cstrike_french path added to it.
>         // 3. For the first "Game" search path, it adds a search path called "MOD".
>         // 4. For the first "Game" search path, it adds a search path called "DEFAULT_WRITE_PATH".
>         //
>         //
>         // Search paths are relative to the base directory, which is where hl2.exe is found.
>         //
>         // |gameinfo_path| points at the directory where gameinfo.txt is.
>         // We always want to mount that directory relative to gameinfo.txt, so
>         // people can mount stuff in c:\mymod, and the main game resources are in
>         // someplace like c:\program files\valve\steam\steamapps\<username>\half-life 2.
>         //
>         SearchPaths
>         {
>             GameBin             |gameinfo_path|addons/metamod/bin
>             Game                            |gameinfo_path|.
>             Game                            platform
>             Game                |gameinfo_path|addons/lod
>         }
>     }
> }


 - Create cfg/custom.cfg

        dota_local_addon_enable 1
        dota_local_addon_game lod
        dota_force_gamemode 15
        update_addon_paths
        dota_wait_for_players_to_load_count 1
        dota_wait_for_players_to_load 1
        dota_wait_for_players_to_load_timeout 30

 - Create cfg/dedicated.kv

        "dedicated" {
        }

 - Create `cfg/allocation.kv` if you want to be allocated into a team automatically

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
