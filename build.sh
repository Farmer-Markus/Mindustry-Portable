#!/bin/bash

scriptdir=$(cd $(dirname $0);pwd)

if [ ! -e $scriptdir/dwarfs-universal-0.7.3-Linux-x86_64 ]
   then

       wget https://github.com/mhx/dwarfs/releases/download/v0.7.3/dwarfs-universal-0.7.3-Linux-x86_64 && chmod a+x dwarfs-universal-0.7.3-Linux-x86_64
fi
if [ ! -e $scriptdir/dwarfs/Mindustry/Mindustry.jar ]
   then

       wget -P dwarfs/Mindustry/ https://github.com/Anuken/Mindustry/releases/latest/download/Mindustry.jar
fi
chmod a+x dwarfs/ATLauncher/Mindustry.jar
./dwarfs-universal-0.7.3-Linux-x86_64 --tool=mkdwarfs -i dwarfs -o dwarfs.dwarfs
cat script.sh dwarfs-universal-0.7.3-Linux-x86_64 1 dwarfs.dwarfs > Mindustry-Portable.sh && chmod a+x Mindustry-Portable.sh
