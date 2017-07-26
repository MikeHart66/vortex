#!/bin/sh
cd `dirname $0`

echo "building meshtool..."
g++ -std=c++03 -stdlib=libstdc++ -arch i386 -arch x86_64 -O2 -o meshtool.data/meshtool.bin src_meshtool/meshtool.cc src_meshtool/loadmesh.cc src_meshtool/genxml.cc -Lsrc_meshtool/irrlicht -lIrrlicht.mac -framework AppKit -framework IOKit -framework OpenGL

echo "building fonttool..."
g++ -std=c++03 -stdlib=libstdc++ -O2 -m32 -o fonttool src.fonttool/stb_image_write.c src.fonttool/stb_truetype.c src.fonttool/main.cpp

echo "done."
