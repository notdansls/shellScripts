#!/bin/bash
# quick script to start each Guest
startHosts=( "VM1" "VM2" "VM3" )

x=1

for i in "${startHosts[@]}"; do
	sudo virsh start $i
	x=$(($x + 1))
done

echo "All hosts have been started..."
