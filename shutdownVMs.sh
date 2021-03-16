#!/bin/bash

# This will be a script to gracefully shutdown any running VM's when a shutdown
# has been initiated by the host system

# Change log
# +------+------------+--------------------------------------------------------------------+-------+
# | ver  |    Date    | Description                                                        | Auth  |
# +------+------------+--------------------------------------------------------------------+-------+
# | 0.01 | 2021-03-14 | Initial Version                                                    |       |
# |      |            |   * Testing stage                                                  | ndsls |
# |      |            |   * take output from virsh list to array                           |       |
# +------+------------+--------------------------------------------------------------------+-------+

# Functions
# ---------

listGuests(){
	## Get a list of running virtual machines
	activeGuests=( $(sudo virsh list --name) )
	x=1
	# Check if there are any active virtual machines running
	if $activeGuests[@] > 0 then
		for i in "$activeGuests[@]"; do
			killGuest $i
			if $? = 0 then return 0
		done
	else
		return 1
	fi
}


killGuest(){
	# take vmname
	# preface it with virsh shutdown xxx
	# return true
	echo $1
        return 0
}

if $listGuests = 0 then
	echo Guests shutting down
else
	echo no guests found
fi

