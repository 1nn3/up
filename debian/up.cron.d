#
# Regular cron jobs for the up package
#

# maintenance
0 4	* * *	root	[ -x /usr/bin/up_maintenance ] && /usr/bin/up_maintenance
0 *	* * *	root	[ -x /usr/bin/up-cronjob ] && /usr/bin/up-cronjob

