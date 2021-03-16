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

# Functions
# ---------

listGuests(){
	## Get a list of running virtual machines
	activeGuests=( $(sudo virsh list --name) )
	x=1
	# Check if there are any active virtual machines running
	if [ $activeGuests[@] > 0 ]; then
		for i in "${activeGuests[@]}"; do
			killGuest $i
			x=$(($x + 1))			
		done
		return 0
	else
		return 1
	fi
}


killGuest(){
	# take vmname
	# preface it with virsh shutdown xxx
	# return true
	sudo virsh shutdown $1
        return 0
}

# Code
# ----

listGuests

#echo $?

#if [ -f $? > 0 ]; then
#	echo Guests shutting down
#else
#	echo no guests found
#fi
