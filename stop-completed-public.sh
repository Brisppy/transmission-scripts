#!/bin/bash
#
# Based on a script by github.com/pawelszydlo
#
# This script:
# Generates a list of all torrents in the transmission instance
# For each torrent:
#   Gets the PRIVATE status of the torrent
#   Gets the PROGRESS of the torrent
#   Gets the current STATE of the torrent
#   IF the torrent is public, progress is 100% and STATE is seeding:
#       Stop the torrent.

echo $(date)
echo ${0##*/}

# Do not modify these.
CURDIR="$(dirname "$(readlink -f "$0")")"
source "$CURDIR/auth"
TRANSCMD="transmission-remote $SERVER"
if [ "$SSL" == "1" ]; then TRANSCMD+=" --ssl"; fi
if [ "$AUTH" != "0" ]; then TRANSCMD+=" --auth $AUTH"; fi
# Which torrent states should be removed at 100% progress.
DONE_STATES=("Seeding" "Idle")

echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# Use transmission-remote to get the torrent list from transmission-remote.
TORRENT_LIST=$($TRANSCMD --list | sed -e '1d' -e '$d' | awk '{print $1}' | sed -e 's/[^0-9]*//g')

# Iterate through the torrents.
for TORRENT_ID in $TORRENT_LIST
do
    INFO=$($TRANSCMD --torrent "$TORRENT_ID" --info)
    echo -e "Processing #$TORRENT_ID	: \"$(echo "$INFO" | sed -n 's/.*Name: \(.*\)/\1/p')\"..."
    # To see the full torrent info, uncomment the following line.
    # echo "$INFO"
    PUBLIC=$(echo "$INFO" | sed -n 's/.*Public torrent: \(.*\)/\1/p')
    PROGRESS=$(echo "$INFO" | sed -n 's/.*Percent Done: \(.*\)%.*/\1/p')
    STATE=$(echo "$INFO" | sed -n 's/.*State: \(.*\)/\1/p')

    # Checks if the torrent is public, completed and either Seeding or Idle.
    if [[ "$PUBLIC" == "Yes" ]] && [[ "$PROGRESS" == "100" ]] && [[ "${DONE_STATES[@]}" =~ "$STATE" ]]; then
        echo "                : Match found, stopping torrent..."
        $TRANSCMD --torrent "$TORRENT_ID" --stop > /dev/null
    fi
done
