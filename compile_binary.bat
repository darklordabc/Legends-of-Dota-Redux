rmdir /S /Q "lod_bin"
mkdir "lod_bin"
mkdir "lod_bin/lod"
copy "manifest.kv" "lod_bin/manifest.kv"
echo d | xcopy /S "lod/resource" "lod_bin/lod/resource"
echo d | xcopy /S "lod/scripts" "lod_bin/lod/scripts"
echo d | xcopy /S "lod/particles" "lod_bin/lod/particles"

cd lod
copy "addoninfo.txt" "../lod_bin/lod/addoninfo.txt"
<<<<<<< HEAD
cd ../lod_bin/lod/resource/flash3
del gfxfontlib.swf
=======
cd ..

cd lod_bin/lod/resource/flash3
DEL /F /S /Q /A "gfxfontlib.swf"
>>>>>>> origin/master
