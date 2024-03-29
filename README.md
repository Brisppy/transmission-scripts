# transmission-scripts

Various shell scripts for automating the removal or modification of torrents in Transmission.

## Requires:
transmission-remote (Or transmisison-cli)

## Installation:
1. Clone the repository to a folder of your choosing and move into the directory.
```
git clone https://github.com/Brisppy/transmission-scripts
cd transmission-scripts
```
2. Create a new file named 'auth' in the directory and add the following lines
```
# Modify the 'host:port' and 'username:port' lines to match your environment.
# If you do not use any authentication, remove 'username:password' from the AUTH variable (Leave the quotation marks).
# If using SSL, change 'SSL' to '1'.
SERVER="host:port"
AUTH="username:password"
SSL="0"
```
3. Modify the variables in 'auth' to suit your environment according to the provided instructions.

## Included scripts:
* **no-seed-public** limits the upload speed of any public torrents. The desired upload speed can be set with the UPLIMIT variable.
* **stop-completed-public** stops any completed public torrent.
* **stop-old-public** stops completed public torrents over a certain age. The maximum age for a torrent can be set with the MAXAGE variable.
* **delete-old-public** removes and deletes any completed public torrents over a certain age. The maximum age for a torrent can be set with the MAXAGE variable.
* **delete-old-specified-tracker** removes and deletes torrents over a specified age which belong to a specified tracker.

See the comments of each script for required arguments (if any).

## Credits
* Thanks to https://github.com/pawelszydlo and their script to remove finished downloads which formed the basis of my scripts.