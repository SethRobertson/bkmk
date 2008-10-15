#! /usr/bin/perl -i.bak
# 
#
# ++Copyright LIBBK++
#
# Copyright © 2001-2003,2006-2008 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--
#
#
# <TODO>Should auto-detect file encoding (ISO-8859-1 or UTF-8?) so that ©
# is encoded properly (now defaults to UTF-8, but uses existing symbol).</TODO>
#
# <TODO>Should determine current branch and compute years from commits on that
# branch and on trunk before that branch (now always uses trunk commits).</TODO>
#

######################################################################
## BAKA
($BAKAHDR = <<'EOF') =~ s/^\|//gm;
|#if !defined(lint)
|static const char libbk__copyright[] = "Copyright (c) YEARS";
|static const char libbk__contact[] = "<projectbaka@baka.org>";
|#endif /* not lint */
EOF

($BAKAPROD = "++"."Copyright BAKA++\n".<<'EOF') =~ s/^\|//gm;
|
|Copyright (c) YEARS The Authors. All rights reserved.
|
|This source code is licensed to you under the terms of the file
|LICENSE.TXT in this release for further details.
|
|Send e-mail to <projectbaka@baka.org> for further information.
|
|- -Copyright BAKA- -
EOF

######################################################################
## Trusted CS
($CSHDR = <<'EOF') =~ s/^\|//gm;
|#if !defined(lint)
|static const char tcs__copyright[] = "Copyright (c) YEARS TCS Commercial, Inc.";
|static const char tcs__contact[] = "TCS Commercial, Inc. <CounterStorm@TrustedCS.com>";
|#endif /* not lint */
EOF

($CSPROD =  "++"."Copyright TRUSTEDCS++\n".<<'EOF') =~ s/^\|//gm;
|
|Copyright (c) YEARS Trusted Computer Solutions, Inc.  All rights reserved.
|
|THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF TRUSTED COMPUTER SOLUTIONS, INC.
|The copyright notice above does not evidence any actual
|or intended publication of such source code.
|
|Only properly authorized employees and contractors of Trusted Computer
|Solutions, Inc. are authorized to view, possess, or otherwise use this file.
|
|Trusted Computer Solutions
|2350 Corporate Park Drive, Suite 500
|Herndon, VA  20171-4848
| (866) 230-1307
|+1-703-318-7134
|<support@trustedcs.com>
|
|- -Copyright TRUSTEDCS- -
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
  if (!defined($YEARS))
  {
    if ($ARGV ne '-')
    {
      $ARGV =~ m=(.*/)?(.*)=;
      $dir = $1;
      $file = $2;
      $git_dir = $dir . '.git';
      $gfile = $file;
    git_dir:
      while (1)
      {
	last git_dir if (-d $git_dir);

	if ($git_dir =~ m=[^/]/=)
	{
	  $git_dir =~ s=([^/]+/+)\.git$=.git=;
	  $gfile = $1 . $gfile;
	  next;
	}
	if ($git_dir =~ m=^/=)
	{
	  undef $git_dir;
	  last git_dir;
	}

	$pwd = `pwd`;
	chomp $pwd;
	$git_dir = $pwd . "/$git_dir";
      }
      if ($git_dir)
      {
	$git_dir =~ m=(.*)/.git=;
	$d = "--git-dir=$git_dir --work-tree=$1";
	@glog = `git $d log --numstat --pretty=tformat:'date: %ai%n%s' -- $gfile`;
	@log = ();
	foreach $_ (@glog)
	{
	  if (/^date/)
	  {
	    $line = $_;
	    chomp $line;
	  }
	  elsif (!$msg)
	  {
	    $msg = $_;
	    chomp $msg;
	  }
	  elsif (!/^$/)	  {
	    s/([\d-]\d*)\s+([\d-]\d*).*/ lines: +$1 -$2/;
	    push @log, $line . $_;
	    push @log, $msg;
	    undef $msg
	  }
	}
      }
      elsif (-d ($dir . 'CVS'))
      {
	@log = `cvs log -N -r1.1: $ARGV`;
      }
      elsif (-f ($dir . 'RCS/' . $file . ',v') || -f ($ARGV . ',v'))
      {
	@log = `rlog -N -r1.1: $ARGV`;
      }
      # generate hash of significant years, ignoring small or marked changes
      %sigyears = ();
      foreach $_ (@log)
      {
	# extract year from log entry
	if (m=^date: (\d{4})=)
	{
	  $year = $1;
	  # ignore non-initial commits with < 10 inserted or deleted lines
	  undef $year if (m=lines: \+(\d+) \-(\d+)= && $1 < 10 && $2 < 10);
	  # always insert initial commit year, regardless of comments
	  $sigyears{$year} = 1 unless (m=lines:=);
	}
	elsif (defined($year))
	{
	  # ignore if first line of commit message has has "chcopy" or "trivial"
	  $sigyears{$year} = 1 unless (/(CHCOPY|[Tt]rivial)/);
	  undef $year;
	}
      }
      # convert list of years to comma-separated ranges (e.g. 2001,2003-2007)
      @years = sort(keys %sigyears);
      $YEARS = '';
      $i = 0;
      while ($i <= $#years)
      {
	if ($i == 0)
	{			# enter first year immediately
	  $YEARS = $lastyear = $years[$i];
	}
	elsif ($i == $#years)
	{			# for final entry in array, always enter year
	  if ($years[$i-1] + 1 == $years[$i])
	  {			# if final entry is previous + 1, collapse
	    if ($years[$i-1] == $lastyear)
	    {			# if previous was already entered, use comma
	      $YEARS .= ",$years[$i]";
	    }
	    else
	    {			# use range for multiple sequential years
	      $YEARS .= "-$years[$i]";
	    }
	  }
	  else
	  {			# if final entry not previous + 1, enter both
	    if ($lastyear + 1 == $years[$i-1])
	    {			# if previous == last entered + 1, use comma
	      $YEARS .= ",$years[$i-1]";
	    }
	    elsif ($lastyear != $years[$i-1])
	    {			# use range for multiple sequential years
	      $YEARS .= "-$years[$i-1]";
	    }
	    $YEARS .= ",$years[$i]";
	  }
	}
	elsif ($lastyear == $years[$i-1] && $lastyear + 1 != $years[$i])
	{			# intermediate entry; singleton or range start
	  $YEARS .= ",$years[$i]";
	  $lastyear = $years[$i];
	}
	elsif ($years[$i-1] + 1 != $years[$i])
	{			# intermediate entry; range end
	  $YEARS .= "-$years[$i-1],$years[$i]";
	  $lastyear = $years[$i];
	}
	$i++;
      }
    }
    $YEARS = 1900 + (localtime time)[5] if ($YEARS eq '');
  }

  # Header stuff
  # (Only try header stuff for first five lines)
  if ($. < 5 && /^$q1/)
  {
    $csymbol = chr(194) . chr(169); # UTF-8 encoding of © copyright symbol
    while (<>)
    {
      $csymbol = $1 if (/copyright ([^\s]{1,3}) \d{4}/i);
      $prod = 0 if ($prod < 0 && (/bk__/ || /libbk__/));
      $prod = 1 if ($prod < 0 && (/tcs__/ || /cs__/ || /sysd__/));
      if (/^$q2$/)
      {
	last;
      }
    }
    if ($prod)
    {
      $prod = 1;		# ignore inconsistent copyright below
      $hdr = $CSHDR;
    }
    else
    {
      $hdr = $BAKAHDR;
    }
    $hdr =~ s/YEARS/$YEARS/g;
    $hdr =~ s/\(c\)/$csymbol/g;
    print $hdr;
    next;
  }

  if (eof)
  {
    close(ARGV);
    undef $YEARS;
  }

  # Copyright
  if (/(.*)\+\+Copyright\ (.*)\+\+/)
  {
    $PREFIX=$1;
    $prod = 0 if ($prod < 0 && $2 =~ /(BAKA|LIBBK)/);
    $prod = 1 if ($prod < 0 && $2 =~ /(TRUSTEDCS|COUNTERSTORM|SYSDETECT)/);
    $csymbol = chr(194) . chr(169); # UTF-8 encoding of © copyright symbol
    while (<>)
    {
      $csymbol = $1 if (/copyright ([^\s]{1,3}) \d{4}/i);
      if (/\-\s?\-Copyright\ .*\-\s?\-/)
      {
	last;
      }
    }
    if ($prod)
    {
      $prod = $CSPROD;
    }
    else
    {
      $prod = $BAKAPROD;
    }
    $prod =~ s/YEARS/$YEARS/g;
    $prod =~ s/\(c\)/$csymbol/g;
    pprint($PREFIX,$prod);
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
