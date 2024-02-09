#!/usr/bin/perl
# Copyright (C) 2015 Intel Corporation
# SPDX-License-Identifier: MIT

# basic postsim to determin pass or fail of simulation and collect errors. 
# 

my @uvm_error;
my @uvm_error_filt;
my @uvm_fatal;
my $sim_fail;
my $test_killed = 0;
my $ab_file = `ls | grep abnormal`;
print $ab_file ;
chomp $ab_file;
my $test_killed = 1 if -e $ab_file;
print $test_killed ;
#my $log_file = "postsim.log";
my $log_file = $ARGV[0];
print "DEBUG: $log_file ***********************************\n";
open(LOGFILE,">$log_file"); 
    @uvm_error = `egrep "^UVM_ERROR" *log`;
    @uvm_fatal = `egrep "^UVM_FATAL" *log`;
    @rtl_fatal = `egrep "^Fatal:" *log`;
    @rtl_finish = `egrep '$finish called from.*[^/]rtl' *log`;    
    @rtl_error_a = `egrep '*** ERROR:' *log`;    
    $rtl_error = $rtl_error_a[0];
    $rtl_error =~ s/.*iofs_ac_test.log:...//;
    $rtl_error =~ s/^(.*:.*):([^:].*)$/$1$2/;
    $test_killed = $test_killed || !($uvm_error[0] || $uvm_fatal[0] || $rtl_finish[0]);
foreach my $err (@uvm_fatal) {
    if($err !~ /.*UVM_FATAL \:    0/){
        print LOGFILE "$err";
        $sim_fail = $err;
    } else {
        print LOGFILE "filtered: $err\n";
    }
}

foreach my $err (@uvm_error) {
    if($err !~ /.*UVM_ERROR \:    0/){
        print LOGFILE "$err";
        $sim_fail = $err;
    } else {
        print LOGFILE "filtered: $err\n";
    }
}

if($sim_fail) {
    print LOGFILE "TEST FAILED\n";
    die ("sim failed with $sim_fail look in postsim.log for more details ");
} elsif (@rtl_finish) {
    print LOGFILE "TEST FAILED\n";
    die ("sim failed with UVM_ERROR: RTL Called \$finish look in regression logs for more details ");
} elsif($rtl_fatal[0]) {
    print LOGFILE "TEST FAILED\n";
        print LOGFILE "UVM_ERROR : $rtl_fatal[0] \n";
       die ("Fatal RTL assertion\n");  
} elsif($rtl_error) {
    print LOGFILE "TEST FAILED\n";
        print LOGFILE "$rtl_error \n";
       die ("Fatal RTL assertion\n");  
} elsif($test_killed) {
    print LOGFILE "TEST FAILED\n";
        print LOGFILE "UVM_ERROR :  Test killed by NB time limit\n";
       die ("sim failed with UVM_ERROR:Test killed by NB time limit");  
} else {
    print LOGFILE "TEST PASSED\n";
    print "TEST PASSED\n";
    exit 0;
}



