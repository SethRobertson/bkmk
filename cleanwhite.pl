#!/usr/bin/perl -i
#
# Clean up nasty whitespace from files
#
#
# ++Copyright LIBBK++
#
# Copyright (c) 2003 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--

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
