#!/usr/bin/env/ perl
use strict;

my $my_pwd = `pwd`;
chomp($my_pwd);

print("My current working directory is: $my_pwd\n");

my @tests;
my $test;
my @sim_tests;

get_ofs_sim_test_list();

create_sim_test_list();

create_sim_test_file();

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
   my $fim_variant_target_name = 'FIM_VARIANT_TARGET';

   print ("\n\n");  # Give a little space in the information for readability.
   if (exists $ENV{$fim_variant_target_name} && defined $ENV{$fim_variant_target_name}) {
      print (">>> Variant: $ENV{$fim_variant_target_name}\n");
   } else {
      print (">>> Variant: NOT SPECIFIED.\n");
      print ("             Creating Unit Test List directly from file: $test_list_file.\n");
   }
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

sub create_sim_test_list {
   my $prefix = "./";
   my $postfix = "/set_params.sh";
   my $top_sim_dir = $my_pwd . "/../../unit_test";
   my $test_dir;
   my $test_file;
   my $sim_test_entry;
   print("\n");
   print(">>> Adding Files to Simulation List from RegTest List...\n");
   foreach $test (@tests) {
      $test_dir = $top_sim_dir . "/" . $test;
      $test_file = $test_dir . $postfix;
      $sim_test_entry = $prefix . $test . $postfix;
      if (-e $test_file) {
         print("    Test Verified: $test_file\n");
         push(@sim_tests,$sim_test_entry);
      } else {
         print STDERR("   ERROR: Test $test_file NOT FOUND!\n");
      }
   }
   print "Done Creating Simulation Test List.\n";
   print "\n";
}

sub create_sim_test_file {
   my $top_sim_dir = $my_pwd . "/../../unit_test";
   my $sim_test_file = $top_sim_dir . "/list.txt";
   print("\n");
   print(">>> Creating Simulation Test File from RegTest List...\n");
   open(SIMLIST, '>', $sim_test_file) || die "Cannot open file: $!";
   foreach $test (@sim_tests) {
      print SIMLIST "$test\n";
   }
   print("    Simulation Test File Created...\n");
   close(SIMLIST);
   print("\n");
}

1;
