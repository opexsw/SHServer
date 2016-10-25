#!/bin/sh

trapdata="alert"
while read LINE; do
   if [[ ${LINE} == SNMPv2-SMI::enterprises* ]];
   then
        FINALLINE=`echo ${LINE} | sed 's/^SNMPv2/,SNMPv2/g' | sed "s/SNMPv2/'SNMPv2/g" | sed "s/ \"/'=\"/g" | sed "s/SNMPv2-SMI::enterprises.20006.1.3.1.7 /SNMPv2-SMI::enterprises.20006.1.3.1.7'=/g"`
        trapdata="${trapdata} ${FINALLINE}"
   fi
done
UPDATEDFINALLINE=`echo ${trapdata} | sed 's/alert ,/alert /g'`
echo "$UPDATEDFINALLINE" >> /var/www/html/SHS/trappipe
