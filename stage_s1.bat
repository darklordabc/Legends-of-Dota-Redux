:: -- Compile the scripts --
call compile_s1.bat

:: -- Stage source1 binaries --

:: Cleanup the old copy of it
rmdir /S /Q "lod_s1_bin"

:: Create directory structure
mkdir "lod_s1_bin\lod\resource"
mkdir "lod_s1_bin\lod\scripts\npc"
mkdir "lod_s1_bin\sourcemod\plugins"

:: Hardl link sourcemod plugins
mklink /H "lod_s1_bin\sourcemod\plugins\clear_playerid.smx" "sourcemod\plugins\clear_playerid.smx"
mklink /H "lod_s1_bin\sourcemod\plugins\ffa.smx" "sourcemod\plugins\ffa.smx"

:: Hard link info files
mklink /H "lod_s1_bin\manifest.kv" "manifest.kv"
mklink /H "lod_s1_bin\dedicated.kv" "dedicated.kv"
mklink /H "lod_s1_bin\lod\addoninfo.txt" "lod_game\addoninfo.txt"

:: Hard link top level scripts
mklink /H "lod_s1_bin\lod\scripts\custom_events.txt" "lod_game\scripts\custom_events.txt"
mklink /H "lod_s1_bin\lod\scripts\stat_collection.kv" "lod_game\scripts\stat_collection.kv"

:: Hard link NPC scripts
mklink /H "lod_s1_bin\lod\scripts\npc\activelist.txt" "lod_game\scripts\npc\activelist_s1.txt"
mklink /H "lod_s1_bin\lod\scripts\npc\herolist.txt" "lod_game\scripts\npc\herolist_s1.txt"
mklink /H "lod_s1_bin\lod\scripts\npc\npc_units_custom.txt" "script_generator\BIN\s1\npc_units_custom.txt"
mklink /H "lod_s1_bin\lod\scripts\npc\npc_items_custom.txt" "script_generator\BIN\s1\npc_items_custom.txt"

:: Link script folders
mklink /D /J "lod_s1_bin\lod\scripts\vscripts" "lod_game\scripts\vscripts\"
mklink /D /J "lod_s1_bin\lod\scripts\kv" "lod_game\scripts\kv"
mklink /D /J "lod_s1_bin\lod\scripts\abilities" "lod_game\scripts\abilities"
mklink /D /J "lod_s1_bin\lod\scripts\game_sounds" "lod_game\scripts\game_sounds"

:: Link particle folder
mklink /D /J "lod_s1_bin\lod\particles" "lod_game\particles_s1"

:: Link resource folders
mklink /D /J "lod_s1_bin\lod\resource\flash3" "lod_game\resource\flash3"
mklink /D /J "lod_s1_bin\lod\resource\overviews" "lod_game\resource\overviews"

:: Hard link generated scripts
mklink /H "lod_s1_bin\lod\resource\addon_english.txt" "script_generator\BIN\s1\addon_english.txt"
mklink /H "lod_s1_bin\lod\resource\addon_russian.txt" "script_generator\BIN\s1\addon_russian.txt"
mklink /H "lod_s1_bin\lod\scripts\npc\npc_abilities_custom.txt" "script_generator\BIN\s1\npc_abilities_custom.txt"
mklink /H "lod_s1_bin\lod\scripts\npc\npc_heroes_custom.txt" "script_generator\BIN\s1\npc_heroes_custom.txt"
