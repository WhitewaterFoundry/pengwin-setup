#
# Regular cron jobs for the wlinux-setup package
#
0 4	* * *	root	[ -x /usr/bin/wlinux-setup_maintenance ] && /usr/bin/wlinux-setup_maintenance
