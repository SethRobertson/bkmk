#!/usr/bin/perl -i
#
# Clean up nasty whitespace from files
#
#
# ++Copyright BAKA++
#
# Copyright © 2003-2010 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -

while (<>)
{
  if (/[ \t]+$/)
  {
    if (/\\[ \t]+$/ || $ARGV =~ /\.MF/ || $ARGV =~ /\.gif/)
    {
      # Don't nuke backslash-quoted (or other magic) whitespace
    }
    else
    {
      s/[ \t]$//;
    }
  }
  print;
}
