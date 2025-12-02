#!/usr/bin/env/ perl
use strict;
use Env;

my $my_pwd = `pwd`;
chomp($my_pwd);

print("My current working directory is: $my_pwd\n");

my @tests;
my $test;

get_ofs_sim_test_list();

clear_test_info();

create_test_dirs();

copy_test_files();

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
   print (">>> Variant: $FIM_VARIANT_TARGET");

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
            # $dir_check = $my_pwd . "/tests/" . $test_name;
            $dir_check = $my_pwd . "/../../unit_test/" . $test_name;
            if (-d $dir_check) {
               print("    Test directory found: $dir_check\n");
               push(@tests,$test_name);
            } else {
               print STDERR ("    Test directory NOT found: $dir_check\n");
               print STDERR ("        Please fix subtest entry at line number[$line_number] in file: $test_list_file -- This entry will be skipped.\n");
               $tests_not_found_number++;
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

sub clear_test_info {
   my $test_dir = $my_pwd . "/tests";
   my @list_del_dirs;
   my $del_dir;
   print "\n";
   chdir $test_dir;
   print("Deleting Old Source Directories at: $test_dir\n");
   # print("Listing tests directory:\n");
   # system("ls -1d */");
   @list_del_dirs = `ls -1d */`;
   chomp @list_del_dirs;
   foreach $del_dir (@list_del_dirs) {
      $del_dir =~ s/(\w+)\/*/\1/;
      # print "DEL_DIR: $del_dir\n";
      # print("Command: rm -rf $del_dir\n");
      system("rm -rf $del_dir");
   }
   print("Deletion Completed...\n\n");
   chdir $my_pwd;
   # print("Listing scripts directory:\n");
   # system("ls -1");
}

sub create_test_dirs {
   my $test_dir = $my_pwd . "/tests";
   print "\n";
   chdir $test_dir;
   foreach $test (@tests) {
      print("Making directory: $test\n");
      system("mkdir $test");
   }
   print("Test Directories Created...\n");
   system("ls -1");
   chdir $my_pwd;
   # system("pwd");
   print("\n");
}

sub copy_test_files {
   my @file_list = ("transcript", "vcs.log", "vlog.log");
   my $regression_log_filename = "regression.log";
   my $regression_log = $my_pwd . "/../../unit_test/scripts/" . $regression_log_filename;
   my $target_file;
   my $file;
   my $destination_file;
   print "\n";
   foreach $test (@tests) {
      foreach $file (@file_list) {
         $target_file = $my_pwd . "/../../unit_test/" . $test . "/sim_vcs/" . $file;
         $destination_file = $my_pwd . "/tests/" . $test . "/" . $file;
         if (-e $target_file) {
            print("Target file: $target_file -- Found!\n");
            print("Destination: $destination_file\n");
            print("Copying...\n");
            system("cp $target_file $destination_file");
         } else {
            print STDERR ("FAILED>> Target file: $target_file -- NOT Found!\n");
         }
      }
      $target_file = $regression_log;
      $destination_file = $my_pwd . "/tests/" . $test . "/" . $regression_log_filename;
      if (-e $target_file) {
            print("Target file: $target_file -- Found!\n");
            print("Destination: $destination_file\n");
            print("Copying...\n");
            system("cp $target_file $destination_file");
      } else {
         print STDERR ("FAILED>> Target file: $target_file -- NOT Found!\n");
      }
   }
}

1;
