#!/usr/bin/perl -i.bak
#
#
# ++Copyright LIBBK++
#
# Copyright © 2001-2003,2006-2008 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
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
use strict;
use warnings;
no warnings "uninitialized";
use Getopt::Long;




sub pprint($$$)
{
  my ($prefix,$string,$postfix) = @_;
  my (@lines);
  my ($output);

  @lines = split(/\n/,$string);
  $output = sprintf("%s",$prefix.join("$postfix\n$prefix",@lines)."$postfix\n");
  $output =~ s/[ \t]+$//mg;
  print $output;
}




my ($BAKAHDR,$BAKAPROD,$CSHDR,$CSPROD);

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
|static const char tcs__contact[] = "TCS Commercial, Inc. <cssupport@TrustedCS.com>";
|#endif /* not lint */
EOF

($CSPROD =  "++"."Copyright TCS COMMERCIAL++\n".<<'EOF') =~ s/^\|//gm;
|
|Copyright (c) YEARS TCS Commercial, Inc.
|All rights reserved.
|
|THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF TCS COMMERCIAL, INC.
|The copyright notice above does not evidence any actual or intended
|publication of such source code.
|
|Only properly authorized employees and contractors of TCS COMMERCIAL,
|INC. are authorized to view, possess, or otherwise use this file.
|
|TCS Commercial, Inc
|2350 Corporate Park Drive
|Suite 500
|Herndon, VA  20171-4848
|
|+1 866 230 1307
|+1 703 318 7134
|<cssupport@trustedcs.com>
|
|- -Copyright TCS COMMERCIAL- -
EOF

my($USAGE) = "Usage: $0: [--use-baka-copyright|b] [--use-commercial-copyright|c] [--use-latin-copyright-symbol|l] [--use-utf8-copyright-symbol|u] <files>...\n";
my(%OPTIONS);
Getopt::Long::Configure("bundling", "no_ignore_case", "no_auto_abbrev", "no_getopt_compat", "require_order");
GetOptions(\%OPTIONS, 'b|use-baka-copyright', 'c|use-commercial-copyright', 'l|use-latin-copyright-symbol', 'u|use-utf8-copyright-symbol') || die $USAGE;

my ($prod_override);
if ($OPTIONS{'b'})
{
  $prod_override = 1;
}
if ($OPTIONS{'c'})
{
  $prod_override = 2;
}

my $q1 = '\#if \!defined\(lint\)';
my $q2 = '\#endif \/\* not lint \*\/';

# ASCII copyright symbol
my $csymbol = "(c)";
# Latin-1 copyright symbol
$csymbol = chr(169) if ($OPTIONS{'l'});
# UTF-8 copyright symbol
$csymbol = chr(194) . chr(169) if ($OPTIONS{'u'});

my ($last_ARGV) = $ARGV;
my ($prod_cpp) = $prod_override;
my ($prod_license) = $prod_override;
my ($YEARS);

while (<>)
{
  if ($ARGV ne $last_ARGV)
  {
    $prod_cpp = $prod_override;
    $prod_license = $prod_override;
    $last_ARGV = $ARGV;
    undef($YEARS);
  }

  if (!defined($YEARS))
  {
    my @log = ();
    if ($ARGV ne '-')
    {
      $ARGV =~ m=(.*/)?(.*)=;
      my $dir = $1;
      my $file = $2;
      my $git_dir = $dir . '.git';
      my $gfile = $file;
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

	my $pwd = `pwd`;
	chomp $pwd;
	$git_dir = $pwd . "/$git_dir";
      }
      if ($git_dir)
      {
	$git_dir =~ m=(.*)/.git=;
	my $d = "--git-dir=$git_dir --work-tree=$1";
	my @glog = `git $d log --numstat --pretty=tformat:'date: %ai%n%s' -- $gfile`;
	my ($line,$msg);
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
      my %sigyears = ();
      my ($year);
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
      my @years = sort(keys %sigyears);
      $YEARS = '';
      my ($lastyear);
      my $i = 0;
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
    my ($hdr);
    while (<>)
    {
      $prod_cpp = 1 if (!defined($prod_cpp) && (/bk__/ || /libbk__/));
      $prod_cpp = 2 if (!defined($prod_cpp) && (/tcs__/ || /cs__/ || /sysd__/));
      if (/^$q2$/)
      {
	last;
      }
    }
    die "Did not find terminator $q2 in $ARGV\n" unless (/^$q2$/);
    if ($prod_cpp == 2)
    {
      $hdr = $CSHDR;
    }
    elsif ($prod_cpp == 1)
    {
      $hdr = $BAKAHDR;
    }
    else
    {
      die "Unknown cpp-style copyright in $ARGV";
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
  if (/(.*)\+\+Copyright\ (.*)\+\+(.*)/)
  {
    my $PREFIX=$1;
    my $POSTFIX=$3;
    my $TYPE=$2;
    $prod_license = 1 if (!defined($prod_license) && $TYPE =~ /(BAKA|LIBBK)/);
    $prod_license = 2 if (!defined($prod_license) && $TYPE =~ /(TRUSTEDCS|TCS COMMERCIAL|COUNTERSTORM|SYSDETECT)/);

    while (<>)
    {
      if (/\-\s?\-Copyright\ .*\-\s?\-/)
      {
	last;
      }
    }
    die "Did not find terminator --"."Copyright $TYPE-- in $ARGV" unless (/\-\s?\-Copyright\ .*\-\s?\-/);

    my ($prod);
    if ($prod_license == 2)
    {
      $prod = $CSPROD;
    }
    elsif ($prod_license == 1)
    {
      $prod = $BAKAPROD;
    }
    else
    {
      die "Unknown ++"."Copyright $TYPE++ style license";
    }

    $prod =~ s/YEARS/$YEARS/g;
    $prod =~ s/\(c\)/$csymbol/g;
    pprint($PREFIX,$prod,$POSTFIX);
    next;
  }
  print;
}

print STDERR "When you commit use the word 'CHCOPY' in the first line of the commit message\n";
