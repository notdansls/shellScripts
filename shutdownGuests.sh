#!/bin/bash

# This will be a script to gracefully shutdown any running VM's when a shutdown
# has been initiated by the host system

# Change log
# +------+------------+--------------------------------------------------------------------+-----------+
# | ver  |    Date    | Description                                                        |   Auth    |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.01 | 2021-03-14 | Initial Version                                                    |           |
# |      |            |   * Testing stage                                                  | notdansls |
# |      |            |   * take output from virsh list to array                           |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.50 | 2021-03-15 | First working version                                              |           |
# |      |            |   * Created functions to simplify code                             | notdansls |
# |      |            |   * removed echo debugging                                         |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.55 | 2021-03-16 | Second working version                                             |           |
# |      |            |   * Fixed bugs (if statements)                                     | notdansls |
# |      |            |   * Added descriptive comments                                     |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.60 | 2021-03-16 | Fix to Issue001 (No guests are running, nothing to do - 3x gues...)|           |
# |      |            |   * Line 34 Position 22                                            | notdansls |
# |      |            |      - Replaced '-gt' with '>'                                     |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.70 | 2021-03-17 | Include function to check if the guests have shutdown properly     |           |
# |      |            |   * Addition of verifyShutdown function (line 64)                  | notdansls |
# |      |            |   * Addition of timer to show elapsed time of shutdown process     |           |
# |      |            |   * Addition of Todo log                                           |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.75 | 2021-03-18 | Include function to log actions                                    |           |
# | 0.70 |            |   * Check if the log file exists, if not create it                 |           |
# | 0.70 |            |   * Take input from functions and write it to a file               |           |
# +------+------------+--------------------------------------------------------------------+-----------+
#
# Todo log
# +------+---------------------------------------------------------------------------------------------+
# | Status |    Description                                                                            |
# +------+---------------------------------------------------------------------------------------------+
# | [ 00 ] |    Status 00 - Idea, plan - Planning stage, code - coding and testing                     |
# +--------+-------------------------------------------------------------------------------------------+
# | [plan] |    Create a function that will log output to flat text file for review                    |
# +--------+-------------------------------------------------------------------------------------------+
# | [ 00 ] |    Modify code to make the script work as a shutdown script                               |
# +--------+-------------------------------------------------------------------------------------------+

# Functions
# ---------

listGuests(){
	## Get a list of running virtual machines
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
	# take vmname
	# preface it with virsh shutdown xxx
	# return true
	sudo virsh shutdown $1
        #return 0
}


verifyShutdown(){
	# This function will verify that the shutdown is complete
	# if guests are down, the script will terminate with exit code 0
	# or re-initiate the shutdown (This might not be so graceful
	# will need to revisit perhaps.

	listGuests
	
	intReturn=$?
	
	for (( ; ; ))
	do
		if [[ $intReturn -gt 0 ]]
		then
			if [[ $intReturn -eq 1 ]]
			then
				echo "$intReturn guest is still shutting down, sleeping for 10 seconds..."
			else
				echo "$intReturn guests are still shutting down, sleeping for 10 seconds..."
			fi
			sleep 10s
			runningGuests=( $(sudo virsh list --name) )
			intReturn="${#runningGuests[@]}"
		else
			break
		fi
	done
}


writeLog(){
	# Function to log writes to a file

	# First, we will check if the logfile exists

	# Next we will write the file.

	# Need to deciede if the file is to be written one line at a time or if we are going to
	# write an event at a time. 
}


# Code
# ----

# get start time
SECONDS=0

# This somewhat makes it redundant, verify shutdown...
verifyShutdown

intReturn=$?
# echo $intReturn

if [[ $intReturn -eq 0 ]]
then
	echo "Guests where running and have been asked to shutdown."
elif [[ $intReturn -eq 1 ]]
then
	echo "No guests are running, nothing to do."
fi

# get fin time and echo it to console
elapsedTime=$SECONDS
echo "$(($elapsedTime / 60 ))m $(($elapsedTime % 60 ))s"
