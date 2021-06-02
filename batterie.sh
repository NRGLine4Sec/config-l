#!/bin/bash
quand=$(date +"%d/%m/%Y %H:%M:%S")
comment=$(cat /proc/acpi/battery/BAT0/state | grep "charging state" | cut -c26-36)
combien=$(cat /proc/acpi/battery/BAT0/state | grep "remaining" | cut -c26-28)
derniere=$(tail -n 1 bat.log | cut -d ';' -f 3 | cut -c 0-3)
if ! &#91; $combien = $derniere &#93;
then
echo $quand";"$comment";"$combien"%" >> bat.log
fi
if ! &#91; $combien = "100"&#93;
then
at -f trace.bat now + 1 minutes
fi
