#!/bin/sh
# WARNING!: This script assumes that suninfo.awk is contained within the same
#           directory
# Usage: sundelay.sh TOD EVT OFFSET EXECMD
#        TOD - time of day: morning or evening
#        EVT - celestial event time: sun or twilight
#        OFFSET - offset in seconds from EVT when EXECMD will be issued.
#        EXECMD - command to execute.
#
# Edit file to:
# * change the location of the stored sun info: sfile variable
# * Set the lat and long to be used.
exedir=`dirname $0`

sfile="/tmp/suninfo.xml"

lat="38.913242"
long="-77.009096"


if [ $# -lt 4 ]; then
  echo "Need: time of day, event type, and command!"
  exit
fi

tod="$1"

if [ "${tod}" != "evening" ] && [ "${tod}" != "morning" ]; then
  echo "Pick time of day: morning or evening"
  exit
fi

evt="$2"

if [ "${evt}" != "sun" ] && [ "${evt}" != "twilight" ]; then
  echo "Pick event: sun or twilight"
  exit
fi


offset="$3"
if [ "${offset}" == "" ] ; then
  echo "Please set OFFSET."
  exit
fi

execmd="$4"
if [ "${execmd}" == "" ] ; then
  echo "Set command to execute"
  exit
fi

donow="no"
if [ $# -gt 4 ]; then
  donow="$5"
fi

yr=`date +%Y`
mon=`date +%m`
day=`date +%d`
dststr=`date +%Z`
tzoff=`date '+%:z'`

oday="-1"
if [ -r "${sfile}" ]; then
  oday=`grep "<day>[^<]\+</day>" ${sfile} | sed -e 's/<day>//g' -e 's/<\/day>//g' `
fi

# Only update info once a day
if [ "${oday}" -ne "${day}" ]; then
  dststr=`date +%Z`
  dst=`echo ${dststr} | grep -c "DT" `

  surl="http://www.earthtools.org/sun/${lat}/${long}/${day}/${mon}/99/${dst}"

  wget -q -O ${sfile} ${surl}
fi

mtimehr=""
if [ "${evt}" == "sun" ]; then
  mtimehr=`awk -f ${exedir}/suninfo.awk ${sfile} | grep -A 1 "^${tod}" | tail -1`
elif [ "${evt}" != "twilight" ]; then
  mtimehr=`awk -f ${exedir}/suninfo.awk ${sfile} | grep -A 2 "^${tod}" | tail -1`
fi

mtime=`date -d "${yr}-${mon}-${day} ${mtimehr}" +%s`

if [ "${mtimehr}" == "" ]; then
  echo "Didn't get time!"
  exit
fi

tnow=`date +%s`

tdiff=$(( mtime + offset - tnow  ))

if [ ${tdiff} -gt 0 ]; then
  #echo -e "Running:\n${execmd}\nin ${tdiff}"
  sleep ${tdiff} && ${execmd}
elif [ "${donow}" != "no" ]; then
  ${execmd}
fi
