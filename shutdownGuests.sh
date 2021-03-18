#!/bin/bash

# This will be a script to gracefully shutdown any running VM's when a shutdown
# has been initiated by the host system

# Change log
# +------+------------+--------------------------------------------------------------------+-----------+
# | ver  |    Date    | Description                                                        |   Auth    ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.01 | 2021-03-14 | Initial Version                                                    |           ||
# |      |            |   * Testing stage                                                  | notdansls ||
# |      |            |   * take output from virsh list to array                           |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.50 | 2021-03-15 | First working version                                              |           ||
# |      |            |   * Created functions to simplify code                             | notdansls ||
# |      |            |   * removed echo debugging                                         |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.55 | 2021-03-16 | Second working version                                             |           ||
# |      |            |   * Fixed bugs (if statements)                                     | notdansls ||
# |      |            |   * Added descriptive comments                                     |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.60 | 2021-03-16 | Fix to Issue001 (No guests are running, nothing to do - 3x gues...)|           ||
# |      |            |   * Line 34 Position 22                                            | notdansls ||
# |      |            |      - Replaced '-gt' with '>'                                     |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.70 | 2021-03-17 | Include function to check if the guests have shutdown properly     |           ||
# |      |            |   * Addition of verifyShutdown function (line 64)                  | notdansls ||
# |      |            |   * Addition of timer to show elapsed time of shutdown process     |           ||
# |      |            |   * Addition of Todo log                                           |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.75 | 2021-03-18 | Include function to log actions                                    |           ||
# |      |            |   * Check if the log file exists, if not create it                 | notdansls ||
# |      |            |   * Take input from functions and write it to a file               |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
# | 0.80 | 2021-03-18 | Modify killGuest to write out to the log when shutting down each   |           ||
# |      |            | guest.                                                             | notdansls ||
# |      |            |                                                                    |           ||
# +------+------------+--------------------------------------------------------------------+-----------+|
#  -----------------------------------------------------------------------------------------------------+
#
# Todo log
# +------+---------------------------------------------------------------------------------------------+
# | Status |    Description                                                                            ||
# +------+---------------------------------------------------------------------------------------------+|
# | [ 00 ] |    Status 00 - Idea, plan - Planning stage, code - coding and testing                     ||
# +--------+-------------------------------------------------------------------------------------------+|
# | [done] |    Create a function that will log output to flat text file for review                    ||
# +--------+-------------------------------------------------------------------------------------------+|
# | [ 00 ] |    Modify code to make the script work as a shutdown script                               ||
# +--------+-------------------------------------------------------------------------------------------+|
#  -----------------------------------------------------------------------------------------------------+

# Functions
# ---------
listGuests(){
	# Get a list of running virtual machines
	activeGuests=( $(sudo virsh list --name) )
	intAG="${activeGuests[@]}"
	intClientCount="${#activeGuests[@]}"
	x=1
	# Check if there are any active virtual machines running
	if [[ $intAG > 0 ]]; then # issue001: Line 34 Pos 22: replace '-gt' with '>'
		for i in "${activeGuests[@]}"; do
			killGuest $i
			x=$(($x + 1))			
		done
		# Return 0 if Guests where trigged to shutdown. Action performed
		return $intClientCount
	else
		# Return 1 if there are no Guests running, nothing to do.
		return 0
	fi
}


killGuest(){
	# Write log file before ending shutdown command then issue shutdown command
	writeLog "Domain '$1' is shutting down"
	sudo virsh shutdown $1 >> /dev/null

}

initiateShutdown(){
	# This function will verify that the shutdown is complete

	listGuests
	
	intReturn=$?
	
	for (( ; ; ))
	do
		if [[ $intReturn -gt 0 ]]
		then
			if [[ $intReturn -eq 1 ]]
			then
				writeLog "$intReturn guest is still shutting down. Script will sleeping for 10 seconds"
			else
				writeLog "$intReturn guests are still shutting down. Script will sleep for 10 seconds"
			fi
			sleep 10s
			runningGuests=( $(sudo virsh list --name) )
			intReturn="${#runningGuests[@]}"
		else
			return 1
		fi
	done
}


writeLog(){
	# Function to log writes to a file

	# Set variables used in log file creation	
	logFile=/var/log/guestShutdown.log
	logText=$1
	currentTime=( "$(date +%H:%M:%S)" )
	upTime=( "$(uptime -p)" )
	scriptTime=( "$(($SECONDS / 60 ))m $(($SECONDS % 60 ))s" )

	# Check to see if the log file exists, if not create it.
	if [ ! -f $logFile ];
	then
		touch $logFile
		printf "Time\tuptime\tScriptTime\tDescription\n" >> $logFile
		printf "$currentTime\t$upTime\t$scriptTime\tLogfile does not exist. Created.\n" >> $logFile
	fi
	
	# Write the log entry to file
	printf "$currentTime\t$upTime\t$scriptTime\t$logText.\n" >> $logFile
}


# Code
# ----

# get start time
SECONDS=0

# This is where it all really begins, start shutting everything down
initiateShutdown

# Take the return value and convert it to a variable
intReturn=$?

# Decide if guests where shutdown or not.
if [[ $intReturn -eq 0 ]]
then
	writeLog "Guests have been sucessfully shutdown"
elif [[ $intReturn -eq 1 ]]
then
	writeLog "No guests are running"
fi

# Wrapping up running of the scrip. Get the elapesed time and pipe it out to the log file
elapsedTime=$SECONDS
writeLog  "Script ending after $(($elapsedTime / 60 ))m $(($elapsedTime % 60 ))s"
