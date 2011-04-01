#! /bin/sh
#
#
# ++Copyright BAKA++
#
# Copyright © 2003-2011 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -
#

case `uname -s` in
  *Linux*) : ;;
  '') echo UNKNOWN; exit ;;
  *)
    echo `uname -s` `uname -r | sed -e 's/-.*//'` | sed -e 's/ /-/' -e 's/ //g'
    exit
    ;;
esac

if [ -f /etc/debian_version ]; then
  sed -e 's/^/DebianLinux-/' -e 's:/:-:g' /etc/debian_version
  exit
elif [ -f /etc/slackware-version ]; then
  sed -e 's/^\([0-9]*.[0-9]*\).*/SlackwareLinux-\1/' /etc/slackware-version
  exit
elif [ -f /etc/SuSE-release ]; then
  echo SuSE`uname -s` `uname -r | sed -e 's/-.*//'` \
   | sed -e 's/ /-/' -e 's/ //g'
  exit
elif [ -f /etc/gentoo-release ]; then
  sed -e '/^Gentoo /s/.* \([0-9][0-9.]*\)/GentooLinux-\1/' /etc/gentoo-release
  exit
fi

for REL in /etc/lsb-release.d /etc/*-release /etc/issue
do
  case $REL in
    */lsb-release*)
      # use lsb_release if present
      DIST_ID=`lsb_release -is 2>/dev/null`
      if [ -n "$DIST_ID" ]; then
	REL_ID=`lsb_release -rs`
	echo ${DIST_ID%-CounterStorm}Linux-${REL_ID}-`uname -m`
	exit
      else
	continue
      fi
      ;;
    */fedora-release) E="-e s/Core/CoreLinux/" ;;
    *) unset E ;;
  esac
  if [ -f "$REL" ]; then
    sed -e 's/release//' -e 's/ \([0-9][0-9.]*\).*/-\1/' -e 's/ //g' -e '3q' \
     $E -e "s/$/-`uname -m`/" < $REL | grep Linux && exit
  fi
done

echo Unknown`uname -s` `uname -r | sed -e 's/-.*//'` \
 | sed -e 's/ /-/' -e 's/ //g'
