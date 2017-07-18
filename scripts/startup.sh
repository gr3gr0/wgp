#!/bin/sh

#Check if Webgrab++ config file exists in config folder. Copy to config if non-existent.
if [ ! -f /config/WebGrab++.config.xml ]; then
  cp /webgrab/assets/WebGrab++.config.xml /config/
fi

#Check if mdb folder exists ...
if [ ! -d /config/mdb ]; then
  cp -R /webgrab/mdb /config/ && rm -f /config/mdb/*.example.xml
fi

#Check if rex folder exists ...
if [ ! -d /config/rex ]; then
  cp -R /webgrab/rex /config/ && rm -f /config/rex/*.example.xml
fi

#Check if any INI file exists. Copy default siteini.pack if non-existent
count=`ls -1 /config/siteini.pack/*.txt 2>/dev/null | wc -l`
if [ $count = 0 ]; then
  cp -R /webgrab/siteini.pack/ /config/ && rm -f /config/rex/*.example.xml
fi

#Check if user modified cron file exists and move to wg++.
if [ -e /config/mycron ]; then
  crontab -u nobody /config/mycron
fi

#Change owner for config files and guide.xml
chown -R nobody:users /config
chown -R nobody:users /data

#Start an update on container start if config file exists
if [ -f /config/WebGrab++.config.xml ]; then
  sudo -u nobody mono /webgrab/bin/WebGrab+Plus.exe "/config"
fi
