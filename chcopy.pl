#! /usr/bin/perl -i.bak
# $Id: chcopy.pl,v 1.14 2006/03/31 00:08:49 dupuy Exp $
#
# ++Copyright LIBBK++
#
# Copyright © 2001-2003,2006 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--
#
#
# <TODO>This script should be enhanced to maintain existing copyright dates, or
# better yet, generate them from CVS history of non-trivial changes.  It would
# also be useful to auto-detect file encoding (ISO-8859-1 or UTF-8?) so that ©
# is encoded properly (for now, assume 8859-1 as it is unambiguous).</TODO>

$YEAR = 1900 + (localtime time)[5];

######################################################################
## BAKA
$BAKAHDR = <<EOF;
#if !defined(lint)
static const char libbk__rcsid[] = "\$Id\$";
static const char libbk__copyright[] = "Copyright © $YEAR";
static const char libbk__contact[] = "<projectbaka\@baka.org>";
#endif /* not lint */
EOF

$BAKAPROD = <<EOF;
++Copyright BAKA++

Copyright © $YEAR The Authors. All rights reserved.

This source code is licensed to you under the terms of the file
LICENSE.TXT in this release for further details.

Send e-mail to <projectbaka\@baka.org> for further information.

- -Copyright BAKA- -
EOF

######################################################################
## CounterStorm
$CSHDR = <<EOF;
#if !defined(lint)
static const char cs__rcsid[] = "\$Id\$";
static const char cs__copyright[] = "Copyright © $YEAR CounterStorm, Inc.";
static const char cs__contact[] = "CounterStorm <support\@counterstorm.com>";
#endif /* not lint */
EOF

$CSPROD = <<EOF;
++Copyright COUNTERSTORM++

Copyright © $YEAR CounterStorm, Inc.  All rights reserved.

THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF COUNTERSTORM, INC.
The copyright notice above does not evidence any actual
or intended publication of such source code.

Only properly authorized employees and contractors of CounterStorm, Inc.
are authorized to view, possess, or otherwise use this file.

CounterStorm, Inc.
15 West 26th Street 7th Floor
New York, NY 10010-1002

+1 212 206 1900
<support\@counterstorm.com>

- -Copyright COUNTERSTORM- -
EOF


require "getopts.pl";

$prod = -1;

do Getopts('bc');

if ($opt_b)
{
  $prod = 0;
}
if ($opt_c)
{
  $prod = 1;
}

$q1 = '\#if \!defined\(lint\)';
$q2 = '\#endif \/\* not lint \*\/';

while (<>)
{
  # Header stuff
  # (Only try header stuff for first five lines)
  if ($. < 5 && /^$q1/)
  {
    while (<>)
    {
      $prod = 0 if ($prod < 0 && (/bk__/ || /libbk__/));
      $prod = 1 if ($prod < 0 && (/cs__/ || /sysd__/));
      if (/^$q2$/)
      {
	last;
      }
    }
    if ($prod)
    {
      $prod = 1;		# ignore inconsistent copyright below
      print $CSHDR;
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
  if (/(.*)\+\+Copyright\ (.*)\+\+/)
  {
    $PREFIX=$1;
    $prod = 0 if ($prod < 0 && $2 =~ /(BAKA|LIBBK)/);
    $prod = 1 if ($prod < 0 && $2 =~ /(COUNTERSTORM|SYSDETECT)/);
    while (<>)
    {
      if (/\-\s?\-Copyright\ .*\-\s?\-/)
      {
	last;
      }
    }
    if ($prod)
    {
      pprint($PREFIX,$CSPROD);
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
  my ($output);

  @lines = split(/\n/,$string);
  $output = sprintf("%s",$prefix.join("\n$prefix",@lines)."\n");
  $output =~ s/[ \t]+$//mg;
  print $output;
}
