#!/usr/bin/env python3
# Copyright (C) 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

import argparse
import subprocess
import logging
import multiprocessing
import time
import datetime
import re
import os
import sys
import smtplib
import textwrap
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class Test:

    test_count = 0
    test_count_pass = 0
    test_count_fail = 0

    def __init__(self, name, directory, num_uvm_error, num_uvm_fatal, uvm_pass, uvm_seed, time_elapsed):
        self.name = name
        self.dir  = directory
        self.uvm_error = num_uvm_error
        self.uvm_fatal = num_uvm_fatal
        self.uvm_pass = uvm_pass
        self.seed = uvm_seed
        self.time_elapsed = time_elapsed
        Test.test_count += 1
        if uvm_pass:
            Test.test_count_pass += 1
        else:
            Test.test_count_fail += 1

    def get_name(self):
        return self.name

    def set_directory(self,directory):
        self.dir = directory

    def get_directory(self):
        return self.dir

    def set_uvm_error(self,error_num):
        self.uvm_error = error_num

    def get_uvm_error(self):
        return self.uvm_error

    def set_uvm_fatal(self,fatal_num):
        self.uvm_fatal = fatal_num

    def get_uvm_fatal(self):
        return self.uvm_fatal

    def set_uvm_pass(self,pass_val):
        if self.uvm_pass ^ pass_val:
            if pass_val:
                Test.test_count_pass += 1
                Test.test_count_fail -= 1
            else:
                Test.test_count_pass -= 1
                Test.test_count_fail += 1
        self.uvm_pass = pass_val

    def uvm_test_passed(self):
        if not self.uvm_pass:
            Test.test_count_pass += 1
            Test.test_count_fail -= 1
        self.uvm_pass = True

    def uvm_test_failed(self):
        if self.uvm_pass:
            Test.test_count_pass -= 1
            Test.test_count_fail += 1
        self.uvm_pass = False

    def get_uvm_pass(self):
        return self.uvm_pass

    def get_test_count(self):
        return Test.test_count

    def get_test_count_passed(self):
        return Test.test_count_pass

    def get_test_count_failed(self):
        return Test.test_count_fail

    def set_seed(self,seed_val):
        self.seed = seed_val

    def get_seed(self):
        return self.seed

    def set_time_elapsed(self,delta):
        self.time_elapsed = delta

    def get_time_elapsed(self):
        return self.time_elapsed

    def print(self):
        logger.info(f"Test Object name........: {self.name}")
        logger.info(f"            dir.........: {self.dir}")
        logger.info(f"            uvm_error...: {self.uvm_error}")
        logger.info(f"            uvm_fatal...: {self.uvm_fatal}")
        logger.info(f"            uvm_pass....: {self.uvm_pass}")
        logger.info(f"            seed........: {self.seed}")
        logger.info(f"            time_elapsed: {self.time_elapsed}")


class FarmTest(Test):

    def __init__(self, name, directory, num_uvm_error, num_uvm_fatal, uvm_pass, uvm_seed, test_info):
        super().__init__(name, directory, num_uvm_error, num_uvm_fatal, uvm_pass, uvm_seed, test_info[0])
        self.arc_job_id = test_info[1]
        self.arc_job_status = test_info[2]
        self.arc_job_host_name = test_info[3]
        self.arc_job_return_code = test_info[4]

    def get_arc_job(self):
        return self.arc_job_id

    def get_arc_job_status(self):
        return self.arc_job_status

    def get_arc_job_host_name(self):
        return self.arc_job_host_name

    def get_arc_job_return_code(self):
        return self.arc_job_return_code

    def print(self):
        logger.info(f"Farm Test Object name...............: {self.name}")
        logger.info(f"                 dir................: {self.dir}")
        logger.info(f"                 uvm_error..........: {self.uvm_error}")
        logger.info(f"                 uvm_fatal..........: {self.uvm_fatal}")
        logger.info(f"                 uvm_pass...........: {self.uvm_pass}")
        logger.info(f"                 seed...............: {self.seed}")
        logger.info(f"                 time_elapsed.......: {self.time_elapsed}")
        logger.info(f"                 arc_job_id.........: {self.arc_job_id}")
        logger.info(f"                 arc_job_status.....: {self.arc_job_status}")
        logger.info(f"                 arc_job_host_name..: {self.arc_job_host_name}")
        logger.info(f"                 arc_job_return_code: {self.arc_job_return_code}")


def check_nfs():
    df_cmd_line = r'df -P -T .'
    logger.debug(f"NFS: Commands follow:")
    logger.debug(f"   df: {df_cmd_line}")
    check_nfs_pattern = r'\S+\s+(\w+)'
    fs = 'None'
    df_cmd   = subprocess.Popen(df_cmd_line.split(), stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with df_cmd.stdout:
        for line in iter(df_cmd.stdout.readline, ""):
            logger.debug(f"NFS: Line Check: {line}")
            line_contains_pattern = re.search(check_nfs_pattern, line)
            if (line_contains_pattern):
                fs = line_contains_pattern.group(1)
    df_cmd.wait()
    command_success = df_cmd.poll()
    logger.debug(f"NFS: Command Success = {command_success}")
    logger.debug(f"NFS: Returning FS... = {fs}")
    return fs


def get_rootdir():
    rootdir = os.getenv('OFS_ROOTDIR')
    if rootdir is not None:
        if os.path.exists(rootdir):
            logger.debug(f"OFS root directory is set in shell and has value: {rootdir}.")
        else:
            logger.error(f"ERROR: OFS root directory variable $OFS_ROOTDIR is set to a location that does not exist:{rootdir}")
            logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
            sys.exit(1)
    else:
        logger.error(f"ERROR: OFS root directory variable $OFS_ROOTDIR is not set in this shell.")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    return rootdir

def get_email_list():
    email_list = os.getenv('EMAIL_LIST')
    if email_list is not None:
        if os.path.exists(email_list):
            logger.info(f"Email list path set in shell and has value: {email_list}")
        else:
            logger.error(f"ERROR: OFS root directory variable $email_list is set to a location that does not exist:{email_list}")
            sys.exit(1)
    else:
        logger.error(f"ERROR: OFS root directory variable $email_list is not set in this shell.")
        sys.exit(1)
    return email_list
            


def get_last_commit():
    commit_pattern_found = 0
    commit = ""
    commit_pattern = r'commit\s*(\w+)'
    commit_cmd = subprocess.Popen(['git', 'log', '-n', '1'], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with commit_cmd.stdout:
        for line in iter(commit_cmd.stdout.readline, ""):
            line_contains_pattern = re.search(commit_pattern, line)
            if (line_contains_pattern):
                commit = line_contains_pattern.group(1)
                commit_pattern_found = 1
    commit_cmd.wait()
    command_success = commit_cmd.poll()
    if (command_success == 0):
        if (commit_pattern_found):
            logger.debug(f"Git repo last commit search has returned successfully with return value {command_success}.")
            logger.debug(f"Git repo last commit is: {commit}.")
        else:
            logger.error(f"ERROR: Git repo last commit could not be found.") 
            logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
            sys.exit(1)
    else:
        logger.error(f"ERROR: Git Log command has failed.")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    return commit


def create_test_list(top_list_of_tests):
    uvm_test_pattern = r'^\s+`include\s+"(\w+\.svh)"'
    base_test_to_be_skipped = r'base_test.svh'
    working_test_list = []
    tests_to_remove = []
    fully_unrolled = 0
    layer_count = 1
    try:
        with open(top_list_of_tests) as file_object:
            for line in file_object:
               test_found = re.search(uvm_test_pattern,line)
               if (test_found):
                   if (test_found.group(1) != base_test_to_be_skipped):
                       working_test_list.append(test_found.group(1))
                       logger.debug(f"Top Test Found: {test_found.group(1)}")
    except FileNotFoundError:
        logger.error(f"ERROR: Top test file not found: {top_list_of_tests}")
        sys.exit(1)

    while not fully_unrolled:
        embedded_list_of_tests_found = 0
        fully_unrolled = 1
        for test in working_test_list:
            test_full_path = test_dir + "/" + test
            logger.debug(f"Test: {test} Full Test Path: {test_full_path}")
            try:
                with open(test_full_path) as file_object:
                    for line in file_object:
                        test_found = re.search(uvm_test_pattern,line)
                        if (test_found):
                            if (test_found.group(1) != base_test_to_be_skipped):
                                logger.debug(f"FOUND: test - {test_found.group(1)} in the file - {test}")
                                working_test_list.append(test_found.group(1))
                                if test not in tests_to_remove:
                                    tests_to_remove.append(test)
                                embedded_list_of_tests_found = 1
            except FileNotFoundError:
                logger.debug(f"WARNING: Test {test} was not found and skipped with path: {test_full_path}")
                tests_to_remove.append(test)
        if embedded_list_of_tests_found:
            fully_unrolled = 0
            layer_count += 1
            for test in tests_to_remove:
                logger.debug(f"Removing test: {test}")
                working_test_list.remove(test)
            tests_to_remove.clear()
    logger.debug(f"Number of test layers found....: {layer_count}")
    logger.debug(f"Number of tests found to run...: {len(working_test_list)}")
    for test in working_test_list:
        logger.debug(f"    {test}")
    return working_test_list


def check_positive_process_count(processes):
    uint = int(processes)
    if uint <= 0:
        raise argparse.ArgumentTypeError(f"Number of processes: {uint} is not a positive integer.")
    return uint


def set_top_list_of_tests(package):
        if (package == 'test_pkg'):
           top_list_of_tests = rootdir + "/verification/unit_tb/copy_engine/tests/test_pkg.svh"
        return top_list_of_tests

def set_make_dir():
    make_dir = rootdir + "/verification/unit_tb/copy_engine/scripts"
    if os.path.exists(make_dir):
        logger.debug(f"      UVM make directory found....:{make_dir}")
    else:
        logger.error(f"ERROR: UVM make directory not found at:{make_dir}.  Please check your repo/environment to continue.")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    return make_dir


def send_email_report():
    #------------------------------------------------------------
    # Get User Info for e-mail 
    #------------------------------------------------------------
    whoami_pattern = r'(^\w+)'
    finger_pattern   = r'Name:\s*(\S+)'
    whoami_command = subprocess.Popen(['whoami'], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with whoami_command.stdout:
        for line in iter(whoami_command.stdout.readline, ""):
            line_contains_name = re.search(whoami_pattern, line)
            if (line_contains_name):
                user_name = line_contains_name.group(1)
    whoami_command.wait()
    whoami_success = whoami_command.poll()
    if (whoami_success == 0):
        logger.debug(f"Found User Name: {user_name}")
        finger_command = subprocess.Popen(['finger', user_name], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
        with finger_command.stdout:
            for line in iter(finger_command.stdout.readline, ""):
                line_contains_full_name = re.search(finger_pattern, line)
                if (line_contains_full_name):
                    user_full_name = line_contains_full_name.group(1)
        finger_command.wait()
        finger_success = finger_command.poll()
        if (finger_success == 0):
            logger.debug(f"Found Full User Name: {user_full_name}")
        else:
            logger.debug(f"WARNING: User Name Not Found.  Setting name to 'user' and full name to 'user.name'.")
            user_full_name = "user.name"
    else:
        logger.debug(f"WARNING: User Name Not Found.  Setting name to 'user' and full name to 'user.name'.")
        user_name = "user"
        user_full_name = "user.name"
    full_name_split = user_full_name.split(".")
    full_name_split_caps = [name.capitalize() for name in full_name_split]
    full_name_caps = " ".join(full_name_split_caps)
    logger.debug(f"Capitalized Name....: {full_name_caps}")

    #------------------------------------------------------------
    # UVM Test Case Data Header
    #------------------------------------------------------------
    html_data = '''
        <html xmlns:v="urn:schemas-microsoft-com:vml"
        xmlns:o="urn:schemas-microsoft-com:office:office"
        xmlns:w="urn:schemas-microsoft-com:office:word"
        xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
        xmlns="http://www.w3.org/TR/REC-html40">

        <head>
        <meta http-equiv=Content-Type content="text/html; charset=windows-1252">
        <meta name=ProgId content=Word.Document>
        <meta name=Generator content="Microsoft Word 15">
        <meta name=Originator content="Microsoft Word 15">
        <link rel=File-List href="uvm_email_page_basic_files/filelist.xml">
        <link rel=dataStoreItem href="uvm_email_page_basic_files/item0006.xml"
        target="uvm_email_page_basic_files/props007.xml">
        <link rel=themeData href="uvm_email_page_basic_files/themedata.thmx">
        <style>
        <!--
         /* Font Definitions */
         @font-face
            {font-family:"Cambria Math";
            panose-1:2 4 5 3 5 4 6 3 2 4;
            mso-font-charset:0;
            mso-generic-font-family:roman;
            mso-font-pitch:variable;
            mso-font-signature:3 0 0 0 1 0;}
        @font-face
            {font-family:Calibri;
            panose-1:2 15 5 2 2 2 4 3 2 4;
            mso-font-charset:0;
            mso-generic-font-family:swiss;
            mso-font-pitch:variable;
            mso-font-signature:-469750017 -1073732485 9 0 511 0;}
        @font-face
            {font-family:Consolas;
            panose-1:2 11 6 9 2 2 4 3 2 4;
            mso-font-charset:0;
            mso-generic-font-family:modern;
            mso-font-pitch:fixed;
            mso-font-signature:-536869121 64767 1 0 415 0;}
         /* Style Definitions */
         p.MsoNormal, li.MsoNormal, div.MsoNormal
            {mso-style-unhide:no;
            mso-style-qformat:yes;
            mso-style-parent:"";
            margin-top:0in;
            margin-right:0in;
            margin-bottom:8.0pt;
            margin-left:0in;
            line-height:105%;
            mso-pagination:widow-orphan;
            font-size:11.0pt;
            font-family:"Calibri",sans-serif;
            mso-ascii-font-family:Calibri;
            mso-ascii-theme-font:minor-latin;
            mso-fareast-font-family:Calibri;
            mso-fareast-theme-font:minor-latin;
            mso-hansi-font-family:Calibri;
            mso-hansi-theme-font:minor-latin;
            mso-bidi-font-family:"Times New Roman";
            mso-bidi-theme-font:minor-bidi;}
        p.msonormal0, li.msonormal0, div.msonormal0
            {mso-style-name:msonormal;
            mso-style-unhide:no;
            mso-margin-top-alt:auto;
            margin-right:0in;
            mso-margin-bottom-alt:auto;
            margin-left:0in;
            mso-pagination:widow-orphan;
            font-size:12.0pt;
            font-family:"Times New Roman",serif;
            mso-fareast-font-family:"Times New Roman";
            mso-fareast-theme-font:minor-fareast;}
        .MsoChpDefault
            {mso-style-type:export-only;
            mso-default-props:yes;
            font-size:10.0pt;
            mso-ansi-font-size:10.0pt;
            mso-bidi-font-size:10.0pt;
            font-family:"Calibri",sans-serif;
            mso-ascii-font-family:Calibri;
            mso-ascii-theme-font:minor-latin;
            mso-fareast-font-family:Calibri;
            mso-fareast-theme-font:minor-latin;
            mso-hansi-font-family:Calibri;
            mso-hansi-theme-font:minor-latin;
            mso-bidi-font-family:"Times New Roman";
            mso-bidi-theme-font:minor-bidi;}
        @page WordSection1
            {size:8.5in 11.0in;
            margin:1.0in 1.0in 1.0in 1.0in;
            mso-header-margin:.5in;
            mso-footer-margin:.5in;
            mso-paper-source:0;}
        div.WordSection1
            {page:WordSection1;}
        -->
        </style>
        </head>

        <body bgcolor="#272727" lang=EN-US style='tab-interval:.5in;word-wrap:break-word'>

        <div class=WordSection1> '''
    #------------------------------------------------------------
    # UVM E-mail body text messages.
    #------------------------------------------------------------
    html_body_text_header = '''
        <p class=MsoNormal><span style='font-family:Consolas;color:white;mso-themecolor: background1'>'''
    html_body_text_error_header = '''
        <p class=MsoNormal><span style='font-family:Consolas;color:rgb(255, 80, 80)'> '''
    html_body_text_ender = "<o:p></o:p></span></p>"
    html_body_text_ender = "<o:p></o:p></span></p>"
    html_data += html_body_text_header
    html_data += f">>> Running UVM Regression Run Python Script: {os.path.basename(__file__)}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Simulator used for run..................: {args.simulator}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Begin running at date/time..............: {regression_run_start}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Regression run by user..................: {user_name} --> {full_name_caps}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Git Repo Root Directory is..............: {rootdir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Git Repo Last Commit is.................: {git_commit}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Script Location is......................: {script_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Current Working Directory is............: {current_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Top list of tests found.................: {top_list_of_tests}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Test Directory..........................: {test_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Number of UVM tests run.................: {test_results[-1].get_test_count()}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Number of UVM tests passing.............: {test_results[-1].get_test_count_passed()}"
    html_data += html_body_text_ender
    html_data += html_body_text_error_header
    html_data += f"    Number of UVM tests failing.............: {test_results[-1].get_test_count_failed()}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    End UVM regression running at date/time.: {regression_run_end}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Elapsed time for UVM regression run.....: {regression_run_elapsed}"
    html_data += html_body_text_ender

    #------------------------------------------------------------
    # UVM Table Data Column Headers
    #------------------------------------------------------------
    html_data += '''
        <table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
         style='border-collapse:collapse;border:none;mso-border-alt:solid #9CC2E5 .5pt;
         mso-border-themecolor:accent5;mso-border-themetint:153;mso-yfti-tbllook:1184;
         mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #9CC2E5;
         mso-border-insideh-themecolor:accent5;mso-border-insideh-themetint:153;
         mso-border-insidev:.5pt solid #9CC2E5;mso-border-insidev-themecolor:accent5;
         mso-border-insidev-themetint:153'>
         <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
          <td width=335 valign=top style='width:251.6pt;border:solid #9CC2E5 1.0pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;mso-border-alt:solid #9CC2E5 .5pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;background:#0070C0;
          padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal align=center style='margin-bottom:0in;text-align:center;
          line-height:normal'><b><span style='font-family:Consolas;color:black;
          mso-themecolor:text1'>UVM Test Case</span></b><b><span style='font-family:
          Consolas'><o:p></o:p></span></b></p>
          </td>
          <td width=114 valign=top style='width:85.5pt;border:solid #9CC2E5 1.0pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;border-left:none;
          mso-border-left-alt:solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;
          mso-border-left-themetint:153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:
          accent5;mso-border-themetint:153;background:#0070C0;padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal align=center style='margin-bottom:0in;text-align:center;
          line-height:normal'><b><span style='font-family:Consolas;color:black;
          mso-color-alt:windowtext'>Seed Value</span></b><b><span style='font-family:
          Consolas'><o:p></o:p></span></b></p>
          </td>
          <td width=126 valign=top style='width:94.5pt;border:solid #9CC2E5 1.0pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;border-left:none;
          mso-border-left-alt:solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;
          mso-border-left-themetint:153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:
          accent5;mso-border-themetint:153;background:#0070C0;padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal align=center style='margin-bottom:0in;text-align:center;
          line-height:normal'><b><span style='font-family:Consolas;color:black;
          mso-color-alt:windowtext'>Run Time</span></b><b><span style='font-family:
          Consolas'><o:p></o:p></span></b></p>
          </td>
          <td width=126 valign=top style='width:94.5pt;border:solid #9CC2E5 1.0pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;border-left:none;
          mso-border-left-alt:solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;
          mso-border-left-themetint:153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:
          accent5;mso-border-themetint:153;background:#0070C0;padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal align=center style='margin-bottom:0in;text-align:center;
          line-height:normal'><b><span style='font-family:Consolas;color:black;
          mso-color-alt:windowtext'>Status</span></b><b><span style='font-family:Consolas'><o:p></o:p></span></b></p>
          </td>
         </tr>'''
    row = 1
    for test_object in test_results:
        test_name = test_object.get_name()
        test_seed = test_object.get_seed()
        test_time = test_object.get_time_elapsed()
        test_pass = test_object.get_uvm_pass()
        if (test_pass):
            test_pass_str = "PASSED"
            font_color = "rgb(256, 256, 256)"
        else:
            test_pass_str = "FAILED"
            font_color = "rgb(255, 80, 80)"
        #------------------------------------------------------------
        # UVM Test Case Table Cell
        #------------------------------------------------------------
        html_data += "<tr style='mso-yfti-irow:"
        html_data += f"{row}"
        html_data += "'>"
        #------------------------------------------------------------
        # Table Cell #1
        #------------------------------------------------------------
        html_data += """
          <td width=335 valign=top style='width:251.6pt;border:solid #9CC2E5 1.0pt;
          mso-border-themecolor:accent5;mso-border-themetint:153;border-top:none;
          mso-border-top-alt:solid #9CC2E5 .5pt;mso-border-top-themecolor:accent5;
          mso-border-top-themetint:153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:
          accent5;mso-border-themetint:153;padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal style='margin-bottom:0in;line-height:normal'><span 
          style='font-family:Consolas;color:"""
        html_data += f"{font_color}'>"
        html_data += f"{test_name}"
        html_data += """<o:p></o:p></span></p>
            </td>"""
        #------------------------------------------------------------
        # Table Cell #2
        #------------------------------------------------------------
        html_data += """
            <td width=114 valign=top style='width:85.5pt;border-top:none;border-left:
            none;border-bottom:solid #9CC2E5 1.0pt;mso-border-bottom-themecolor:accent5;
            mso-border-bottom-themetint:153;border-right:solid #9CC2E5 1.0pt;mso-border-right-themecolor:
            accent5;mso-border-right-themetint:153;mso-border-top-alt:solid #9CC2E5 .5pt;
            mso-border-top-themecolor:accent5;mso-border-top-themetint:153;mso-border-left-alt:
            solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;mso-border-left-themetint:
            153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:accent5;
            mso-border-themetint:153;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-bottom:0in;line-height:normal'><span
            style='font-family:Consolas;color:"""
        html_data += f"{font_color}'>"
        html_data += f"{test_seed}"
        html_data += """<o:p></o:p></span></p>
                </td>"""
        #------------------------------------------------------------
        # Table Cell #3
        #------------------------------------------------------------
        html_data += """
        <td width=126 valign=top style='width:94.5pt;border-top:none;border-left:
          none;border-bottom:solid #9CC2E5 1.0pt;mso-border-bottom-themecolor:accent5;
          mso-border-bottom-themetint:153;border-right:solid #9CC2E5 1.0pt;mso-border-right-themecolor:
          accent5;mso-border-right-themetint:153;mso-border-top-alt:solid #9CC2E5 .5pt;
          mso-border-top-themecolor:accent5;mso-border-top-themetint:153;mso-border-left-alt:
          solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;mso-border-left-themetint:
          153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:accent5;
          mso-border-themetint:153;padding:0in 5.4pt 0in 5.4pt'>
          <p class=MsoNormal align=right style='margin-bottom:0in;text-align:right;
          line-height:normal'><span style='font-family:Consolas;color:"""
        html_data += f"{font_color}'>"
        html_data += f"{test_time}"
        html_data += """<o:p></o:p></span></p>
                </td>"""
        #------------------------------------------------------------
        # Table Cell #4
        #------------------------------------------------------------
        html_data += """
            <td width=126 valign=top style='width:94.5pt;border-top:none;border-left:
            none;border-bottom:solid #9CC2E5 1.0pt;mso-border-bottom-themecolor:accent5;
            mso-border-bottom-themetint:153;border-right:solid #9CC2E5 1.0pt;mso-border-right-themecolor:
            accent5;mso-border-right-themetint:153;mso-border-top-alt:solid #9CC2E5 .5pt;
            mso-border-top-themecolor:accent5;mso-border-top-themetint:153;mso-border-left-alt:
            solid #9CC2E5 .5pt;mso-border-left-themecolor:accent5;mso-border-left-themetint:
            153;mso-border-alt:solid #9CC2E5 .5pt;mso-border-themecolor:accent5;
            mso-border-themetint:153;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal align=center style='margin-bottom:0in;text-align:center;
            line-height:normal'><span style='font-family:Consolas;color:"""
        html_data += f"{font_color}'>"
        html_data += f"{test_pass_str}"
        html_data += """<o:p></o:p></span></p>
                </td>
             </tr>"""
        row += 1
    html_data += """
        </table>
        <p class=MsoNormal><span style='font-family:Consolas'><o:p>&nbsp;</o:p></span></p>
        </div>
        </body>
        </html>"""
    #------------------------------------------------------------
    # Email set-up and sending
    #------------------------------------------------------------
    server = smtplib.SMTP('localhost')
    sender_email = user_name
    if args.email_list:
        read_file = email_list + "/email_list.f"
        my_file = open(read_file, "r")
        # reading the file
        data = my_file.read()
        # replacing end splitting the text 
        # when newline ('\n') is seen.
        mail_into_list = data.split("\n")
        my_file.close()
        print(mail_into_list)
        receiver_email = mail_into_list;
    else:
        receiver_email = user_name

    message = MIMEMultipart()
    if(args.fims=='n6000_100G'):
        platform = "N6000-100G"
    elif(args.fims=='n6000_25G'):
        platform = "N6000-25G"
    elif(args.fims=='n6000_10G'):
        platform = "N6000-10G"
    else:
        platform = "N6001"
    message["Subject"] = f"[{platform}] UVM Regression results for COPY ENGINE - Tool:{args.simulator}"
    message["From"] = sender_email
    if args.email_list:
        message["To"]   = ", ".join(receiver_email)
    else:
        message["To"]   = receiver_email
    email_body = MIMEText(html_data,"html")
    message.attach(email_body)
    server.sendmail(sender_email, receiver_email, message.as_string())
    logger.info(f"Report Email sent to user:{user_name} --> {full_name_caps}")
    server.quit()


def scan_test_results(test_list,working_dir):
    working_dir_list = working_dir.split("/")
    logger.debug(f"SCAN: working_dir_list: {working_dir_list}")
    working_dir_list.pop()
    sim_dir = "/".join(working_dir_list) + "/sim"
    logger.debug(f"SCAN: sim_dir: {sim_dir}")
    test_name_pattern = r'(\w+)\.svh'
    uvm_error_pattern = r'^UVM_ERROR\s*:\s*(\d+)'
    uvm_fatal_pattern = r'^UVM_FATAL\s*:\s*(\d+)'
    uvm_seed_pattern  = r'(random seed used:\s*|random seed =\s*)(\d+)'
    for test in test_list:
        test_name_valid = re.search(test_name_pattern, test)
        uvm_error_found = False
        uvm_fatal_found = False
        uvm_seed_found  = False
        uvm_time_found  = False
        num_uvm_error = None
        num_uvm_fatal = None
        uvm_seed      = None
        uvm_time      = datetime.timedelta(seconds = 0)
        if (test_name_valid):
            test_name = test_name_valid.group(1)
            runsim_dir = sim_dir + "/" + test_name
            runsim_log = runsim_dir + "/" + "runsim.log"
            if (os.path.exists(runsim_log)):
                try:
                    with open(runsim_log) as file_object:
                        for line in file_object:
                            uvm_error_pattern_found = re.search(uvm_error_pattern,line)
                            uvm_fatal_pattern_found = re.search(uvm_fatal_pattern,line)
                            uvm_seed_pattern_found  = re.search(uvm_seed_pattern,line)
                            if (uvm_error_pattern_found):
                                num_uvm_error = uvm_error_pattern_found.group(1)
                                uvm_error_found = True
                                logger.debug(f"SCAN: UVM Error found: {num_uvm_error}")
                            if (uvm_fatal_pattern_found):
                                num_uvm_fatal = uvm_fatal_pattern_found.group(1)
                                uvm_fatal_found = True
                                logger.debug(f"SCAN: UVM Fatal found: {num_uvm_fatal}")
                            if (uvm_seed_pattern_found):
                                uvm_seed = uvm_seed_pattern_found.group(2)
                                uvm_seed_found = True
                                logger.debug(f"SCAN: UVM Seed found: {uvm_seed}")
                    if (uvm_error_found and (num_uvm_error == "0") and uvm_fatal_found and (num_uvm_fatal == "0")):
                        uvm_test_pass = True
                        logger.debug(f"SCAN: Success!  UVM Simulation test:{test_name} ran without errors.")
                    else:
                        uvm_test_pass = False
                        logger.debug(f"SCAN: Failure!  UVM Simulation test:{test_name} ran with errors.")
                    logger.debug(f"      uvm_error_found: {uvm_error_found}")
                    logger.debug(f"      num_uvm_error..: {num_uvm_error}")
                    logger.debug(f"      uvm_fatal_found: {uvm_fatal_found}")
                    logger.debug(f"      num_uvm_fatal..: {num_uvm_fatal}")
                    logger.debug(f"      uvm_seed_found.: {uvm_seed_found}")
                    logger.debug(f"      uvm_seed.......: {uvm_seed}")
                    if test_name in test_times_dict:
                        logger.debug(f"      uvm test time..: {test_times_dict[test_name]}")
                    else:
                        logger.debug(f"      uvm test time..: None")
                    if args.run_regression_locally :
                        test_result_object = Test(test_name, runsim_dir, num_uvm_error, num_uvm_fatal, uvm_test_pass, uvm_seed, test_times_dict[test_name])
                    else:
                        test_result_object = FarmTest(test_name, runsim_dir, num_uvm_error, num_uvm_fatal, uvm_test_pass, uvm_seed, test_info_dict[test_name])
                    test_results.append(test_result_object)
                except FileNotFoundError:
                    logger.debug(f"WARNING: Simulation Log for test {test_name}: {runsim_log} was not found.")
            else:
                logger.debug(f"WARNING: Simulations Log File: {runsim_log} was not found.")


def build_sim_env(platform, coverage, simulator,fims):
    logger.info(f">>> Beginning UVM Library Build.")
    logger.info(f"    Coverage....: {coverage}")
    logger.info(f"    Simulator...: {simulator}")
    env_start = datetime.datetime.now()
    logger.info(f"    Started.....: {env_start}")
    makefile = "Makefile_" + simulator.upper() + '.mk'
    cmplib = "cmplib_" + platform
    build  = "build_"  + platform
    if(fims=='n6000_100G'):
        fim = "n6000_100G=1"
    elif(fims=='n6000_25G'):
        fim = "n6000_25G=1"
    elif(fims=='n6000_10G'):
        fim = "n6000_10G=1"
    else:
        fim = ""
       
    clean_command_line = f"gmake -f {makefile} clean"
    if (coverage == 'ral_cov'):
        if (simulator == 'vcs'):
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim} COV=1"
            build_command_line  = f"gmake -f {makefile} {build} {fim} DEBUG=1 COV=1"
        else:
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim} COV=1 MSIM=1"
            build_command_line  = f"gmake -f {makefile} {build} {fim} COV=1 MSIM=1"
    elif (coverage == 'fun_cov'):
        if (simulator == 'vcs'):
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim} COV_FUNCTIONAL=1"
            build_command_line  = f"gmake -f {makefile} {build} {fim} DEBUG=1 COV_FUNCTIONAL=1"
        else:
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim} COV_FUNCTIONAL=1 MSIM=1"
            build_command_line  = f"gmake -f {makefile} {build} {fim} COV_FUNCTIONAL=1 MSIM=1"
    else:
        if (simulator == 'vcs'):
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim}"
            build_command_line  = f"gmake -f {makefile} {build} {fim} DEBUG=1"
        else:
            cmplib_command_line = f"gmake -f {makefile} {cmplib} {fim} MSIM=1"
            build_command_line  = f"gmake -f {makefile} {build} {fim} MSIM=1"
    logger.debug(f"DEBUG: Raw cmplib command line list: {cmplib_command_line}")
    logger.debug(f"DEBUG: Raw build command line list: {build_command_line}")
    logger.info(f"Running Make Clean: {clean_command_line} ...")
    clean_cmd = subprocess.Popen(clean_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    clean_cmd.wait()
    clean_cmd_success = clean_cmd.poll()
    if (clean_cmd_success == 0):
        logger.info(f"Make Clean Command was successful.")
    else:
        logger.error(f"ERROR: Make Clean Command was not successful")
        sys.exit(1)
    logger.info(f"Running Make Library Compile: {cmplib_command_line} ...")
    cmplib_cmd = subprocess.Popen(cmplib_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    cmplib_cmd.wait()
    cmplib_cmd_success = cmplib_cmd.poll()
    if (cmplib_cmd_success == 0):
        logger.info(f"Make Library Compile Command was successful.")
    else:
        logger.error(f"ERROR: Make Library Compile Command was not successful")
        sys.exit(1)
    logger.info(f"Running Make Library Build: {build_command_line} ...")
    build_cmd = subprocess.Popen(build_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    build_cmd.wait()
    build_cmd_success = build_cmd.poll()
    if (build_cmd_success == 0):
        logger.info(f"Make Build Command was successful.")
    else:
        logger.error(f"ERROR: Make Build Command was not successful")
        sys.exit(1)
    env_end = datetime.datetime.now()
    time_elapsed = env_end - env_start
    logger.info(f"    Ended.......: {env_end}")
    logger.info(f"    Time Elapsed: {time_elapsed}")
    logger.info(f">>> UVM Library Build Complete.")

def print_results():
    failing_tests = []
    failing_lines = []
    passing_tests = []
    passing_lines = []
    longest_line = 0
    longest_name = 0
    for test in test_results:
        if test.get_uvm_pass():
            passing_tests.append(test)
            test_name = test.get_name() + ":"
            if len(test_name) > longest_name:
                longest_name = len(test_name)
        else:
            failing_tests.append(test)
            test_name = test.get_name() + ":"
            if len(test_name) > longest_name:
                longest_name = len(test_name)
    total_tests = len(passing_tests) + len(failing_tests)
    length_index_field = len(str(total_tests))
    fail_count_field = f"{len(failing_tests):>{length_index_field}}/{total_tests}"
    pass_count_field = f"{len(passing_tests):>{length_index_field}}/{total_tests}"
    for test in passing_tests:
        test_name = test.get_name() + ":"
        test_pass = "PASS"
        test_time = test.get_time_elapsed()
        pass_message = f"   {test_name:.<{longest_name}} {test_pass} -- Time Elapsed:{test_time}"
        if len(pass_message) > longest_line:
            longest_line = len(pass_message)
        passing_lines.append(pass_message)
    for test in failing_tests:
        test_name = test.get_name() + ":"
        test_pass = "FAIL"
        test_time = test.get_time_elapsed()
        fail_message = f"   {test_name:.<{longest_name}} {test_pass} -- Time Elapsed:{test_time}"
        if len(fail_message) > longest_line:
            longest_line = len(fail_message)
        failing_lines.append(fail_message)
    pass_message = f"Passing Unit Tests:{pass_count_field} "
    pass_line = f"{pass_message:><{longest_line + 1}}"
    logger.info(pass_line)
    for line in passing_lines:
        logger.info(line)
    fail_message = f"Failing Unit Tests:{fail_count_field} "
    fail_line = f"{fail_message:><{longest_line + 1}}"
    logger.info(fail_line)
    for line in failing_lines:
        logger.info(line)
    last_line = ">" * (longest_line + 1)
    logger.info(last_line)


def sim_process(index, test, test_dir_top, platform, coverage, simulator, fims):
    makefile = "Makefile_" + simulator.upper() + '.mk'
    test_name_pattern = r'(\w+)\.svh'
    test_name_valid = re.search(test_name_pattern, test)
    sim_elapsed = datetime.timedelta(seconds = 0)
    total_processes = len(list_of_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    if(fims=='n6000_100G'):
        fim = "n6000_100G=1"
    elif(fims=='n6000_25G'):
        fim = "n6000_25G=1"
    elif(fims=='n6000_10G'):
        fim = "n6000_10G=1"
    else:
        fim = ""

    if (test_name_valid):
        sim_start = datetime.datetime.now()
        test_name_extracted = test_name_valid.group(1)
        test_file = test_dir_top + '/' + test 
        logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
        if (os.path.exists(test_file)):
            testname = "TESTNAME=" + test_name_extracted
            if (coverage == 'ral_cov'):
                if (simulator == 'vcs'):
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1 COV=1"
                else:
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1 COV=1 MSIM=1"
            elif (coverage == 'fun_cov'):
                if (simulator == 'vcs'):
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1 COV_FUNCTIONAL=1"
                else:
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1 COV_FUNCTIONAL=1 MSIM=1"
            else:
                if (simulator == 'vcs'):
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1"
                else:
                    sim_command_line = f"gmake -f {makefile} {testname} run {fim} DEBUG=1 MSIM=1"
            sim = subprocess.Popen(sim_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
            sim.wait()
            sim_result = sim.poll()
            sim_end = datetime.datetime.now()
            sim_elapsed = sim_end - sim_start
            if sim_result == 0:
                logger.debug(f"Simulation via gmake has returned normally for test <{test_name_extracted}> with return value {sim_result}.")
            else:
                logger.warning(f"WARNING: Simulation has returned abnormally for test <{test_name_extracted}> with return value {sim_result}.")
            logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
            logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
            queue.put((test_name_extracted, sim_elapsed))
        else:
            logger.warning(f"WARNING: UVM Test {test_file} could not be found.")
    else:
        logger.warning(f"WARNING: UVM Test {test} name does not appear to be in the correct format(regex): {test_name_pattern}.")


def sim_farm_process(index, test, test_dir_top, platform, coverage, simulator, fims):
    makefile = "Makefile_" + simulator.upper() + '.mk'
    arc_submit_return = r'(\w+)'
    arc_submit_return_found = False
    arc_job_pattern = r'id\s*:\s*(\w+)'
    arc_job_status_pattern = r'status\s*:\s*(\w+)'
    arc_job_start_time_pattern = r'set_running_at\s*:\s*(\w+)'
    arc_job_finish_time_pattern = r'set_done_at\s*:\s*(\w+)'
    arc_job_host_name_pattern = r'host\s*:\s*(\w+)'
    arc_job_return_code_pattern = r'return_code\s*:\s*(\w+)'
    test_name_pattern = r'(\w+)\.svh'
    test_name_valid = re.search(test_name_pattern, test)
    sim_elapsed = datetime.timedelta(seconds = 0)
    total_processes = len(list_of_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    if(fims=='n6000_100G'):
        fim = "n6000_100G=1"
    elif(fims=='n6000_25G'):
        fim = "n6000_25G=1"
    elif(fims=='n6000_10G'):
        fim = "n6000_10G=1"
    else:
        fim = ""

    if (test_name_valid):
        sim_start = datetime.datetime.now()
        test_name_extracted = test_name_valid.group(1)
        test_file = test_dir_top + '/' + test 
        logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
        if (os.path.exists(test_file)):
            testname = "TESTNAME=" + test_name_extracted
            if (coverage == 'ral_cov'):
                if (simulator == 'vcs'):
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1 COV=1"
                else:
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1 COV=1 MSIM=1"
            elif (coverage == 'fun_cov'):
                if (simulator == 'vcs'):
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1 COV_FUNCTIONAL=1"
                else:
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1 COV_FUNCTIONAL=1 MSIM=1"
            else:
                if (simulator == 'vcs'):
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1"
                else:
                    arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- gmake -f {makefile} {testname} run {fim} DEBUG=1 MSIM=1"
            arc_submit = subprocess.Popen(arc_submit_command_line.split(), stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
            with arc_submit.stdout:
                for line in iter(arc_submit.stdout.readline, ""):
                    line_contains_arc_submit_return_pattern = re.search(arc_submit_return, line)
                    if (line_contains_arc_submit_return_pattern):
                        arc_submit_return_id = line_contains_arc_submit_return_pattern.group(1)
                        arc_submit_return_found = True
            arc_submit.wait()
            arc_submit_result = arc_submit.poll()
            if (arc_submit_result == 0) and arc_submit_return_found:
                logger.debug(f"Farm job via ARC submit has returned normally for test <{test_name_extracted}> with return value {arc_submit_result} and ARC Job ID:{arc_submit_return_id}")
                arc_job_done = False
                arc_job_status = "None"
                arc_job_last_status = "None"
                arc_job_command_line = f"arc job {arc_submit_return_id}"
                while not arc_job_done:
                    arc_job = subprocess.Popen(arc_job_command_line.split(), stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
                    with arc_job.stdout:
                        for line in iter(arc_job.stdout.readline, ""):
                            line_contains_arc_job_pattern             = re.search(arc_job_pattern,             line)
                            line_contains_arc_job_status_pattern      = re.search(arc_job_status_pattern,      line)
                            line_contains_arc_job_start_time_pattern  = re.search(arc_job_start_time_pattern,  line)  
                            line_contains_arc_job_finish_time_pattern = re.search(arc_job_finish_time_pattern, line)
                            line_contains_arc_job_host_name_pattern   = re.search(arc_job_host_name_pattern,   line)   
                            line_contains_arc_job_return_code_pattern = re.search(arc_job_return_code_pattern, line)
                            if (line_contains_arc_job_pattern):
                                arc_job_id = line_contains_arc_job_pattern.group(1)
                            if (line_contains_arc_job_status_pattern):
                                arc_job_last_status = arc_job_status
                                arc_job_status = line_contains_arc_job_status_pattern.group(1)
                                if (arc_job_status != arc_job_last_status):
                                    logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> process_status.......: {arc_job_status}")
                                    if (arc_job_status == "done") or (arc_job_status == "error"):
                                        arc_job_done = True
                            if (line_contains_arc_job_start_time_pattern):
                                arc_job_start_time = line_contains_arc_job_start_time_pattern.group(1)
                            if (line_contains_arc_job_finish_time_pattern):
                                arc_job_finish_time = line_contains_arc_job_finish_time_pattern.group(1)
                                arc_job_done = True
                            if (line_contains_arc_job_host_name_pattern):
                                arc_job_host_name = line_contains_arc_job_host_name_pattern.group(1)
                            if (line_contains_arc_job_return_code_pattern):
                                arc_job_return_code = line_contains_arc_job_return_code_pattern.group(1)
                    arc_job.wait()
                    arc_job_result = arc_job.poll()
                    time.sleep(10)
                sim_end = datetime.datetime.now()
                sim_elapsed = sim_end - sim_start
                logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
                logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
                queue.put((test_name_extracted, sim_elapsed, arc_job_id, arc_job_status, arc_job_host_name, arc_job_return_code))
            else:
                if (arc_submit_result != 0):
                    logger.warning(f"WARNING: ARC submit has returned abnormally for test <{test_name_extracted}> with return value {arc_submit_result}.")
                if not arc_submit_return_found:
                    logger.warning(f"WARNING: ARC submit has failed to provide a job ID normally for test <{test_name_extracted}>.")
        else:
            logger.warning(f"WARNING: UVM Test {test_file} could not be found.")
    else:
        logger.warning(f"WARNING: UVM Test {test} name does not appear to be in the correct format(regex): {test_name_pattern}.")


if __name__ == "__main__":
    test_times_dict = {}
    test_info_dict = {}
    test_results = []
    regression_run_start = datetime.datetime.now()
    format = "%(asctime)s: %(message)s"
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter(format)
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.INFO)
    stdout_handler.setFormatter(formatter)
    file_handler = logging.FileHandler('regression_py.log')
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.addHandler(stdout_handler)
    parser = argparse.ArgumentParser(
            formatter_class=argparse.RawDescriptionHelpFormatter,
            description=textwrap.dedent('''OFS UVM Regression Test Runner'''),
            epilog=textwrap.dedent('''\
            Example: below performs a UVM regression test, run locally, with 8 processes, for adp platform, using test_pkg set of tests, using VCS with no code coverage.
               python regress_run.py -l -n 8 -p adp -k test_pkg -s vcs -c none
            Same as above using long-form args: 
               python regress_run.py --local --n_procs 8 --plat adp --pack test_pkg --sim vcs --cov none
            Same as above, but run on Intel Farm (no --local): 
               python regress_run.py --plat adp --pack test_pkg --sim vcs --cov none
            Running script using defaults: run on Farm, adp platform, using test_pkg set of tests, using VCS with no code coverage:
               python regress_run.py'''))
    parser.add_argument('-l', '--local', dest='run_regression_locally', action='store_true', help='Run regression locally, or run it on Farm.  (Default: %(default)s)')
    parser.add_argument('-n', '--n_procs', dest='max_parallel_running_process_count', type=check_positive_process_count, metavar='N', nargs='?', default=multiprocessing.cpu_count()-1, help='Maximum number of processes/UVM tests to run in parallel when run locally.  This has no effect on Farm run.  (Default #CPUs-1: %(default)s)')
    parser.add_argument('-p', '--plat', dest='platform', type=str, nargs='?', default='adp', choices=['adp'], help='HW platform for regression test.  (Default: %(default)s)')
    parser.add_argument('-k', '--pack', dest='package', type=str, nargs='?', default='test_pkg', choices=['test_pkg'], help='Test suite to run during regression.  (Default: %(default)s)')
    parser.add_argument('-s', '--sim', dest='simulator', type=str, nargs='?', default='vcs', choices=['vcs','msim'], help='Simulator used for regression test.  (Default: %(default)s)')
    parser.add_argument('-f', '--fims', dest='fims', type=str, nargs='?', default='n6001', choices=['n6001','n6000_100G','n6000_25G','n6000_10G'], help='select fims.  (Default: %(default)s)')
    parser.add_argument('-c', '--cov', dest='coverage', type=str, nargs='?', default='none', choices=['none','ral_cov','fun_cov'], help='Code coverage used for regression, if any.  (Default: %(default)s)')
    parser.add_argument('-b', '--bypass', dest='bypass_library_build', action='store_true', help='Bypass/skip the IP/library build step.  Do this if you have already built your library and do not want to waste time doing it again.  (Default: %(default)s)')
    parser.add_argument('-e', '--email_list', dest='email_list', action='store_true', help='To send mail to multiple receipients')
    args = parser.parse_args()
    logger.info(f">>> Running UVM Regression Run Python Script: {os.path.basename(__file__)}")
    logger.info(f"    Begin running at date/time..............: {regression_run_start}")
    logger.info(f"    Simulator used for run..................: {args.simulator}")
    rootdir = get_rootdir()
    logger.info(f"      Git Repo Root Directory is..: {rootdir}")
    if args.email_list:
       email_list = get_email_list()
    git_commit = get_last_commit()
    logger.info(f"      Git Repo Last Commit is.....: {git_commit}")
    script_dir = os.path.dirname(os.path.realpath(__file__))
    logger.info(f"      Script Location is..........: {script_dir}")
    current_dir = os.getcwd()
    logger.debug(f"      Current Working Directory is: {current_dir}")
    top_list_of_tests = set_top_list_of_tests(args.package)
    test_dir = os.path.dirname(top_list_of_tests)
    make_dir = set_make_dir()
    os.chdir(make_dir)
    current_dir = os.getcwd()
    logger.info(f"      Current Working Directory is: {current_dir}")
    logger.info(f"      Make Directory is...........: {make_dir}")
    if(os.path.exists(top_list_of_tests)):
        logger.info(f"      Top list of tests found.....: {top_list_of_tests}")
        logger.info(f"      Test Directory..............: {test_dir}")
    else:
        logger.error(f"ERROR: Top list of tests NOT found: {top_list_of_tests}")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    if args.run_regression_locally:
        logger.info(f"      File System for Local Run...: {check_nfs().upper()}")
    else:
        if (check_nfs() == 'nfs'): 
            logger.info(f"      File System for Farm Run....: {check_nfs().upper()}")
        else:
            logger.error(f"ERROR: Farm Regression Runs must be run from an NFS file system.  Current file system is: {check_nfs().upper()}")
            sys.exit(1)
    list_of_tests = create_test_list(top_list_of_tests)
    logger.info(f"      List of Tests to Run ({len(list_of_tests)})..: >>>>")
    longest_test_name = 0
    for test in list_of_tests:
        logger.info(f"         {test}")
        if (len(test)>longest_test_name):
            longest_test_name = len(test)
    if not args.bypass_library_build:
        build_sim_env(args.platform, args.coverage, args.simulator, args.fims)
    total_processes_to_run = len(list_of_tests)
    if args.run_regression_locally:
        logger.info(f"          Beginning Test Regression with {total_processes_to_run} processes.")
        logger.info(f"          Parallel Running Process Count limited to {args.max_parallel_running_process_count} processes.")
        queue = multiprocessing.Queue()
        pool = multiprocessing.Pool(args.max_parallel_running_process_count)
        test_items = [pool.apply_async(sim_process, (i, list_of_tests[i], test_dir, args.platform, args.coverage, args.simulator, args.fims)) for i in range(total_processes_to_run)]
        logger.info(f"UVM Test Pool Launch Completed.")
        logger.info(f"Test Items Pool: {test_items}")
        for item in test_items:
            item.get()
        while not queue.empty():
            time_tuple = queue.get()
            logger.debug(f"Time tuple : {time_tuple}")
            test = time_tuple[0]
            logger.debug(f"Test.......: {test}")
            time = time_tuple[1]
            logger.debug(f"Time.......: {time}")
            test_times_dict[test] = time
        logger.info(f"UVM Test Processing Completed.  Total of {total_processes_to_run} processes run.")
    else:
        logger.info(f"          Beginning Farm Test Regression with {total_processes_to_run} processes.")
        queue = multiprocessing.Queue()
        pool = multiprocessing.Pool(total_processes_to_run)
        test_items = [pool.apply_async(sim_farm_process, (i, list_of_tests[i], test_dir, args.platform, args.coverage, args.simulator, args.fims)) for i in range(total_processes_to_run)]
        logger.info(f"UVM Farm Test Pool Launch Completed.")
        logger.info(f"Test Items List: {test_items}")
        for item in test_items:
            item.get()
        while not queue.empty():
            info_tuple = queue.get()
            test = info_tuple[0]
            info = info_tuple[1:]
            logger.debug(f"Info tuple : {info_tuple}")
            logger.debug(f"Test.......: {test}")
            logger.debug(f"Info.......: {info}")
            test_info_dict[test] = info 
        logger.info(f"UVM Farm Test Processing Completed.  Total of {total_processes_to_run} processes run.")
    scan_test_results(list_of_tests, current_dir)
    length_count_field = len(str(test_results[0].get_test_count()))
    logger.info(f"      Number of UVM test results captured: {test_results[-1].get_test_count():>{length_count_field}}")
    logger.info(f"      Number of UVM test results passing.: {test_results[-1].get_test_count_passed():>{length_count_field}}")
    logger.info(f"      Number of UVM test results failing.: {test_results[-1].get_test_count_failed():>{length_count_field}}")
    for test_object in test_results:
        test_object.print()
    print_results()
    regression_run_end = datetime.datetime.now()
    regression_run_elapsed = regression_run_end - regression_run_start
    logger.info(f"      Number of UVM test results captured: {test_results[-1].get_test_count():>{length_count_field}}")
    logger.info(f"      Number of UVM test results passing.: {test_results[-1].get_test_count_passed():>{length_count_field}}")
    logger.info(f"      Number of UVM test results failing.: {test_results[-1].get_test_count_failed():>{length_count_field}}")
    logger.info(f"    End UVM regression running at date/time................: {regression_run_end}")
    logger.info(f"    Elapsed time for UVM regression run....................: {regression_run_elapsed}")
    send_email_report()
