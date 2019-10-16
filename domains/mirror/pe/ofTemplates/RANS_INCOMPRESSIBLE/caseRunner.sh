#!/bin/bash

startFile="start.signal"
doneFile="done.signal"
stopFile="stop.signal"

./allClean.sh
rm _inactive.state
touch _active.state

while true
sleep 1s
do

if [ -f "$stopFile" ]
then
	echo "$stopFile found, ending caseRunner."
	rm _active.state
	touch _inactive.state
	break;
fi

if [ -f "$startFile" ]
	then
	echo "$startFile found: starting OpenFOAM case."
    rm start.signal
	bash allClean.sh
	bash RANS_INCOMPRESSIBLE.sh
else
	echo -n "Waiting for $startFile..."
fi

done
