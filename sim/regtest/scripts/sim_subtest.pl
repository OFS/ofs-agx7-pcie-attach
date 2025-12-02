#!/usr/bin/env/ perl
use strict;

use RegTest;

my $my_pwd = `pwd`;
chomp($my_pwd);
my $regression_log_filename = "regression.log";
my $transcript_filename = "transcript";
# my $transcript_filename = "trnscript";  # Testing Error Condition
my $vcs_log_filename = "vcs.log";
my $vcs_comp_filename = "vlog.log";
my $line;
my @lines;
my $extracted_variation_name = "";
my $tail_line_number = 300;


reg_get_options (
   'variation_name=s' => \$extracted_variation_name
);

print "\n\n";
print ">>> Variation Name: $extracted_variation_name\n";
print "\n\n";
my $test_name = $extracted_variation_name;
my $path = $my_pwd . "/tests/" . $test_name . "/";
# my $regression_log = $my_pwd . "/../../unit_test/scripts/" . $regression_log_filename;
my $regression_log = $path . $regression_log_filename;
my $transcript = $path . $transcript_filename;
my $vcs_log = $path . $vcs_log_filename;
my $vcs_comp = $path . $vcs_comp_filename;

print("My current working directory is: $my_pwd\n");
print("   Path..........: $path\n");
print("   Regression Log: $regression_log\n");
print("   Transcript....: $transcript\n");
print("   VCS Log.......: $vcs_log\n");
print("   VCS Comp......: $vcs_comp\n\n");

my $pass = 0;
my $regression_run;
my $simulation_run;
my $vcs_log_found;
my $vcs_comp_found;

if (-e $regression_log) {
   print("Found regression log at: $regression_log\n");
   $regression_run = 1;
} else {
   print STDERR ("Was not able to find regression log at: $regression_log\n\n");
   $regression_run = 0;
}

if (-e $transcript) {
   print("Found transcript at: $transcript\n");
   $simulation_run = 1;
} else {
   print STDERR ("Was not able to find transcript at: $transcript\n\n");
   $simulation_run = 0;
}

if (-e $vcs_log) {
   print("Found VCS Log at: $vcs_log\n");
   $vcs_log_found = 1;
} else {
   print STDERR ("Was not able to find VCS Log at: $vcs_log\n\n");
   $vcs_log_found = 0;
}

if (-e $vcs_comp) {
   print("Found VCS Comp at: $vcs_comp\n");
   $vcs_comp_found = 1;
} else {
   print STDERR ("Was not able to find VCS Comp at: $vcs_comp\n\n");
   $vcs_comp_found = 0;
}


my $tail_command = "tail -n $tail_line_number $transcript";
if ($simulation_run) {
   @lines = `$tail_command`;
   chomp @lines;
   foreach $line (@lines) {
      if ($line =~ /^\s*Test passed!/) {
         $pass = 1;
      } 
   }
}

if ($pass) {
   reg_put_to_reg_rout("Test passed!");
   print("The test has PASSED!\n");
} else {
   reg_put_to_reg_rout("Test failed!");
   print STDERR ("The test has FAILED!\n");
   if (!$simulation_run) {
      print STDERR ("   It appears the test was not run or the compilaton failed.  No transcript found.\n");
   }
}

if ($regression_run) {
   open(my $fh, "<", $regression_log) || die "Cannot open Regression Log file: $regression_log -- $!";
   print("\n\n");
   print("BEGIN >>> Printing out Regression log:$regression_log\n");
   print("==================================================>\n");
   while(my $line = <$fh>) {
      print $line;
   }
   close($fh);
   print("==================================================>\n");
   print("END >>> Printing out Regression log:$regression_log\n");
   print("\n\n");
}


if ($simulation_run) {
   print("\n\n");
   print("BEGIN >>> Printing out transcript tail capture of <$tail_line_number> lines:\n");
   print("==================================================>\n");
   foreach $line (@lines) {
      print("$line\n");
   }
   print("==================================================>\n");
   print("END >>> Printing out transcript tail capture of <$tail_line_number> lines:\n");
} else {
   if ($vcs_comp_found) {
      open(my $fh, "<", $vcs_comp) || die "Cannot open VCS Comp file: $vcs_comp -- $!";
      print("\n\n");
      print("BEGIN >>> Printing out VCS Compilation log:$vcs_comp\n");
      print("==================================================>\n");
      while(my $line = <$fh>) {
         print $line;
      }
      close($fh);
      print("==================================================>\n");
      print("END >>> Printing out VCS Compilation log:$vcs_comp\n");
      print("\n\n");
   }
   if ($vcs_log_found) {
      open(my $fh, "<", $vcs_log) || die "Cannot open VCS Log file: $vcs_log -- $!";
      print("\n\n");
      print("BEGIN >>> Printing out VCS SIMV Build log:$vcs_log\n");
      print("==================================================>\n");
      while(my $line = <$fh>) {
         print $line;
      }
      close($fh);
      print("==================================================>\n");
      print("END >>> Printing out VCS SIMV Build log:$vcs_log\n");
      print("\n\n");
   }
}

1;
