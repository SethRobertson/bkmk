#! /bin/sh
# $Id: os-name.sh,v 1.2 2003/10/08 18:08:02 dupuy Exp $
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
if [ -f /etc/redhat-release ]; then
    sed -e 's/release \([0-9.]*\).*/-\1/' -e 's/ //g' /etc/redhat-release
else
    echo UNKNOWN
fi
