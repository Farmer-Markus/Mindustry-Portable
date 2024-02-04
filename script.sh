#!/bin/bash

#Sets variables and functions#
##############################
scriptdir=$(cd $(dirname $0);pwd)
scriptname=$(basename "$0")
offset=auto
mountpoint="/tmp"
if [ -e "/dev/shm" ]; then mountpoint="/dev/shm"; fi
workdir=$scriptdir
workdiroption="--working-dir"
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' "$scriptdir/$scriptname"`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' "$scriptdir/$scriptname"`

sh_mount () {
  Tools=$mountpoint/Mindustry-Portable/mnt/Tools
  if [ ! -e "$mountpoint/Mindustry-Portable" ]
     then

         mkdir -p "$mountpoint/Mindustry-Portable/mount-tools"
         mkdir -p "$mountpoint/Mindustry-Portable/mnt" 
         awk "NR==$Begin_dwarfs_universal, NR==$End_dwarfs_universal" "$scriptdir/$scriptname" > "$mountpoint/Mindustry-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" && chmod a+x "$mountpoint/Mindustry-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64"
         "$mountpoint/Mindustry-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" --tool=dwarfs "$scriptdir/$scriptname" "$mountpoint/Mindustry-Portable/mnt" -o offset=$offset
fi
}

sh_unmount () {
  umount "$mountpoint/Mindustry-Portable/mnt"
  rm -r "$mountpoint/Mindustry-Portable"
}

sh_help () {
  echo 'sh Options                           Description'
  echo '----------                           -----------'
  echo '--use-internal-jar                   Uses internal Mindustry.jar'
  echo '                                     (you need to recompile sh for Updates)'
  echo ''
  echo '--mount                              Mounts the dwarfs filesystem in '$mountpoint''
  echo '                                     (can be used with <--mountpoint>)'
  echo ''
  echo '--mountpoint=<string>                Defines the mount location for the dwarfs'
  echo '                                     image.(Default mountpoint: </dev/shm or /tmp>)'
  echo ''
  echo '--install                            Moves the image into your .local/share'
  echo '                                     folder and creates an desktop entry'
  echo ''
  echo '--ignore-updates		     Will not update Mindustry if an new'
  echo '				     update is available'
  echo ''
  echo '-------------------------------------------------------------------------------'
  exit
}

sh_if_mounted () {
  if [ ! -e "$mountpoint/Mindustry-Portable" ]
     then

         sh_mount
         echo -e "\033[1;32mImage mounted in "$mountpoint"\033[0;38m"
         exit

     else

         umount "$mountpoint/Mindustry-Portable/mnt"
         rm -r "$mountpoint/Mindustry-Portable"
         echo -e "\033[1;31mImage unmounted\033[0;38m"
         exit
fi
}

sh_internal_jar () {
  echo -e "\033[1;32mUsing internal jar\033[0;38m"
  export HOME="$scriptdir"
  "$mountpoint/Mindustry-Portable/mnt/java-runtime-16/bin/java" -Duser.home=$scriptdir -Dhttps.protocols=TLSv1.2,TLSv1.1,TLSv1 -jar "$mountpoint/Mindustry-Portable/mnt/Mindustry/Mindustry.jar"
}

sh_external_jar () {

  if [ ! -e "$workdir/Mindustry.jar" ]
     then

         cp "$mountpoint/Mindustry-Portable/mnt/Mindustry/Mindustry.jar" "$workdir"
fi 

  if [ "$noupdates" == "" ]
     then

  	 if ( ping -c 1 gitgub.com | grep -q "1" );
      	    then

	  	echo -e "\033[1;31mChecking for updates...\033[0;38m"
	  	$Tools/unzip -p $workdir/Mindustry.jar version.properties > $mountpoint/Mindustry-Portable/version.properties
     	  	Version=$($Tools/curl --silent "https://api.github.com/repos/Anuken/Mindustry/releases/latest" | grep -Po "(?<=\"tag_name\": \").*(?=\")" | sed s/v//g)
     	  	if ( ! grep "$Version" "$mountpoint/Mindustry-Portable/version.properties" ) # > /dev/null )
             	   then

		       echo -e "\033[1;32mVersion $Version available on https://github.com/Anuken/Mindustry/releases/latest/\033[0;38m" 
		       echo -e "\033[1;31mInstalling updates...\033[0;38m" 
		       rm "$workdir/Mindustry.jar"
		       wget -P "$workdir" "https://github.com/Anuken/Mindustry/releases/latest/download/Mindustry.jar"
		       echo -e "\033[1;32mUpdates installed.\033[0;38m"
fi
fi
fi
  export HOME="$scriptdir"
  "$mountpoint/Mindustry-Portable/mnt/java-runtime-16/bin/java" -Duser.home=$scriptdir -Dhttps.protocols=TLSv1.2,TLSv1.1,TLSv1 -jar "$workdir/Mindustry.jar"
}

sh_install () {
  if [ -e ~/.local/share/Mindustry-Portable ]
     then

         echo -e "\033[1;31mFolder Mindustry-Portable already exists in ~/.local/share\033[0;38m"
         if [ ! -e ~/.local/share/applications/mindustry-portable.desktop ]; then sh_create_entry && echo -e "\033[1;32mFixed missing desktop entry\033[0;38m"; fi
         echo -e "\033[1;31mCan't install in ~/.local/share\033[0;38m"
         echo -e "\033[1;31mAlready installed\033[0;38m"
         echo -e "\033[1;31mWould you like to uninstall? All data will be removed![Y/n]\033[0;38m"
         read input
         case $input in
             y|yes)
             sh_uninstall
             ;;
             n|no)
             echo -e "\033[1;31mAborting\033[0;38m"
             ;;
             *)
             echo -e "\033[1;31mAborting\033[0;38m"
             ;;
         esac
         exit

     else

         echo -e "\033[1;32mInstalling Mindustry in ~/.local/share...\033[0;38m"
         sh_mount
         mkdir -p ~/.local/share/Mindustry-Portable
         cp "$scriptdir/$scriptname" ~/.local/share/Mindustry-Portable
         cp "$mountpoint/Mindustry-Portable/mnt/install/Mindustry.png" ~/.local/share/Mindustry-Portable/
         if [ -e ~/.local/share/applications/Mindustry-portable.desktop ]; then rm ~/.local/share/applications/Mindustry-portable.desktop; fi
         echo -e "\033[1;32mCreating desktop entry...\033[0;38m"
         sh_create_entry
         echo -e "\033[1;32mDone\033[0;38m"
         sh_unmount
         echo -e "\033[1;32mFinished installing Mindustry in ~/.local/share.\033[0;38m"
fi
}

sh_create_entry () {
  echo '[Desktop Entry]'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Name=Mindustry'									>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Exec='$HOME'/.local/share/Mindustry-Portable/Mindustry-Portable.sh'		>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Type=Application'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Keywords=game;multiplayer;'							>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Categories=Games;'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Comment=An open-ended factory management game with RTS and tower defense elements'	>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'StartupNotify=true'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Terminal=false'									>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Icon='$HOME'/.local/share/Mindustry-Portable/Mindustry.png'			>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Actions=noupdates;'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo ''										>> ~/.local/share/applications/mindustry-portable.desktop
  echo '[Desktop Action noupdates]'							>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Name=Ignore updates'								>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Name[de]=Updates ignorieren'							>> ~/.local/share/applications/mindustry-portable.desktop
  echo 'Exec="'$HOME'/.local/share/Mindustry-Portable/Mindustry-Portable.sh --ignore-updates"'	>> ~/.local/share/applications/mindustry-portable.desktop
}

sh_uninstall () {
  echo -e "\033[1;32mUninstalling Mindustry in ~/.local/share...\033[0;38m"
  echo -e "\033[1;31mAll data will be removed in\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m3		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m2		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m1		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  
  echo -e "\033[1;32mRemoving data...\033[0;38m"
  rm -rf ~/.local/share/Mindustry-Portable
  echo -e "\033[1;32mRemoving desktop entry...\033[0;38m"
  rm ~/.local/share/applications/mindustry-portable.desktop
  echo -e "\033[1;32mFully uninstalled Mindustry in ~/.local/share\033[0;38m"
}
#Scriptstart#
#############
for i in "$@"
do
case $i in
    -?|--h|--help)
    sh_help
    ;;
    --mount)
    mount=1
    ;;
    --use-internal-jar)
    internaljar=1
    ;;
    --mountpoint=*)
    mountpoint="${i#*=}"
    ;;
    --install)
    install=1
    ;;
    --ignore-updates)
    noupdates=1
    ;;
    *)
    atargs="$atargs $i"
    ;;
esac
done

if [ "$install" == "1" ]; then sh_install && exit; fi
if [[ "$internaljar" == "1" && "$mount" = "1" ]]; then echo -e "\033[1;31mCan't use this options together!\033[0;38m"; fi
if [[ "$internaljar" == "1" && "$mount" = "" ]]; then sh_mount && sh_internal_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "" ]]; then sh_mount && sh_external_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "1" ]]; then sh_if_mounted; fi


exit
#__Begin_dwarfs_universal__
