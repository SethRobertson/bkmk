#!/usr/bin/perl
#
#
# ++Copyright BAKA++
#
# Copyright © 2002-2010 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -
#
#
$topdir_inode=(stat("$ARGV[0]"))[1];
$last_inode=0;
$done=0;
while (!$done)
{
  # Sigh.. we'd love to autoconf this, but alas we get into a bootstrapping
  # problem. Well OK, if they don't have pwd, then they're pretty screwed.
  chomp($pwd=`pwd`);
  $curdir_inode=(stat($pwd))[1];

  # infinite recursion protection (not just stepping up to /, but hard links to directories can
  #					kill you too).
  last if ($curdir_inode eq $last_inode);

  if (-f "$pwd/.user-variables" )
    {
      print "$pwd/.user-variables\n";
      $done=1;
    }
  else
    {
      $done=1 if ($curdir_inode eq $topdir_inode);
    }
  chdir("..");
}
exit (0);
