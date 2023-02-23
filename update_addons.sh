#!/bin/bash
# modified from https://github.com/kevinlekiller/eso-linux-launcher

PATH_TO_ADDONS="/home/deck/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online/live/AddOns/"
CWD=$PWD

TMPDIR="$CWD/tmp"

mkdir -p "$TMPDIR"
while read line; do

done < "$CWD/addons.txt"

rm -d "$TMPDIR"
