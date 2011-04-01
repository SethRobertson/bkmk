#!/usr/bin/perl -i.bak
=pod
=encoding utf8
=cut
#
#
# ++Copyright BAKA++
#
# Copyright © 2001-2011 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -
#
#
# <TODO>Should determine current branch and compute years from commits on that
# branch and on trunk before that branch (now always uses trunk commits).</TODO>
#
use bytes;
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
|static const char rtcs__copyright[] = "Copyright (c) YEARS Raytheon Trusted Computer Solutions, Inc.";
|static const char rtcs__contact[] = "Raytheon Trusted Computer Solutions, Inc. <cssupport@TrustedCS.com>";
|#endif /* not lint */
EOF

($CSPROD =  "++"."Copyright RTCS COMMERCIAL++\n".<<'EOF') =~ s/^\|//gm;
|
|Copyright (c) YEARS Raytheon Trusted Computer Solutions, Inc.
|All rights reserved.
|
|THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF RAYTHEON TRUSTED
|COMPUTER SOLUTIONS, INC.  The copyright notice above does not
|evidence any actual or intended publication of such source code.
|
|Only properly authorized employees and contractors of RAYTHEON
|TRUSTED COMPUTER SOLUTIONS, INC. are authorized to view, possess, or
|otherwise use this file.
|
|Raytheon Trusted Computer Solutions, Inc
|12950 Worldgate Drive
|Suite 600
|Herndon, VA  20170-6024
|
|+1 866 230 1307
|+1 703 318 7134
|<cssupport@trustedcs.com>
|
|- -Copyright RTCS COMMERCIAL- -
EOF

my($USAGE) = "Usage: $0: [OPTIONS] DETAIL-OPTIONS SYMBOL-OPTION FILES...
OPTIONS
 [-b|--use-baka-copyright|-c|--use-commercial-copyright]
 [--copyright-trivial-lines=NUMBER] [--disable-trivial-message-skip]
 [--keep-copyright-symbol] [--match-file-encoding]
DETAIL-OPTIONS
 --copyright-detailed |
 --copyright-range [--copyright-range-start=DATE] [--copyright-range-end=DATE]
SYMBOL-OPTION
 -a|--use-ascii-copyright-symbol |
 -l|--use-latin-copyright-symbol |
 -u|--use-utf8-copyright-symbol\n";
my(%OPTIONS);
$OPTIONS{'copyright-trivial-lines'}=5;

Getopt::Long::Configure("bundling", "no_ignore_case", "no_auto_abbrev", "no_getopt_compat", "require_order");
GetOptions(\%OPTIONS, 'copyright-detailed', 'copyright-range', 'copyright-range-end=s', 'copyright-range-start=s', 'b|use-baka-copyright', 'c|use-commercial-copyright', 'l|use-latin-copyright-symbol', 'u|use-utf8-copyright-symbol', 'a|use-ascii-copyright-symbol','match-file-encoding|encoding-super-copyright-win','keep-copyright-symbol|cur-copyright-symbol-wins','copyright-trivial-lines=i','disable-trivial-message-skip') || die $USAGE;

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

my ($csymbol);

# ASCII copyright symbol
my $asciicsymbol = "(c)";
# Latin-1 copyright symbol
my $latin1csymbol = chr(169);
# UTF-8 copyright symbol
my $utf8csymbol = chr(194) . chr(169);
my $csymbolre = "(?:".quotemeta($asciicsymbol)."|".quotemeta($latin1csymbol)."|".quotemeta($utf8csymbol).")";
my $CURCSYMBOL;

$csymbol = $asciicsymbol if ($OPTIONS{'a'});
$csymbol = $latin1csymbol if ($OPTIONS{'l'});
$csymbol = $utf8csymbol if ($OPTIONS{'u'});

die "Must select an ASCII, Latin-1, or UTF-8 copyright symbol\n\n$USAGE" unless ($csymbol);

die "Must select --copyright-detailed or --copyright-range\n\n$USAGE" unless ($OPTIONS{'copyright-detailed'} xor $OPTIONS{'copyright-range'});

# Restore backup file if we die
$SIG{__DIE__} = sub
{
  die @_ if $^S; # do nothing if die called within eval
  rename("$ARGV.bak", "$ARGV") if ($ARGV ne '-');
};


my ($last_ARGV) = $ARGV;
my ($prod_cpp) = $prod_override;
my ($prod_license) = $prod_override;
my ($YEARS,$OVERRIDE_CSYM,$override_csym_final);
my $pwd = `pwd`;
chomp $pwd;

while (<>)
{
  if ($ARGV ne $last_ARGV)
  {
    $prod_cpp = $prod_override;
    $prod_license = $prod_override;
    $last_ARGV = $ARGV;
    undef($YEARS);
    undef($OVERRIDE_CSYM);
    undef($override_csym_final);
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

	$git_dir = $pwd . "/$git_dir";
      }

      my $qgit_dir = $git_dir;
      $qgit_dir =~ s:/\.git$::;
      $qgit_dir = quotemeta($qgit_dir);
      if ($pwd =~ /^$qgit_dir/)
      {
	$gfile = $file;
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
      my ($year,$lastyear);
      foreach $_ (@log)
      {
	# extract year from log entry
	if (m=^date: (\d{4})=)
	{
	  $lastyear = $year = $1;
	  # ignore non-initial commits with < 5 inserted or deleted lines
	  undef $year if (m=lines: \+(\d+) \-(\d+)= && $1 < $OPTIONS{'copyright-trivial-lines'} && $2 < $OPTIONS{'copyright-trivial-lines'});
	  # always insert initial commit year, regardless of comments
	  $sigyears{$year} = 1 unless (m=lines:=);
	}
	elsif (defined($year))
	{
	  # ignore if first line of commit message has has "chcopy" or "trivial"
	  $sigyears{$year} = 1 unless (/CHCOPY/);
	  $sigyears{$year} = 1 unless ($OPTIONS{'disable-trivial-message-skip'} || /[Tt]rivial/);
	  undef $year;
	}
      }
      # Earliest year always goes in
      $sigyears{$lastyear} = 1;
      # convert list of years to comma-separated ranges (e.g. 2001,2003-2007)
      my @years = sort(keys %sigyears);
      $YEARS = '';
      if ($OPTIONS{'copyright-detailed'})
      {
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
      elsif ($OPTIONS{'copyright-range'})
      {
	my $startyear = $OPTIONS{'copyright-range-start'} || $years[0] || 1900 + (localtime time)[5];
	my $endyear = $OPTIONS{'copyright-range-end'} || $years[$#years] || 1900 + (localtime time)[5];
	if ($startyear eq $endyear)
	{
	  $YEARS=$startyear;
	}
	else
	{
	  $YEARS="$startyear-$endyear";
	}
      }
      else
      {
	die "Should have already died...copyright list";
      }
    }
    $YEARS = 1900 + (localtime time)[5] if ($YEARS eq '');
  }

  # Header stuff--encoding detection
  # (Only try header stuff for first five lines)
  if ($OPTIONS{'match-file-encoding'})
  {
    # <TODO>Recognize UTF-16 or UTF-32 Byte Order Mark (BOM) (note: this
    # requires not only changing the copyright symbol, but re-encoding all
    # replacement text into 16-bit coding.</TODO>

    if ($. == 1 && /^\357\273\277/) # UTF-8 BOM
    {
      $OVERRIDE_CSYM = $utf8csymbol;

      # HTML5 specifies that BOM overrides in-document character encoding;
      # http://www.w3.org/International/questions/qa-html-encoding-declarations
      # Perl auto-detects BOM, but it is rarely used as it conflicts with #!;
      # for a file that actually has a BOM, it trumps use pragmas and POD.
      # http://perldoc.perl.org/perlunicode.html#Important-Caveats
      $override_csym_final = 1;
    }
    # From http://www.iana.org/assignments/character-sets
    my $CHARACTER_SET_CLASS = '\w:.()-';
    # See also http://www.w3.org/International/tutorials/tutorial-char-enc/ and
    # http://www.w3.org/International/questions/qa-html-encoding-declarations
    if ($. < 40 && !$override_csym_final &&
	(
	 # X(HT)?ML: http://www.w3.org/International/O-charset
	 /\<\?xml [^>]*(?<= )encoding=[\'\"]?([$CHARACTER_SET_CLASS]+)/ ||
	 # X?HTML: http://blog.whatwg.org/the-road-to-html-5-character-encoding
	 /\<meta [^>]*\bcharset=["']?([$CHARACTER_SET_CLASS]+)/i ||
	 # CSS: http://www.w3.org/International/questions/qa-css-charset
	 /\@charset "([^\"]*)"/ ||
	 # Perl: http://perldoc.perl.org/utf8.html
	 /^\s*use\s+(utf8)\s*;/ ||
	 # Perl: http://perldoc.perl.org/encoding.html
	 /^\s*use\s+encoding\s+[\'\"]?([$CHARACTER_SET_CLASS]+)/ ||
	 # Perl (POD): http://perldoc.perl.org/perlpod.html#Command-Paragraph
	 /^\=encoding +([$CHARACTER_SET_CLASS]+)/ ||
	 # PostgreSQL: http://www.postgresql.org/docs/9.0/static/multibyte.html
	 /^\\encoding +(\w+)$/ ||
	 /^\s*set +client_encoding +(?:=|to) +\'(\w+)/i ||
	 # SQL: http://www.destructor.de/firebird/charsets.htm
	 /^\s*set +names +\'?(\w+)/i ||
	 # MySQL: http://dev.mysql.com/doc/refman/5.0/en/charset-connection.html
	 /^\s*set +character_set_client *= *\'?(\w+)/i ||
	 /^\s*set +character +set +\'?(\w+)/i ||
	 0 # linefeed fodder
	))
    {
      my ($encoding) = $1;

      # Perl use pragma takes precedence over POD =encoding
      $override_csym_final = 1 if (/^\s*use\s/);

      if ($encoding =~ /^utf-?8$/i)
      {
	$OVERRIDE_CSYM = $utf8csymbol;
      }
      elsif ($encoding =~ /^(iso[-_]?8859-([1789]|1[345])\b|latin[15789]|greek|hebrew|windows-1252)/i)
      {
	$OVERRIDE_CSYM = $latin1csymbol;
      }
      else
      {
	$OVERRIDE_CSYM = $asciicsymbol;
      }
    }
  }

  # Header stuff
  # (Only try header stuff for first five lines)
  if ($. < 5 && /^$q1/)
  {
    my ($hdr);
    while (<>)
    {
      if (/Copyright ($csymbolre) /)
      {
	$CURCSYMBOL = $1;
      }

      $prod_cpp = 1 if (!defined($prod_cpp) && (/bk__/ || /libbk__/));
      $prod_cpp = 2 if (!defined($prod_cpp) && (/rtcs__/ || /tcs__/ || /cs__/ || /sysd__/));
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
    if ($OPTIONS{'match-file-encoding'} && defined($OVERRIDE_CSYM))
    {
      $hdr =~ s/\(c\)/$OVERRIDE_CSYM/g;
    }
    elsif ($OPTIONS{'keep-copyright-symbol'} && defined($CURCSYMBOL))
    {
      $hdr =~ s/\(c\)/$CURCSYMBOL/g;
    }
    else
    {
      $hdr =~ s/\(c\)/$csymbol/g;
    }
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
    # Just in case the Copyright is the first line, and there is a BOM
    $PREFIX =~ s/^\357\273\277// if ($. == 1);
    $prod_license = 1 if (!defined($prod_license) && $TYPE =~ /(BAKA|LIBBK)/);
    $prod_license = 2 if (!defined($prod_license) && $TYPE =~ /(RTCS COMMERCIAL|TRUSTEDCS|TCS COMMERCIAL|COUNTERSTORM|SYSDETECT)/);
    undef($CURCSYMBOL);

    while (<>)
    {
      if (/Copyright ($csymbolre) /)
      {
	$CURCSYMBOL = $1;
      }

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
    if ($OPTIONS{'match-file-encoding'} && defined($OVERRIDE_CSYM))
    {
      $prod =~ s/\(c\)/$OVERRIDE_CSYM/g;
    }
    elsif ($OPTIONS{'keep-copyright-symbol'} && defined($CURCSYMBOL))
    {
      $prod =~ s/\(c\)/$CURCSYMBOL/g;
    }
    else
    {
      $prod =~ s/\(c\)/$csymbol/g;
    }
    pprint($PREFIX,$prod,$POSTFIX);
    next;
  }
  print;
}

print STDERR "When you commit use the word 'CHCOPY' in the first line of the commit message\n";


=pod

=head1 NAME

chcopy.pl - Update copyright notices in well formed source files

=head1 SYNOPSIS

chcopy.pl [OPTIONS] DETAIL-OPTIONS SYMBOL-OPTION FILES...

OPTIONS
 [-b|--use-baka-copyright | -c|--use-commercial-copyright]
 [--copyright-trivial-lines=NUMBER] [--disable-trivial-message-skip]
 [--keep-copyright-symbol] [--match-file-encoding]

DETAIL-OPTIONS
 --copyright-detailed |
 --copyright-range [--copyright-range-start=DATE]
  [--copyright-range-end=DATE]

SYMBOL-OPTION
 -a|--use-ascii-copyright-symbol |
 -l|--use-latin-copyright-symbol |
 -u|--use-utf8-copyright-symbol

=head1 OVERVIEW

chcopy.pl updates recognized copyright notices to the latest versions.
The text of the various license types it recognizes are listed
internally.  By default it substitutes the latest version of the same
license type currently present in the file, but if a
--use-TYPE-copyright option is given, it replaces the license with the
TYPE (baka, commercial, rtcs) license.  In addition to textual
(comment) copyright notices, it also substitutes C static variable
copyright notices if present.  (These notices are compiled into
executables for visible copyright notification in binary files.)

There is a regular expression which matches the copyright section.
The current form currently starts with ++<TYPE>++ and ends with
- -<TYPE>- - (the space between the - is for HTML/XML comment syntax
reasons).

The per-line prefix for the copyright section is automatically
determined based on the existing per-line prefix, so the current
comment syntax or indention style will be matched.

The previous version of the file (before any changes are made) is
saved with a .bak extension.

There are multiple theories for the proper style of copyright dates to
be used.  Some prefer to list only years (or ranges of years) when the
file actually changed (e.g. 2002,2005-2006,2010); this is selected by
--copyright-detailed.  Others prefer to date the copyright from the
year the file was born until it was last modified (e.g. 2002-2010);
this is selected by --copyright-range).  Still others prefer the end
date to be the current year (e.g. 2002-2011); this is selected by
--copyright-range --copyright-range-end=2011.  Some even want to
copyright the file before the file exists, to have the same copyright
for all files (e.g. 2001-2011); this is selected by --copyright-range
--copyright-range-start=2001 --copyright-range-end=2011.

There are also different opinions on what is required for a file to
have been modified in a given year.  For some, changes of only a few
lines don't count.  The default is that only changes inserting 5 or
more lines (or deleting 5 or more lines) count for computing
non-initial dates; use --copyright-trivial-lines=NUMBER to change this
threshold - setting it to zero will cause any change to be considered
non-trivial.  For others, changes explicitly marked as being trivial
(with the word "trivial" or "Trivial" in the commit message) do not
count.  This is also the default; use --disable-trivial-message-skip
to disable this.  Changes committed with CHCOPY (uppercase) in the
first line of the commit message (which you should always do when
committing changes made by this program) never count for computing
non-initial copyright dates.

Modification information is taken from the current source code
management system: RCS, CVS, and git are supported.

The final question on which many disagree on is the proper copyright
symbol to use.  While the common use of lowercase c in parentheses -
(c) - has no legal standing, it is also true that in many countries
(including the US since 1976) a copyright symbol is not required to
claim copyright.  Using the ASCII-only (c) has the advantage that it
is the same in all encodings, and will not generate errors or warnings
from compilers, parsers, or translators.  If you want a proper
copyright symbol - © - the actual bytes in a file will be different
depending on whether it is encoded with Latin-1 (ISO 8859-1) as <A9>,
or UTF-8 as <C2 A9>.  (Note that the <A9> representation also works
for 8859-7 (Greek), 8859-8 (Hebrew), 8859-9 (Latin-5), 8859-13
(Latin-7), 8859-14 (Latin-8), 8859-15 (Latin-9 aka Latin0), and even
Windows Code Page 1252.)  You must choose which symbol/encoding to
use, with --use-ascii-copyright-symbol, --use-latin-copyright-symbol,
or --use-utf8-copyright-symbol.

If you have problems with use of certain encodings in certain files,
you can also specify --keep-copyright-symbol to keep the current
encoding used in each file, or --match-file-encoding to look for a
UTF-8 BOM (byte order mark, <EF BB BF>), XML encoding tag
(<?xml...encoding="TYPE">), HTML meta tag (<meta
http-equiv="Content-Type" content="text/html; charset=TYPE">), Perl
POD encoding (\n=encoding TYPE), or Perl 'use' pragma (use encoding
"TYPE";) near the top to determine the proper encoding type and use
that (UTF-8 will use utf-8, compatible 8859-# will use latin, and
anything else present will force ascii).  If --keep-copyright-symbol
and --match-file-encoding are both specified, a recognized file
encpding will override the current copyright symbol.  Perl 'use'
pragmas will take precedence over POD =encoding if both are present.

When running this on a complex package where there are multiple
branches under active development, you must run this on the files
contained in each branch, being very careful to ensure that all
commits, merges, and other source code management (SCM) maintenance
has been completed before starting to make the copyright changes.  If
your SCM tracks merging (e.g. git), you should "fake" a merge
(e.g. git merge -s ours BRANCH) immediately after the copyright change
are committed, so that you can avoid tedidous and unnecessary conflict
resolution.

=head1 EXAMPLE

Before running these examples or variants thereof, you should request
a super-lock from all developers: have them commit and push all
changes and refrain from making other changes; failing to do so may
lead to unnecessary conflicts.

  # Update the 1.0 release branch copyrights (avoiding conflicts)
  git checkout master
  ## Get latest changes
  git pull --rebase
  ## Fully merge branch upstream, to avoid conflicts during copyright change
  git merge --no-ff 1.0-release-branch
  ## Check out branch in question
  git checkout 1.0-release-branch
  ## Actually update copyrights
  find . -type f | fgrep -v .git | xargs -d'\n' \
    chcopy.pl -u --keep-copyright-symbol --match-file-encoding \
      --copyright-range --copyright-trivial-lines=0
  ## Commit copyright change
  git commit -a -m "Update Copyrights via CHCOPY"
  ## Share changes with everyone
  git push
  ## Fake merge to prevent copyright change clashes
  git checkout master
  git merge --no-ff -s ours 1.0-release-branch
  ## Double check no changes were actually made
  git diff HEAD HEAD^

  # Update the master branch Copyrights
  git checkout master
  ## Check for outstanding changes
  git status
  ## Get latest changes
  git pull --rebase
  ## Actually update copyrights
  find . -type f | fgrep -v .git | xargs -d'\n' \
    chcopy.pl -u --keep-copyright-symbol --match-file-encoding \
      --copyright-range --copyright-trivial-lines=0
  ## Commit copyright change
  git commit -a -m "Update Copyrights via CHCOPY"
  git push


=head1 REQUIREMENTS

perl 5 (probably almost any version of perl 5)

RCS, CVS, or git source code management.

=head1 AUTHOR

Seth Robertson

=head1 COPYRIGHT

Copyright © 1997-2011 Seth Robertson.  License is similar to the GNU
Lesser General Public License version 2.1, see LICENSE.TXT for more
details.
