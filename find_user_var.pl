#!/bin/perl
$topdir_inode=(stat("$ARGV[0]"))[1]; 
$last_inode=0;
$done=0; 
while (!$done)
{ 
  chomp($pwd=`$ARGV[1]`); 
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
