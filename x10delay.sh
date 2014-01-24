#!/bin/sh

exedir=`dirname $0`

if [ $# -ne 4 ]; then
  echo "Need: time of day, event type, and unit code!"
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

HU="$3"
if [ "${HU}" == "" ] ; then
  echo "Pick HU: [A-Z][1-15]"
  exit
fi

x10cmd="$4"
if [ "${x10cmd}" == "" ] ; then
  echo "Pick X10 command: see heyu documentation"
  exit
fi


sfile="/tmp/suninfo.xml"

lat="38.913242"
long="-77.009096"

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
  echo "${oday} != ${day}"
  dststr=`date +%Z`
  dst=`echo ${dststr} | grep -c "DT" `

  surl="http://www.earthtools.org/sun/${lat}/${long}/${day}/${mon}/99/${dst}"

  wget -q -O ${sfile} ${surl}
fi

mtimehr=""
if [ "${tod}" == "sun" ]; then
  mtimehr=`awk -f ${exedir}/suninfo.awk ${sfile} | grep -A 1 "^${tod}" | tail -1`
  mtime=`date -d "${yr}-${mon}-${day} ${mtimehr} ${dststr}" +%s`
elif [ "${tod}" != "twilight" ]; then
  mtimehr=`awk -f ${exedir}/suninfo.awk ${sfile} | grep -A 2 "^${tod}" | tail -1`
  mtime=`date -d "${yr}-${mon}-${day} ${mtimehr} ${dststr}" +%s`
fi

if [ "${mtimehr}" == "" ]; then
  echo "Didn't get time!"
  exit
fi

tnow=`date +%s`

tdiff=$(( mtime - tnow ))

if [ ${tdiff} -gt 0 ]; then
  sleep ${tdiff}
  heyu ${x10cmd} ${HU}
  #echo "${HU} ${x10cmd}"
fi
