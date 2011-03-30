#!/usr/bin/perl -i.bak
#
# ++Copyright BAKA++
#
# Copyright © 2011 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -
#

use strict;
use warnings;
no warnings "uninitialized";

my %space;

while (<>)
{
  s/[ \t]+$//;
  if(/^\t*  +\t/)
  {
    while (s/^(\t*) {8}/$1\t/) { 1; }
    while (s/^(\t*) +\t/$1\t/) { 1; }
  }
  print;
}
