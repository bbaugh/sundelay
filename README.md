sundelay
========

Simple bash and awk scripts which collect celestial event times from
[EarthTools](http://www.earthtools.org) and execute commands at specific times.
The standard run method would be a cron event running well before the earliest
occurrence of the event one wants to trigger on:
If one wants to trigger on a sunrise then have the cron event occur
well before the earliest sunrise of the year for your location. For example a
crontab entry like below

0 4 * * * /path/to/sundelay.sh  morning sun -1800 "echo 'Hello World'"

Will run at 4 AM every day to print "Hello World" a half hour (1800s) before
sunrise.

One must edit sundelay.sh to:
 * change the location of the stored sun info: sfile variable
 * Set the lat and long to be used.

