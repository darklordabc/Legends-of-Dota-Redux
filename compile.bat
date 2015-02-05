rmdir /S /Q "lod_bin"
mkdir "lod_bin"
mkdir "lod_bin/lod"
copy "manifest.kv" "lod_bin/manifest.kv"
echo d | xcopy /S "lod/resource" "lod_bin/lod/resource"
echo d | xcopy /S "lod/scripts" "lod_bin/lod/scripts"
echo d | xcopy /S "lod/particles" "lod_bin/lod/particles"

cd lod
copy "addoninfo.txt" "../lod_bin/lod/addoninfo.txt"
cd ../lod_bin/lod/resource/flash3
del gfxfontlib.swf

cd ../../../..

rmdir /S /Q "lod_s2_bin"
mkdir "lod_s2_bin"
mkdir "lod_s2_bin/maps"
echo d | xcopy /S "lod/resource" "lod_s2_bin/resource"
echo d | xcopy /S "lod/scripts" "lod_s2_bin/scripts"

cd lod
copy "addoninfo.txt" "../lod_s2_bin/addoninfo.txt"
cd ../maps
copy "dota_pvp.vpk" "../lod_s2_bin/maps/dota_pvp.vpk"

cd ../lod_s2_bin/resource/flash3
del gfxfontlib.swf

cd ../../..

cd "script_generator/BIN"

copy "npc_abilities_custom.txt" "../../lod_bin/lod/scripts/npc/npc_abilities_custom.txt"
copy "npc_abilities_custom.txt" "../../lod_s2_bin/scripts/npc/npc_abilities_custom.txt"

copy "npc_heroes_custom.txt" "../../lod_bin/lod/scripts/npc/npc_heroes_custom.txt"
copy "npc_heroes_custom.txt" "../../lod_s2_bin/scripts/npc/npc_heroes_custom.txt"

copy "addon_*" "../../lod_bin/lod/resource/"
copy "addon_*" "../../lod_s2_bin/resource/"

pause