#!/usr/bin/perl
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

#
# rename series of frames
#
if ($#ARGV != 0) {
    print "usage: One argument as input\n";
    exit;
}

$dir_name = $ARGV[0];
$new_dir = 0;
$i = 1;
$filename = $dir_name;
   # print "File Exists here! $filename";
#until($new_dir == 1){
while ($new_dir == 0){
 if (-e $filename) {
   # print "File Exists! $filename";
    $filename ="$dir_name.$i" ; 
    $new_dir = 0; 
    $i= $i +1 ;
 #print  $filename;
 }
  else {
    $new_dir = 1;  
 } 

 }
 print  $filename;



#variable: = <path of script>
#output: = $(shell $(echo))

