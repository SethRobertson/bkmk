#! /bin/bash --norc
#! /bin/ksh -p
######################################################################
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
#
# Get installation home directory using $0; for use by other programs, this
# will use $1 (containing an copy of the other program's $0) if present.
# If the $0 path is relative, it will be resolved relative to the current
# directory; if it is wholly unqualified (neither relative nor absolute), a
# PATH search for $0 will be performed (and resulting relative paths will be
# resolved relative to the current directory, as above).  If the last component
# of the resulting path is */bin, the /bin component will be trimmed.
#
# This script sources the getcwd script (which should be installed in the same
# directory as this script) to get getcwd() and pawd() functions; the getcwd
# function is used to resolve relative pathnames, and the pawd function is used
# to perform automounter normalization on the final path.
#
# Handles directories with whitespace (other than newline) in name.
#
# This file can also be sourced ". gethome.sh" into ksh/bash scripts, which
# will define a gethome() function that performs the operation of this script.
#
typeset -f getcwd > /dev/null || {
  typeset name path spath
  # need to source getcwd; prepend dirs of $1, $0, $_ (set by ksh) to PATH
  path=$PATH
  for spath in "$0" "$1" "$_"
  do
    case "$spath" in
      /*|*/*) path=${spath%/*}:$path ;;
    esac
  done
  PATH=$path . getcwd.sh || {
    # failsafe in case we cannot source getcwd
    getcwd() { pwd; }
    pawd() { echo "$1"; }
  }
}

name=gethome
gethome() {
  typeset prog IFS pdir cwd hdir

  prog=${1-$0}

  # PATH search for unqualified $0
  case "$prog" in
    /*|*/*) : ;;		# qualified path
    *)
    IFS=':'
    for pdir in $PATH		# unqualified, search PATH
    do
      unset IFS
      pdir=${pdir:-.}		# empty PATH component == .
      if [ -x "$pdir/$prog" ]; then
	prog=$pdir/$prog
	break
      fi
      pdir=
    done
    unset IFS
    if [ -z "$pdir" ]; then	# not found, use . (better than nothing)
      prog=./$prog
    fi
    ;;
  esac

  # getcwd for relative $0
  case "$prog" in
    /*) : ;;			# absolute path
    ./*) cwd=`getcwd`; prog=$cwd/"${prog#./}" ;;
    *) cwd=`getcwd`; prog=$cwd/$prog ;;
  esac

  hdir=${prog%/*}

  # strip trailing /bin (dealing with ../bin specially)
  case "$hdir" in
    /../bin) hdir=/ ;;
    $PWD/../bin|$cwd/../bin) hdir=${hdir%/*/../bin} ;;
    /bin) hdir=/ ;;
    */bin) hdir="${hdir%/bin}" ;;
  esac

  echo `pawd "$hdir"`
}

# only do anything if this script is run rather than sourced
case "$0" in
  $name|$name.sh|*/$name|*/$name.sh) $name ;;
esac

unset name
