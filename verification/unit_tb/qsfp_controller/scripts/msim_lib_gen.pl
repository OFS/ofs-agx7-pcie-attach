#!/usr/bin/env perl
# Copyright (C) 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

use strict;
my $transcript   = $ARGV[0] ;
my $libs;
open my $info, $transcript or die "Could not open $transcript: $!";

while( my $line = <$info>)  {   
    if($line =~ m/vsim -voptargs/)
    {
       $libs = $line;
       last;
     }   
}
close $info;

$libs =~ s/# vsim.*"//;
$libs =~ s/\-L/\n$&/g;
open(FH,">","temp.f");
print FH "$libs";    
close FH;

open(my $FHW,">","temp1.f");
open(my $FHR,"<","temp.f");
while(<$FHR>)
{
  next if /^\s*$/;
  if($_ =~ m/bpf\.bpf/)
   {
      $_ =~ s/bpf\.bpf//g;
      
      print $FHW "$_";
   }
  else
  {
    print $FHW "$_";
  }  
}
close FHR;
close FHW;
system("rm -rf temp.f");
open(my $FHW,">","msim_lib.f");
open(my $FHR,"<","temp1.f");

while(<$FHR>)
{
    $_ =~ s/-L\ work_lib//g;
    $_ =~ s/-L\ uart uart.uart/-L uart/g;
    $_ =~ s/-L /-L \$QLIB_DIR\//g;
    print $FHW "$_";
}
system("rm -rf temp1.f");
close FHR;
close FHW;
