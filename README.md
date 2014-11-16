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

Custom.cfg

    dota_local_addon_enable 1
    dota_local_addon_game 296590332
    dota_force_gamemode 15
    update_addon_paths
    dota_wait_for_players_to_load_count 1
    dota_wait_for_players_to_load 1
    dota_wait_for_players_to_load_timeout 30
