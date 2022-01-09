#!/usr/bin/bash

LATESTPATH="https://github.com/ankitects/anki/releases/latest"
DOWNLOADPATH="https://github.com/ankitects/anki/releases/download/"

METHOD=0
# 0: update
# 1: forced update
# 2: install
# 3: forced-install
ANKI=$(which anki)

if [ -z "$1" ]; then
	if [ -f "$ANKI" ]; then
		METHOD=0
	else
		METHOD=2
	fi
elif [ "$1" == "update" ]; then
	METHOD=1
elif [ "$1" == "install" ]; then
	METHOD=3
else
	echo "Unknown option."
	exit 1
fi

install_anki () {
	INSTALLNAME="anki-${REMOTEVERSION}-linux"
	cd "/tmp"
	wget -q -O "${INSTALLNAME}.tar.bz2" --show-progress "${DOWNLOADPATH}${REMOTEVERSION}/${INSTALLNAME}.tar.bz2"
	echo -n "Decompressing... "
	tar xjf "${INSTALLNAME}.tar.bz2"
	echo "Done."
	cd "$INSTALLNAME"
	if [ "$(whoami)" == "root" ]; then
		./install.sh
	else
		sudo ./install.sh
	fi
}

REMOTEURL=$(wget --spider "$LATESTPATH" 2>&1 | grep "Location:" | cut -d " " -f 2)
REMOTEVERSION=$(echo "$REMOTEURL" | rev | cut -d "/" -f 1 | rev)
if [ $METHOD -lt 2 ]; then
	LOCALVERSION=$("$ANKI" -v | cut -d " " -f 2)
	RV1=$(echo "$REMOTEVERSION" | cut -d "." -f 1)
	RV2=$(echo "$REMOTEVERSION" | cut -d "." -f 2)
	RV3=$(echo "$REMOTEVERSION" | cut -d "." -f 3)
	LV1=$(echo "$LOCALVERSION" | cut -d "." -f 1)
	LV2=$(echo "$LOCALVERSION" | cut -d "." -f 2)
	LV3=$(echo "$LOCALVERSION" | cut -d "." -f 3)
	echo "Installed Anki Version: $LOCALVERSION"
	echo "Latest Anki Version: $REMOTEVERSION"
	if [ $RV1 -gt $LV1 ] || [[ $RV1 -ge $LV1 && $RV2 -gt $LV2 ]] || [[ $RV1 -ge $LV1 && $RV2 -ge $LV2 && $RV3 -gt $LV3 ]]; then
		if [ $METHOD == "0" ]; then
			read -p "Do you want to continue? <y>: " ASK
			if [ $ASK != "y" ]; then
				echo "Aborted."
				exit 0
			fi
		fi
		install_anki
	fi
else
	echo "Latest Anki Version: $REMOTEVERSION"
	if [ $METHOD == "2" ]; then
		read -p "Do you want to continue? <y>: " ASK
		if [ $ASK != "y" ]; then
			echo "Aborted."
			exit 0
		fi
	fi
	install_anki
fi

