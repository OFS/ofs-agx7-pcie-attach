#!/usr/bin/env/ perl
use strict;

use RegTest;

my $my_pwd = `pwd`;
chomp($my_pwd);

print("My current working directory is: $my_pwd\n");

my $pass = 1;

my @tests;
my $test;
my $subtest;
my $sim_cmd = "sim_subtest.pl";

get_ofs_sim_test_list();

foreach $test (@tests) {
   $subtest = $test . "_subtest";
   reg_add_subtest (
   'reg-subtest-rel-name' => $subtest,
   'reg-cmd' => $sim_cmd,
   'variation_name' => $test);
}

if ($pass) {
   reg_put_to_reg_rout("Test passed!");
   print("The test has PASSED!\n");
} else {
   reg_put_to_reg_rout("Test failed!");
   print("The test has FAILED!\n");
   print SDTERR ("The test has FAILED! 2\n");
}

print("\n\n");

sub get_ofs_sim_test_list {
   my $test_list_file = "test_list";
   my $line;
   my $dir_check;
   my $duplicate_found;
   my $test_name;
   my $line_number = 0;
   my $test_number = 0;
   my $duplicate_test_number = 0;
   my $tests_not_found_number = 0;
   my $skipped_test_number = 0;
   print ("\n\n");  # Give a little space in the information for readability.
   print(">>> Scanning test list file: $test_list_file...\n");
   open(TESTLIST,$test_list_file) || die "Cannot open file: $test_list_file -- $!";
   while($line = <TESTLIST>) {
      chomp($line);
      $line_number++;
      if ($line =~ /^\s*TESTNAME=(\S+)/) {
         $test_name = $1;
         print("    Test Entry Found --->TESTNAME=$test_name\n");
         $duplicate_found = 0;
         foreach $test (@tests) {
            if ($test eq $test_name) {
               $duplicate_found = 1;
               print("       Skipping duplicate entry of <$test_name> in file: $test_list_file -- line [$line_number]\n");
               $duplicate_test_number++;
               last;
            }
         }
         if (!$duplicate_found) {
            $dir_check = $my_pwd . "/tests/" . $test_name;
            if (-d $dir_check) {
               print("    Test directory found: $dir_check\n");
               push(@tests,$test_name);
            } else {
               print STDERR ("    Test directory NOT found: $dir_check\n");
               print STDERR ("        Please fix subtest entry at line number[$line_number] in file: $test_list_file -- This entry will be skipped.\n");
               $tests_not_found_number++;
               # $pass = 0;
            }
         }
      }
   }
   print ("\n");  # Give a little space in the information for readability.
   $test_number = scalar @tests;
   $skipped_test_number = $duplicate_test_number + $tests_not_found_number;
   print(">>> Found [$test_number] unique tests to run in [$line_number] lines from setup file: $test_list_file\n");
   print("    Duplicate Test Entries Found....: [$duplicate_test_number]\n");
   print("    Test Entry Directories Not Found: [$tests_not_found_number]\n");
   print("    Total Test Entries Skipped......: [$skipped_test_number]\n");
   print("    Total Test Entries Being Run....: [$test_number]\n\n");
   close(TESTLIST);
}

1;
