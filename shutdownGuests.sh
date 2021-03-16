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
# | 0.50 | 2021-03-14 | First working version                                              |           |
# |      |            |   * Created functions to simplify code                             | notdansls |
# |      |            |   * removed echo debugging                                         |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.55 | 2021-03-14 | Second working version                                             |           |
# |      |            |   * Fixed bugs (if statements)                                     | notdansls |
# |      |            |   * Added descriptive comments                                     |           |
# +------+------------+--------------------------------------------------------------------+-----------+
# | 0.60 | 2021-03-14 | Fix to Issue001 (No guests are running, nothing to do - 3x gues...)|           |
# |      |            |   * Line 34 Position 22                                            | notdansls |
# |      |            |      - Replaced '-gt' with '>'                                     |           |
# +------+------------+--------------------------------------------------------------------+-----------+



# Functions
# ---------

listGuests(){
	## Get a list of running virtual machines
	activeGuests=( $(sudo virsh list --name) )
	intAG="${activeGuests[@]}"
	x=1
	# Check if there are any active virtual machines running
	if [[ $intAG > 0 ]]; then # issue001: Line 34 Pos 22: replace '-gt' with '>'
		for i in "${activeGuests[@]}"; do
			killGuest $i
			x=$(($x + 1))			
		done
		# Return 0 if Guests where trigged to shutdown. Action performed
		return 0
	else
		# Return 1 if there are no Guests running, nothing to do.
		return 1
	fi
}


killGuest(){
	# take vmname
	# preface it with virsh shutdown xxx
	# return true
	sudo virsh shutdown $1
        #return 0
}



# Code
# ----

listGuests
intReturn=$?
# echo $intReturn

if [[ $intReturn -eq 0 ]]
then
	echo "Guests where running and have been asked to shutdown."
elif [[ $intReturn -eq 1 ]]
then
	echo "No guests are running, nothing to do."
fi
