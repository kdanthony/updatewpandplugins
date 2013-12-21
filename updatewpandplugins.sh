#!/bin/bash

# Simple Wordpress Updater
# ================================================================================
# Updates wordpress and all isntalled plugins to their newest versions automatically.
# ================================================================================
#
# Copyright (c) 2013, Kevin Anthony (kevin@anthonynet.org
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.A

# You should not need to change these unless Wordpress changes their URL schemes
# URLs for wordpress downloads
WPURL=http://wordpress.org/latest.zip
WPPLUGINURL=http://downloads.wordpress.org/plugin/
BASEDIR=`pwd`

function scriptusage() {
    echo "USAGE: updatewpandplugins.sh /path/to/wordpress"
}

if [ ! $1 ]; then
    scriptusage
    exit
else
    SITEDIR=$*
fi


# ------------

if [ ! -f "${SITEDIR}/wp-config.php" ]; then
    echo "ERROR: There does not appear to be a Wordpress installation in ${SITEDIR}"
    exit 1
fi

echo "==============================================================================="
echo "  Upgrading Wordpress and all plugins for:"
echo "             ${SITEDIR}"
echo "==============================================================================="
echo
echo " ******** THIS WILL OVERWRITE ALL DEFAULT WORDPRESS AND PLUGIN FILES *********"
echo
read -p "Do you wish to continue? [y/n]:  " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "ERROR: Upgrade cancelled"
    exit 1
fi

echo "==============================================================================="
echo "Starting update process for ${SITEDIR}"
echo "==============================================================================="

if [ -d "${BASEDIR}/downloads" ]; then
    echo "* Cleaning existing download directory"
    rm -rf "${BASEDIR}/downloads"
    mkdir "${BASEDIR}/downloads"
else
    echo "* No download directory exists, creating it"
    mkdir "${BASEDIR}/downloads"
fi

if [ -d "${BASEDIR}/unpack" ]; then
    echo "* Cleaning existing unpack directory"
    rm -rf "${BASEDIR}/unpack"
    mkdir "${BASEDIR}/unpack"
else
    echo "* No unpack directory exists, creating it"
    mkdir "${BASEDIR}/unpack"
fi

echo "==============================================================================="
echo "* Downloading Wordpress";
curl --progress-bar ${WPURL} -o ${BASEDIR}/downloads/wordpress.zip
echo "* Downloading Plugins";

cd "${BASEDIR}/downloads/"

for PLUGINNAME in `find "${SITEDIR}/wp-content/plugins/" -mindepth 1 -maxdepth 1 -xtype d | sed -e 's/.*plugins\///g'`; do
    echo ${PLUGINNAME}
    curl --progress-bar -O ${WPPLUGINURL}${PLUGINNAME}.zip
done

#while read pluginurl; do
#    echo "* Downloading ${pluginurl}"
#    curl --progress-bar -O ${pluginurl}
#done < ${BASEDIR}/plugins.txt

mkdir "${BASEDIR}/unpack/plugins"
mkdir "${BASEDIR}/unpack/wordpress"

cd "${BASEDIR}/unpack/"
echo "==============================================================================="

if [ -e "${BASEDIR}/downloads/wordpress.zip" ]; then
    echo "* Unpacking Wordpress"
    unzip -q "${BASEDIR}/downloads/wordpress.zip"
    rm -f "${BASEDIR}/downloads/wordpress.zip"
else
    echo "* No ${BASEDIR}/downloads/wordpress.zip exists, can't extract"
fi

cd "${BASEDIR}/unpack/plugins"

echo "* Unpacking plugins"
unzip -q "${BASEDIR}/downloads/*.zip"


echo "* Upgrading Wordpress"
\cp -a "${BASEDIR}/unpack/wordpress"/* "${SITEDIR}/"

echo "* Upgrading plugins"
\cp -a "${BASEDIR}/unpack/plugins"/* "${SITEDIR}/wp-content/plugins/"

echo "==============================================================================="
echo "Upgrading is complete! You will want to visit your site's wp-admin URL to"
echo "accept any database updates required for the Wordpress update"
exit 0
