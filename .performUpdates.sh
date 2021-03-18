#!/bin/bash

## Functions ...
performUpdatesNow (){
	pacman -Syyyyu --noconfirm
	date -I >> /home/dan/.lastupdate
}

# Code...
# Get todays date from the shell
today=$(date -I)
longToday=$today+=" 00:00:00"
dateToday=$(echo "$longToday" | sed 's/[^0-9]//g')

# Get the last update date from the lastupdate File
lastUpdate=$(tail -1 /home/dan/.lastupdate)
longLastUpdate=$today+=" 00:00:00"
lastUpdated=$(echo "$longLastUpdate" | sed 's/[^0-9]//g')


# Calculate the number of days since the last update.
calculateDaysPast=$(echo "( `date -d $today +%s` - `date -d $lastUpdate +%s`) / (24*3600)" | bc -l)
daysPast=$(printf "%.0f\n" $calculateDaysPast)


if [ $daysPast -gt 0 ]
then
	performUpdatesNow
elif [ $daysPast -lt 0 ]
then
	echo "WARNING: The date found in the last update file is newer than today's date."
	echo
	echo "You should check system dates to confirm what is going on."
fi
