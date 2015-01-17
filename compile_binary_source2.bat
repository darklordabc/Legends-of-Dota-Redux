rmdir /S /Q "lod_s2_bin"
mkdir "lod_s2_bin"
mkdir "lod_s2_bin/maps"
echo d | xcopy /S "lod/resource" "lod_s2_bin/resource"
echo d | xcopy /S "lod/scripts" "lod_s2_bin/scripts"

cd lod
copy "addoninfo.txt" "../lod_s2_bin/addoninfo.txt"
cd maps
copy "dota_pvp.vpk" "../../lod_s2_bin/maps/dota_pvp.vpk"

cd ../../lod_s2_bin/resource/flash3
del gfxfontlib.swf
