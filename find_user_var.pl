#!/usr/bin/perl
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
  # 					kill you too).
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
