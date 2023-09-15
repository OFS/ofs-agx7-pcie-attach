#!/usr/bin/env perl
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

use warnings;

use Cwd qw(abs_path);
use File::Basename;
use File::Spec;

#$mydir = `pwd`;
$mydir = "$ENV{VERDIR}/scripts";
chomp $mydir;
#local $ENV{PATH} = "$mydir:$ENV{PATH}";
$wdir = $ARGV[0];
$dir = "";
$rpt_dir = "/tmp/rpts";
chomp $rpt_dir;
mkdir $rpt_dir unless -d $rpt_dir;
chomp $wdir;
opendir (DIR,$wdir) or die "cannot open dir $!\n";
chdir $wdir;
while ($dir = readdir DIR){
    print "dir to work = $dir \n";
    chomp $dir;
    next if ($dir eq '.' or $dir eq '..' or $dir !~ /^i*ofs_|^soc_|^host_|eth_/ );
    next unless ( -d "$wdir/$dir");
    chdir $dir;
#    print "I am in"; 
#    `pwd`;
    system ("$mydir/postsim.pl $rpt_dir/$dir.log");
    system ("$mydir/make_rpt.pl");
    # `cat $dir/*.rpt >> $wdir/result.rpt` if (-d $dir);
    chdir $wdir;
    }
    closedir DIR;
    #system ("cat $wdir/*/*.rpt > $mydir/latest.rpt");
    system ("echo $wdir > $rpt_dir/head.txt");
    system ("git -C $wdir rev-parse HEAD >> $rpt_dir/head.txt");
    system ("cat $rpt_dir/*.rp > $rpt_dir/latest.rpt");
    system ("$mydir/lsti --seed $rpt_dir/latest.rpt > $rpt_dir/report.txt");
    #system ("cat $rpt_dir/*.rpt > $mydir/latest.rpt");
    # `cat $wdir/*/*.rpt > $mydir/latest.rpt`;

