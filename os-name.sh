#! /bin/sh
# $Id: os-name.sh,v 1.3 2003/10/08 19:58:01 dupuy Exp $
#
# ++Copyright SYSDETECT++
#
# Copyright (c) 2003 System Detection.  All rights reserved.
#
# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF SYSTEM DETECTION.
# The copyright notice above does not evidence any actual
# or intended publication of such source code.
#
# Only properly authorized employees and contractors of System Detection
# are authorized to view, possess, to otherwise use this file.
#
# System Detection
# 5 West 19th Street Floor 2K
# New York, NY 10011-4240
#
# +1 212 206 1900
# <support@sysd.com>
#
# --Copyright SYSDETECT--
#

if [ -f /etc/debian_version ]; then
  sed -e 's/^/DebianLinux-/' /etc/debian_version
  exit
elif [ -f /etc/slackware-version ]; then
  sed -e 's/^\([0-9]*.[0-9]*\).*/SlackwareLinux-\1/' /etc/slackware-version
  exit
fi

for REL in /etc/*-release /etc/issue
do
  if [ -f "$REL" ]; then
    sed -e 's/release//' -e 's/ \([0-9][0-9.]*\).*/-\1/' -e 's/ //g' -e '3q' \
     < $REL | grep Linux && exit
  fi
done

echo `uname -s` `uname -r | sed -e 's/-.*//'` | sed -e 's/ /-/' -e 's/ //g'
