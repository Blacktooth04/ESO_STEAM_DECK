#!/bin/bash
# modified from https://github.com/kevinlekiller/eso-linux-launcher

PATH_TO_ADDONS="/home/deck/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online/live/AddOns/"
BASE_DIRECTORY=$PWD

TMPDIR="$BASE_DIRECTORY/tmp"
mkdir -p "$TMPDIR"
rm -rf "$TMPDIR/*"

while read line
do
	# ignore lines that start with # or are empty
	if [[ $line == \#* ]] || [[ $line == "" ]]
	then
		continue
	fi
	
	AURI=$(echo "$line" | cut -d\  -f1) # URL of addon
	ANAME=$(echo "$line" | cut -d\  -f2) # Name of addon 
	AVERS=$(echo "$line" | cut -d\  -f3) # Version Currently Installed
	
	# Get the actual name of addon
	if [[ $ANAME == $AURI ]]; then
		ANAME=$(echo "$line" | grep -Poi "info\d+-[^.]+" | cut -d- -f2)
	fi
	echo "Updating addon: $ANAME"
	
	# Get the actual version of addon
	if [[ $AVERS == $AURI ]]; then
		AVERS=""
		echo "Addon not currently installed."
	else
		echo "Currently installed version: $AVERS"
	fi

	# Get the latest version of addon
	RVERS=$(curl -s $AURI 2> /dev/null | grep -Poi "<div\s+id=\"version\">Version:\s+[^<]+" | cut -d\  -f3)
	echo "Latest version in ESOUI: $RVERS"
	# If empty, print error
	if [[ $RVERS == "" ]];  then
		echo "Error finding version of addon $ANAME on esoui.com"
		sleep 1
		continue
	fi
	
	# Compare the current and latest version
	if [[ $RVERS == $AVERS ]]; then
		echo -e "Addon $ANAME is up to date. Ignoring.\n"
		continue
	fi

	# Get the addon
	DURI=$(curl -s $(echo "$AURI" | sed "s#/info#/download#" | sed "s#.html##") 2> /dev/null | grep -m1 -Poi "https://cdn.esoui.com/downloads/file[^\"]*")
	wget -q -O "$TMPDIR/addon.zip" "$DURI"
	unzip -o -qq -d "$TMPDIR" "$TMPDIR/addon.zip"
	rm "$TMPDIR/addon.zip"
	ADIRS=""
	# Remove the currently installed version and replace with new one.
	for dir in $(ls -d "$TMPDIR/"*); do
		dir=$(basename "$dir")
		rm -rf "$PATH_TO_ADDONS/$dir"
		mv -f "$TMPDIR/$dir" "$PATH_TO_ADDONS/"
		if [[ $ADIRS == "" ]]; then
			ADIRS="$dir"
		else
			ADIRS="$ADIRS|$dir"
		fi
	done
	
	# del url name ver dirs from 
	sed -i "s#$line#$AURI $ANAME $RVERS $ADIRS#" "$BASE_DIRECTORY/addons.txt"
	echo -e "Updated addon $ANAME\n"
	sleep 1
done < "$BASE_DIRECTORY/addons.txt"

rm -d "$TMPDIR"
