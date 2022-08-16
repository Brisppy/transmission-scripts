#!/bin/bash
#
# Based on a script by github.com/pawelszydlo
#
# This script:
# Generates a list of all torrents in the transmission instance
# For each torrent:
#   Gets the PRIVATE status of the torrent
#   Gets the current UP LIMIT of the torrent
#   IF the torrent is public, and UP LIMIT not set:
#       Set UP LIMIT to provided value

echo $(date)
echo ${0##*/}

# Upload speed to set (kbps)
UPLIMIT=50

# Do not modify these.
CURDIR="$(dirname "$(readlink -f "$0")")"
source "$CURDIR/auth"
TRANSCMD="transmission-remote $SERVER"
if [ "$SSL" == "1" ]; then TRANSCMD+=" --ssl"; fi
if [ "$AUTH" != "0" ]; then TRANSCMD+=" --auth $AUTH"; fi

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
    CURUPLIMIT=$(echo "$INFO" | sed -n 's/.*Upload Limit: \(.*\)/\1/p')

    # Checks if the torrent is public and upload limit is unlimited.
    if [[ "$PUBLIC" == "Yes" ]] && [[ "$CURUPLIMIT" == "Unlimited" ]]; then
        echo "                : Match found, seting upload limit to $UPLIMIT kb/s..."
        $TRANSCMD --torrent "$TORRENT_ID" --uplimit $UPLIMIT > /dev/null
    fi
done
