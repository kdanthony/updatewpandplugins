Update Wordpress and Plugins
==================

Simple script to update wordpress and all plugins specified quickly. I got tired of updating these by hand and I am not ok with using FTP on my site like wordpress will use when doing the updates automatically.

NOTE: This script forcibly updates wordpress and plugins if they need it or not, it is not going to be compatible with any plugins that you have customized distributed files in.

NOTE: This does not update themes currently.

USAGE: ./updatewpandplugins.sh /path/to/wordpress

Present directory will be used to create a download/unpack directory so you must have write permissions.
