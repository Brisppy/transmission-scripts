#!/bin/bash
#
# Based on a script by github.com/pawelszydlo
#
# This script:
# Generates a list of all torrents in the transmission instance
# For each torrent:
#   Gets the TRACKER of the torrent
#   Gets the LOCATION of the torrent
#   Gets the PROGRESS of the torrent
#   Gets the time since last activity of the torrent
#   IF the torrent is from the tracker, progress is 100%, location matches and days since activity is greater than MAXAGE:
#       Remove the torrent and data.

# ARGUMENTS:
# 1. Tracker's domain e.g tracker.opentrackr.org
# 2. Path to torrent folder
# 3. Maximum age of torrent in days

echo $(date)
echo ${0##*/}

# Tracker URL
TRACKERURL="$1"

# Full path to folder
PATH="$2"

# Maximum time since last activity
MAXAGE="$3"

# Do not modify these.
CURDIR="$(dirname "$(readlink -f "$0")")"
source "$CURDIR/auth"
TRANSCMD="transmission-remote $SERVER"
if [ "$SSL" == "1" ]; then TRANSCMD+=" --ssl"; fi
if [ "$AUTH" != "0" ]; then TRANSCMD+=" --auth $AUTH"; fi
# Covert maxage to seconds
let MAXAGE="$MAXAGE*(60*60*24)"

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
    t=$(echo "$INFO" | sed -n 's/.*tr=\(.*\)/\1/p')
    t=$(printf '%b' "${t//%/\\x}")
    TRACKER=$(echo $t | awk -F '/' '{print $3}' | sed "s/\:.*//")
    LOCATION=$(echo "$INFO" | sed -n 's/.*Location: \(.*\)/\1/p')
    PROGRESS=$(echo "$INFO" | sed -n 's/.*Percent Done: \(.*\)%.*/\1/p')
    a=$(echo "$INFO" | sed -n 's/.*Latest activity: \(.*\)/\1/p' | awk '{ print $2 " " $3 " " $5 }')
    ACTIVITYDATE=$(date -d "$a" +%s)

    # Checks if the torrent belongs to specified tracker, completed, is located in specifed path and has been no activity since MAXAGE.
    if [[ "$TRACKER" == "$TRACKERURL" ]] && [[ "$PROGRESS" == "100" ]] && [[ "$LOCATION" == "$PATH" ]] && [[ $(date +%s) -gt $(($ACTIVITYDATE + $MAXAGE)) ]]; then
        echo "                : Match found, removing torrent and deleting data..."
        $TRANSCMD --torrent "$TORRENT_ID" --remove-and-delete > /dev/null
    fi
done
