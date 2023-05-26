#!/usr/bin/perl -w
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

#
use Cwd qw(abs_path);
use File::Basename;
use File::Spec;
#            T E S T    R E P O R T   F I L E
###################################################
#         TEST NAME: verif/tests/soc_random_seq_lib_test:skipSVID+LEVEL0_SIM+sbBridgDIS+XPROP
#     TEST SIM-TOOL: acerun
#       TEST SOURCE: verif/tests/soc_random_seq_lib_test:skipSVID+LEVEL0_SIM+sbBridgDIS+XPROP
#       TEST STATUS: FAIL
#       TEST RESULT: Error: "/nfs/pdx/stod/stodc01n03bH/w.cfung.100/MODELS/cnlcc-cnls62-p0-16ww39a/subIP/clk/source/clk/rtl/common/dyclkgate_assert.sv", 289: soc_tb.soc.par_ccu.ccu_top_wrap.ccu_top.ccu_main.sbclk_slice.itcg.genblk10[27].agent_req_Known_Driven: at time 184321500000 fs
#     MODEL VERSION: /nfs/site/stod/stodc01n03bH/w.cfung.100/MODELS/cnlcc-cnls62-p0-16ww39a
#               DUT: soc
#         ACE MODEL: soc_rtl
#     TEST RES PATH: /nfs/site/disks/ddg.reset_pm.nobackup.001/granite/rpmv/cnlcc-cnls62-p0-16ww39a_XPROP/soc_random_seq_lib_test__skipSVID__LEVEL0_SIM__sbBridgDIS__XPROP
#              SEED: 61
#     TEST CMD-LINE: 11770906 verif/tests/soc_random_seq_lib_test:skipSVID+LEVEL0_SIM+sbBridgDIS+XPROP -ace -ace_args -mpp_run -mpp_run -mpp_run -ace_args- -dut soc -emu_fuses_override 1 -no_flex_check -noexist -seed 61
#       BUCKET NAME: SVA::SOC::SVA FATAL Error - Agent req should be known driven
#  PROJECT-STEPPING: cnls62-p0

my  $dir = `pwd`;
    $dir =~ s@.*/([^/]+).*$/@$1@;
    #$postsimlog = "postsim.log";
    #$postsimlog = "/nfs/sc/disks/swuser_work_vvrudome/work/reports/rpts/$dir.log";
    $postsimlog = "/tmp/rpts/$dir.log";
    $test_status = 'FAIL';
    #$report_file = "/nfs/sc/disks/swuser_work_vvrudome/work/reports/rpts/$dir.rpt";
    $report_file = "/tmp/rpts/$dir.rp";
    $abn_file = "$dir"."_regr.abnormal";
    $regression_log = "$dir"."_regr.log";
    $cci_trk = "cci_trk.out";
    $num_request_cci = `egrep "mdata =" $cci_trk | wc -l`;
    $bad_request_cci = $num_request_cci % 2;
    $nb_limit = 0;
    $rtl_fatal = 0;
print $dir, "\n";
print $ENV{SITE};
my $test_for_bucket = "";
my @crash_fault;
    @crash_fault = `egrep "Dumping VCS" $regression_log`;
my @rwb_conflict_fault;
# @rwb_conflict_fault = `egrep "RECURSIVE WB CONFLICT DETECTED" $regression_log`;
my @bfm_error;
my $bfm_error_0;
    @bfm_error = `egrep "ErrorReport" $regression_log`;
my @seed_string;
    @seed_string =`egrep "random seed =" *.log`;
my @r_seed_string;
    @r_seed_string =`egrep "random seed used:" *.log`;
my @ntb_seed_string;
    @ntb_seed_string =`egrep "ntb_random_seed=" *.log`;
    print "BFM ERROR : ", @bfm_error;
    print "BFM ERROR [0]: ", $bfm_error[0];
    #  chomp $bfm_error[0];
    #( $bfm_error_0 )= $bfm_error[0] =~ s/error/BUG/gi  if @bfm_error;
    $bfm_error_0 =  chomp ($bfm_error[0])  if @bfm_error;
    print "BFM ERROR_0: ", $bfm_error_0  if @bfm_error;




   @rtl_error_a = `egrep 'ERROR:' $postsimlog`;
   $rtl_error = $rtl_error_a[0];
   # $rtl_error =~ s/^.*runsim.log...://;
    print "RTL ERROR: ",$rtl_error, "\n";

if ($dir =~ /model_(\w+)_seed_\w+/) {$test_for_bucket = $1;}

print "TEST FOR BUCK $test_for_bucket \n";

print $report_file, "   DBG \n";
print $abn_file, "   DBG bnormal \n";
open (OUTPUT, ">$report_file") or die "Could not open $report_file : $!";
#&get_test_status();
&report();

close OUTPUT;
`chmod 0660 $report_file`;
sub get_test_status {
    open (my $fn1, '<', $postsimlog) or die "Could not open $postsimlog : $!";
    #      $faylure_string = <$fn>;
    while (<$fn1>){
        next if /^\s*$/;
        # chomp $abn_file;
        $test_status = 'PASS' if /TEST PASSED/;
        $test_status = 'FAIL' if /TEST FAILED/;
        $test_status = "RUNNING : probably PASS " if ((-e $abn_file) && $test_status eq 'PASS' && !@crash_fault);
        $test_status = "FAIL" if (-z $postsimlog);
        $test_status = "FAIL" if (@crash_fault);
        $test_status = "FAIL" if (@bfm_error);
        $test_status = "FAIL" if (@rwb_conflict_fault);
        $test_status = "FAIL" if ($bad_request_cci && !/TEST PASSED/);
        $nb_limit = 1 if /Test killed by NB/;
        $rtl_fatal = 1 if /Fatal:/;
    }
        close $fn1;
        return $test_status;
    }
sub failure_string {
    my $fp = ' N/A';
     open (my $buck, '<', $postsimlog) or die "Could not open $postsimlog : $!";
     while ($fp = <$buck>){
         next if $fp =~ /^\s*$/;
         next if $fp =~ /UVM_FATAL\s+:\s+0/;
         $fp = "$fp $test_for_bucket" if $fp =~ /TIMED OUT/;
         $fp = "UVM_ERROR: Number of CCI Req does not match Rsp" if ($bad_request_cci && (-e $abn_file));
         $fp = "UVM_ERROR: VCS crash" if (@crash_fault);
         $fp = "UVM_FATAL: ".$bfm_error_0 if (@bfm_error && !@rwb_conflict_fault);
         $fp = "UVM_ERROR: ".$rtl_error if ($rtl_error) ;
         $fp = "UVM_ERROR: WBF: HA_PC: RECURSIVE WB CONFLICT DETECTED" if (@rwb_conflict_fault);
         $fp = "UVM_ERROR: Fatal RTL assertion" if $fp =~ /^UVM_ERROR : .*:Fatal:/;
         $fp = "UVM_ERROR: Test killed by NB time limit" if $fp =~ /Test killed by NB/;
         #$fp = "UVM_FATAL: ".$bfm_error_0 if (@bfm_error);
         print "FP = $fp \n";
         return $fp if $fp =~ /\w+\.log:(UVM_ERROR|UVM_FATAL|.*VCS|BUGReport:|Fatal:)\s*/;

     }
}
sub report {
#    open (my $fn, '>', $report_file) or die "Could not open $report_file : $!";
#     open (my $buck, '<', $postsimlog) or die "Could not open $postsimlog : $!";
#     my $faylure_pat = <$buck>;
    my $faylure_pat = &failure_string();
    chomp $faylure_pat;
     print $faylure_pat,"\n";   ###### DBG
    my $test_name = "         TEST NAME: ".$dir;
    my $sim_tool = "     TEST SIM-TOOL: vcs";
    my $test_source = "       TEST SOURCE: ".$dir;
    my $status = "       TEST STATUS: ".&get_test_status();
    my $test_result = "       TEST RESULT: ".&failure2general($faylure_pat);
       $test_result = "       TEST RESULT: Bug reported by RTL" if (-z $postsimlog);
       $test_result = "       TEST RESULT: Number of CCI Req does not match Rsp" if ($bad_request_cci && (-e $abn_file)) ;
       $test_result = "       TEST RESULT: VCS Crush: $crash_fault[0]" if (@crash_fault) ;
       $test_result = "       TEST RESULT: WBF: $rwb_conflict_fault[0]" if (@rwb_conflict_fault) ;
       $test_result = "       TEST RESULT: ". $bfm_error_0 if (@bfm_error && !@rwb_conflict_fault) ;
       $test_result = "       TEST RESULT:  ".$rtl_error if ($rtl_error) ;
       $test_result = "       TEST RESULT:  ERROR: Fatal RTL assertion" if ($rtl_fatal) ;
       $test_result = "       TEST RESULT:  NO RESULT Probably Pass" if ($nb_limit) ;
    my $ver = "     MODEL VERSION: /nfs/pdx/disks/atp.09/users/vvrudome/exp/skpx-a0-ww37-2-eth";
    my $dut = "               DUT: soc";
    my $ace_model = "         ACE MODEL: soc_rtl";
    my $result_path = "     TEST RES PATH: ".`pwd`;
#    my $results_dir = "RESULTS DIR: ".`pwd`;
    my $mseed = 25;
    my $bseed = 25;
    my $nmseed = "";
       ($bseed,$mseed) = (0,0);
       ($bseed,$mseed) = $seed_string[0] =~ /(.*random seed = )(-*\w+)/ if ($seed_string[0] =~ /random seed = /);
       ($r_bseed,$r_mseed) = $r_seed_string[0] =~ /(.*random seed used: )(\w+)/ if ($r_seed_string[0] =~ /random seed used: /);
       ($n_mseed,$nmseed) = $ntb_seed_string[0] =~ /(.*ntb_random_seed=)(\w+)/ if ($ntb_seed_string[0] =~ /ntb_random_seed=/);
#    $mseed = 0 if (!defined $mseed);
    my $seed = "       SEED:   N/A";
       $seed = "       SEED: $mseed" if $mseed;
       $seed = "       SEED: $r_mseed" if $r_mseed;
       $seed = "       SEED: $nmseed" if $nmseed;
#    my $cycles = "CYCLES: 1";
    my $cmd_line = "     TEST CMD-LINE: TBD";
    my $bucket_name = "       BUCKET NAME: ".&failure2general($faylure_pat);
    $bucket_name = "       BUCKET NAME:  Probably Pass" if (-e $abn_file);
    $bucket_name = "       BUCKET NAME:  Bug reported by RTL" if (-z $postsimlog);
    $bucket_name = "       BUCKET NAME:  ERROR: VCS Crash" if (@crash_fault);
    $bucket_name = "       BUCKET NAME:  WBF ERROR: RECURSIVE WB CONFLICT DETECTED" if (@rwb_conflict_fault);
    $bucket_name = "       BUCKET NAME:  ERROR: ".$bfm_error_0 if (@bfm_error) ;
    $bucket_name = "       BUCKET NAME:  ERROR: ".$rtl_error if ($rtl_error) ;
    $bucket_name = "       BUCKET NAME:  NO Result Probably Pass" if ($nb_limit) ;
    print OUTPUT "            T E S T    R E P O R T   F I L E\n";
    print OUTPUT "##################################################\n";
    print OUTPUT $test_name,"\n";
    print OUTPUT  $sim_tool, "\n";
    print OUTPUT $test_source, "\n";
    print OUTPUT  $status, "\n";
    print OUTPUT $test_result, "\n";
#    print OUTPUT $results_dir;
    print OUTPUT $ver, "\n";
    print OUTPUT $dut, "\n";
    print OUTPUT $result_path;
    #print OUTPUT $seed, "\n";
    print OUTPUT $seed, "\n";
#    print OUTPUT $cycles, "\n";
    print OUTPUT $cmd_line, "\n";
    print OUTPUT $bucket_name, "\n";
    print "BUCKET NAME: ", $bucket_name, "\n";

    #   close $fn;
    #close $buck;

}
sub failure2general {
    my ($message) = @_;
    return $message  if $message =~ /ErrorReport/;
    $message =~ s/.*UVM_ERROR.*?\[/UVM_ERROR ::\[/;
    $message =~ s/.*UVM_FATAL.*?\[/UVM_FATAL ::\[/;

    $message =~ s/Model-Tool FAILED with exit status 1//;
    $message =~ s/::\d+:\s+/::/;
    $message =~ s/\d+\s*[munpf]s//;
    $message =~ s/\[\d+:\d*\]/\[x:x\]/g;
    $message =~ s/\[[\sa-fA-F\d]+\]/\[<see log>\]/g;
    $message =~ s/Actual value.*Expected value.*/actual and expected value do not match/i;
    $message =~ s/Read data.*Data written.*/Read and written data do not match/i;
    $message =~ s/\[\]//;
    $message =~ s/Expected completion data.*did not match with Received xaction data.*/Expected completion data did not match with Received xaction data/;
    $message =~ s/\s*-\s*expected.*,\s*actual.*//i;
    $message =~ s/:\s*expected.*actual.*//i;
    $message =~ s/\([xa-fA-F\d]+\)//g;
    $message =~ s/0x[a-fA-F\d]+/<see log>/gi;
    $message =~ s/to \d+$//;
    $message =~ s/\d+\'h[a-fA-F\d]+/<see log>/g;
    $message =~ s/'\{['h,a-fA-F\d ]+}/<see log>/g;
    $message =~ s/[a-fA-F\d]{8,}/<see log>/g;
    $message =~ s/=[\.a-fA-F\d]+([, ]|$)/=<see log>$1/g;
    $message =~ s/: [\.a-fA-F\d]+([, ]|$)/ <see log>$1/g;

    #Devon and Paymon bucket clean up
    $message =~ s/PEG\d+/PCIE_X/gi;
    $message =~ s/ DMI/ PCIE_X/gi;
    $message =~ s/num lanes \d+/num lanes <see log>/gi;
    $message =~ s/\s+at time :\s+//gi;
    $message =~ s/AFE_RX_SERDES_JITTER_ASSERTX/AFE_RX_SERDES_JITTER_ASSERT/g;
    #$message =~ s/error://ig; # Why we had this? - vvrudome
    $message =~ s/^\s+//;
    # Clean up extra spaces and digits and errors keep these at the end
    #$message =~ s/Error//i;
    $message =~ s/\s+/ /g;
    $message =~ s/::\s+/::/g;
    $message =~ s/\s+$//;
    $message =~ s/\(\d+ nsec\)/(X nsec)/;
    $message =~ s/\sEID \d+/ EID X/;
    $message =~ s/ clock cycles = -\d+\.\d+/ clock cycles = X/;
    $message =~ s/=0\.\d+/=X/;
    $message =~ s/\+CYCLE_LIMIT_US = \d+/+CYCLE_LIMIT_US = X/;
    $message =~ s/rtl:Ie\S+ sim:I.\S+/rtl:X sim:X/;
    $message =~ s/\d+\s*\[[munpf]s\]/<see log>/;
    $message =~ s/ expected \d+/ expected <see log>/;
    $message =~ s/=-0.\d+/=<see log>/;
    $message =~ s/Read:\d+, Expected:\d+\+-\d+/Read:<see log>, Expected:<see log>/;
    $message =~ s/^:://;
    $message =~ s/mdata = \S+ id = \S+/mdata = <see log> id = <see log>/;
    $message =~ s/mdata = \w+/mdata = <see log>/;
	return $message;
}

