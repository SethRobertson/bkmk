#! /usr/bin/perl -i.bak
#
# <TODO>This script should be enhanced to maintain existing copyright dates,
# as well as choice of Baka vs. SysD copyright notices</TODO>

######################################################################
## BAKA
$BAKAHDR = <<EOF;
#if !defined(lint) && !defined(__INSURE__)
static char libbk__rcsid[] = "\$Id\$";
static char libbk__copyright[] = "Copyright (c) 2002";
static char libbk__contact[] = "<projectbaka\@baka.org>";
#endif /* not lint */
EOF

$BAKAPROD = <<EOF;
++Copyright LIBBK++

Copyright (c) 2002 The Authors. All rights reserved.

This source code is licensed to you under the terms of the file
LICENSE.TXT in this release for further details.

Mail <projectbaka\@baka.org> for further information

--Copyright LIBBK--
EOF

######################################################################
## System Detection
$SYSDHDR = <<EOF;
#if !defined(lint) && !defined(__INSURE__)
static char sysd__rcsid[] = "\$Id\$";
static char sysd__copyright[] = "Copyright (c) 2002 System Detection";
static char sysd__contact[] = "System Detection <support\@systemdetection.com>";
#endif /* not lint */
EOF

$SYSDPROD = <<EOF;
++Copyright SYSDETECT++

Copyright (c) 2002 System Detection.  All rights reserved.

THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF SYSTEM DETECTION.
The copyright notice above does not evidence any actual
or intended publication of such source code.

Only properly authorized employees and contractors of System Detection
are authorized to view, possess, to otherwise use this file.

System Detection
5 West 19th Street Floor 2K
New York, NY 10011-4240

+1 212 206-1900
<support\@systemdetection.com>

--Copyright SYSDETECT--
EOF


require "getopts.pl";

$prod = 1;

do Getopts('b');

if ($opt_b)
{
  $prod = 0;
}

$q1 = '\#if \!defined\(lint\) \&\& \!defined\(__INS...T?__\)';
$q2 = '\#endif \/\* not lint \*\/';

while (<>)
{
  # Header stuff
  # (Only try header stuff if first line)
  if ($. < 5 && /^$q1$/)
    {
      while (<>)
	{
	  if (/^$q2$/)
	    {
	      last;
	    }
	}
      if ($prod)
	{
	  print $SYSDHDR;
	}
      else
	{
	  print $BAKAHDR;
	}
      next;
    }

  if (eof)
    {
      close(ARGV);
    }

  # Copyright
  if (/(.*)\+\+Copyright\ .*\+\+/)
    {
      $PREFIX=$1;
      while (<>)
	{
	  if (/ \-\-Copyright\ .*\-\-/)
	    {
	      last;
	    }
	}
      if ($prod)
	{
	  pprint($PREFIX,$SYSDPROD);
	}
      else
	{
	  pprint($PREFIX,$BAKAPROD);
	}
      next;
    }
  print;
}



sub pprint($$)
{
  my ($prefix,$string) = @_;
  my (@lines);

  @lines = split(/\n/,$string);
  print $prefix.join("\n$prefix",@lines)."\n";
}
