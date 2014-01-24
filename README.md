x10delay
========

Simple bash and awk scripts which collect celestial event times from
[EarthTools](http://www.earthtools.org) and allows one to control X10 devices
using [heyu] (http://heyu.org). Easily expandable to use other interfaces. The
standard run method would be a cron event running well before the earliest
occurrence of the event one wants to trigger on:
If one wants to trigger on a sunrise then have the cron event occur
well before the earliest sunrise of the year for your location. For example a
crontab entry like below

0 4 * * * /path/to/x10delay.sh  morning sun -1800 A4 on

Will run at 4 AM every day to turn X10 module A4 a half hour (1800s) before
sunrise.

