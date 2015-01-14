rmdir /S /Q "lod_bin"
mkdir "lod_bin"
mkdir "lod_bin/lod"
copy "manifest.kv" "lod_bin/manifest.kv"
copy "lod/addoninfo.txt" "lod_bin/lod/addoninfo.txt"
echo d | xcopy /S "lod/resource" "lod_bin/lod/resource"
echo d | xcopy /S "lod/scripts" "lod_bin/lod/scripts"
echo d | xcopy /S "lod/particles" "lod_bin/lod/particles"

cd lod_bin
cd lod
cd resource
cd flash3
DEL /F /S /Q /A "gfxfontlib.swf"
