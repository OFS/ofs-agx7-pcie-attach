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

    def __init__(self, name, directory, unit_test_pass, time_elapsed):
        self.name = name
        self.dir  = directory
        self.unit_test_pass = unit_test_pass
        self.time_elapsed = time_elapsed
        Test.test_count += 1
        if unit_test_pass:
            Test.test_count_pass += 1
        else:
            Test.test_count_fail += 1

    def get_name(self):
        return self.name

    def set_directory(self,directory):
        self.dir = directory

    def get_directory(self):
        return self.dir

    def set_unit_test_pass(self,pass_val):
        if self.unit_test_pass ^ pass_val:
            if pass_val:
                Test.test_count_pass += 1
                Test.test_count_fail -= 1
            else:
                Test.test_count_pass -= 1
                Test.test_count_fail += 1
        self.unit_test_pass = pass_val

    def unit_test_test_passed(self):
        if not self.unit_test_pass:
            Test.test_count_pass += 1
            Test.test_count_fail -= 1
        self.unit_test_pass = True

    def unit_test_test_failed(self):
        if self.unit_test_pass:
            Test.test_count_pass -= 1
            Test.test_count_fail += 1
        self.unit_test_pass = False

    def get_unit_test_pass(self):
        return self.unit_test_pass

    def get_test_count(self):
        return Test.test_count

    def get_test_count_passed(self):
        return Test.test_count_pass

    def get_test_count_failed(self):
        return Test.test_count_fail

    def set_time_elapsed(self,delta):
        self.time_elapsed = delta

    def get_time_elapsed(self):
        return self.time_elapsed

    def print(self):
        logger.info(f"Test Object name..............: {self.name}")
        logger.info(f"            dir...............: {self.dir}")
        logger.info(f"            unit_test_pass....: {self.unit_test_pass}")
        logger.info(f"            time_elapsed......: {self.time_elapsed}")


class FarmTest(Test):

    def __init__(self, name, directory, unit_test_pass, test_info):
        super().__init__(name, directory, unit_test_pass, test_info[0])
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
        logger.info(f"                 unit_test_pass.....: {self.unit_test_pass}")
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

    if rootdir is None:
        rootdir_pattern_found = 0
        rootdir = ""
        rootdir_pattern = r'(/\S*)'
        rootdir_cmd = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
        with rootdir_cmd.stdout:
            for line in iter(rootdir_cmd.stdout.readline, ""):
                line_contains_pattern = re.search(rootdir_pattern, line)
                if (line_contains_pattern):
                    rootdir = line_contains_pattern.group(1)
                    rootdir_pattern_found = 1
        rootdir_cmd.wait()
        command_success = rootdir_cmd.poll()
        if (command_success == 0):
            if (rootdir_pattern_found):
                logger.debug(f"Git root directory search has returned successfully with return value {command_success}.")
                logger.debug(f"Git root directory is: {rootdir}.")
            else:
                logger.error(f"ERROR: Git root directory returned is not in an absolute format.")
                logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.")
                sys.exit(1)
        else:
            logger.error(f"ERROR: Git root directory search has failed.")
            logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.")
            sys.exit(1)

    simdir = os.path.join(rootdir, 'sim')
    if not os.path.isdir(simdir):
        logger.error(f"ERROR: {simdir}/ directory not found. Check OFS_ROOTDIR environment varable.")
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


def find_files(filename, search_top_dir):
    found_file_list = []
    for root_dir, dir_local, files in os.walk(search_top_dir):
        if filename in files:
            found_file_list.append(root_dir)
    return found_file_list

def generate_sim_files():
    sim_files_path=rootdir+ "/" + "ofs-common" + "/" + "scripts" + "/" + "common" + "/" + "sim" + "/" + "gen_sim_files.sh"
    logger.info(f" generating sim files: {sim_files_path}")
    sim_files  = f"sh {sim_files_path}"
    if args.ofss:
        sim_files=sim_files + f" --ofss {','.join(args.ofss)}"

    sim_files=sim_files + f" {args.board_name}"
    print(sim_files)
    files = subprocess.Popen(sim_files.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    files.wait()

def create_test_list():
    working_test_list = []
    filtered_test_list = []
    logger.debug(f"CTL: Package - {args.package}")
    test_list_file = top_test_dir + "/list.txt"
    skip_list_file = top_test_dir + "/scripts/skip_list.txt"
    if (args.package == "list"):
        test_dir_pattern = r'^\.\/(\w+)\/set_params\.sh'
        try:
            with open(test_list_file) as file_object:
                for line in file_object:
                   working_test_list.append(line.rstrip())
        except FileNotFoundError:
            logger.error(f"ERROR: List of Unit Tests file not found: {test_list_file}")
            sys.exit(1)
        for test in working_test_list:
            test_dir_pattern_found = re.search(test_dir_pattern,test)
            if (test_dir_pattern_found):
                test_dir = test_dir_pattern_found.group(1)
                unit_test_script = top_test_dir + "/" + test_dir + "/" + "set_params.sh"
                if (os.path.exists(unit_test_script)):
                    logger.debug(f"CTL: Adding Test - {test_dir}")
                    filtered_test_list.append(test_dir)
                else:
                    logger.error(f"ERROR: Unit Test run script not found: {unit_test_script} for test {test_dir}")
                    sys.exit(1)
            else:
                logger.error(f"ERROR: Unit Test in 'list.txt' file not in correct format: {test}")
                logger.error(f"       Expected regex pattern: {test_dir_pattern}")
    else:
        working_test_list = find_files("set_params.sh",top_test_dir)
        if (args.package == "all"):
            for test in working_test_list:
                test_path_split = test.split("/")
                filtered_test_list.append(test_path_split[-1])                
        else:
            test_dir_pattern = "\/(" + args.package + r'\w+)$'
            logger.debug(f"Unit Test Search Pattern: {test_dir_pattern}")
            for test in working_test_list:
                logger.debug(f"Unit Test Searched..: {test}")
                filtered_test_found = re.search(test_dir_pattern,test)
                if (filtered_test_found):
                    filtered_test_list.append(filtered_test_found.group(1))
    if 'scripts' in filtered_test_list:
        filtered_test_list.remove('scripts')
    if (os.path.exists(rootdir+"/sim/scripts/generated_ftile_macros.f")):
        with open(skip_list_file) as file_object:
            for line in file_object:
                if (line.startswith("FTILE:")):
                    test = line.split(":")
                    filtered_test_list.remove(test[1].rstrip())
    else:
        with open(skip_list_file) as file_object:
            for line in file_object:
                if (line.startswith("n6001:")):
                    test = line.split(":")
                    filtered_test_list.remove(test[1].rstrip())
    return filtered_test_list


def pmci_problem_test_filter():
    # pmci_problem_tests = (
    # )
    filtered_test_list = []
    # looping_list = list_of_tests.copy() # Iteration on list_of_tests with test removal results in skipped tests.  Use a copy for looping.
    # logger.debug(f">>> Filtering PMCI Problematic Tests into their own list.")
    # for test in looping_list:
    #     for pmci_test in pmci_problem_tests:
    #         if (test == pmci_test):
    #             filtered_test_list.append(test)
    #             list_of_tests.remove(test)
    #             logger.debug(f"    Removing test {test} from main list and adding to PMCI list.")
    # logger.debug(f"List of standard tests({len(list_of_tests)}):")
    # for test in list_of_tests:
    #     logger.debug(f"     {test}")
    # logger.debug(f"List of PMCI tests({len(filtered_test_list)}):")
    # for pmci_test in filtered_test_list:
    #     logger.debug(f"     {pmci_test}")
    # logger.debug(f">>> Filtering PMCI Problematic Tests complete...")
    return filtered_test_list



def check_positive_process_count(processes):
    uint = int(processes)
    if uint <= 0:
        raise argparse.ArgumentTypeError(f"Number of processes: {uint} is not a positive integer.")
    return uint


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
    # Unit Test Case Data Header
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
        <link rel=File-List href="unit_test_email_page_basic_files/filelist.xml">
        <link rel=dataStoreItem href="unit_test_email_page_basic_files/item0006.xml"
        target="unit_test_email_page_basic_files/props007.xml">
        <link rel=themeData href="unit_test_email_page_basic_files/themedata.thmx">
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
    # Unit Test E-mail body text messages.
    #------------------------------------------------------------
    html_body_text_header = '''
        <p class=MsoNormal><span style='font-family:Consolas;color:white;mso-themecolor: background1'>'''
    html_body_text_error_header = '''
        <p class=MsoNormal><span style='font-family:Consolas;color:rgb(255, 80, 80)'> '''
    html_body_text_ender = "<o:p></o:p></span></p>"
    html_body_text_ender = "<o:p></o:p></span></p>"
    html_data += html_body_text_header
    html_data += f">>> Running Unit Test Regression Run Python Script: {os.path.basename(__file__)}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Simulator used for run........................: {args.simulator}"
    html_data += html_body_text_ender
    if args.run_regression_locally:
        html_data += html_body_text_header
        html_data += f"    Simulation environment........................: Local"
        html_data += html_body_text_ender
    else:
        html_data += html_body_text_header
        html_data += f"    Simulation environment........................: Farm"
        html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Number of CPUs/Processes selected.............: {args.max_parallel_running_process_count}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Package of tests run..........................: {args.package}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Begin running at date/time....................: {regression_run_start}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Regression run by user........................: {user_name} --> {full_name_caps}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Git Repo Root Directory is....................: {rootdir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Git Repo Last Commit is.......................: {git_commit}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Script Location is............................: {script_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Current Working Directory is..................: {current_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Unit Test Package run.........................: {args.package}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Test Directory................................: {top_test_dir}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Number of Unit Tests run......................: {test_results[-1].get_test_count()}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Number of Unit Tests passing..................: {test_results[-1].get_test_count_passed()}"
    html_data += html_body_text_ender
    html_data += html_body_text_error_header
    html_data += f"    Number of Unit Tests failing..................: {test_results[-1].get_test_count_failed()}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    End Unit Test regression running at date/time.: {regression_run_end}"
    html_data += html_body_text_ender
    html_data += html_body_text_header
    html_data += f"    Elapsed time for Unit Test regression run.....: {regression_run_elapsed}"
    html_data += html_body_text_ender

    #------------------------------------------------------------
    # Unit Test Table Data Column Headers
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
          mso-themecolor:text1'>Unit Test Case</span></b><b><span style='font-family:
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
        test_time = test_object.get_time_elapsed()
        test_pass = test_object.get_unit_test_pass()
        if (test_pass):
            test_pass_str = "PASSED"
            font_color = "rgb(256, 256, 256)"
        else:
            test_pass_str = "FAILED"
            font_color = "rgb(255, 80, 80)"
        #------------------------------------------------------------
        # Unit Test Case Table Cell
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
    message["Subject"] = f"Unit Test Regression results for OFS AC - Tool:{args.simulator}, Processes:{args.max_parallel_running_process_count}, Package:{args.package}, Rootdir:{rootdir}"
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


def scan_test_results(test_list):
    logger.debug(f"SCAN: top directory: {top_test_dir}")
    if (args.simulator == 'msim'):
        unit_test_fail_pattern = r'^#\s*Test FAILED!'
        unit_test_pass_pattern = r'^#\s*Test passed!'
    else:
        unit_test_fail_pattern = r'^Test FAILED!'
        unit_test_pass_pattern = r'^Test passed!'
    for test in test_list:
        test_name = test
        sim_dir = top_test_dir + "/" + test + "/" + f"sim_{args.simulator}"
        transcript = sim_dir + "/" + "transcript"
        transcript_found = os.path.exists(transcript)
        unit_test_fail = False
        unit_test_pass = False
        if (transcript_found):
            logger.debug(f"transcript.......: {transcript}")
            try:
                with open(transcript) as file_object:
                    for line in file_object:
                        line = line.rstrip()
                        unit_test_fail_pattern_found = re.search(unit_test_fail_pattern,line)
                        if (unit_test_fail_pattern_found):
                            unit_test_fail = True
                            logger.debug(f"SCAN: Failure!  Unit Test Simulation test:{test_name} ran with errors.")
                            break
                        unit_test_pass_pattern_found = re.search(unit_test_pass_pattern,line)
                        if (unit_test_pass_pattern_found):
                            unit_test_pass = True
                            logger.debug(f"SCAN: Success!  Unit Test Simulation test:{test_name} ran without errors.")
                            break
                if test_name in test_times_dict:
                    logger.debug(f"      unit_test test time..: {test_times_dict[test_name]}")
                else:
                    logger.debug(f"      unit_test test time..: None")
                if args.run_regression_locally :
                    test_result_object = Test(test_name, sim_dir, unit_test_pass, test_times_dict[test_name])
                else:
                    test_result_object = FarmTest(test_name, sim_dir, unit_test_pass, test_info_dict[test_name])
                test_results.append(test_result_object)
            except FileNotFoundError:
                logger.debug(f"WARNING: Simulation Log for test {test_name}: {transcript} was not found.")
        else:
            logger.debug(f"WARNING: Simulations Log File: {transcript} was not found.")
            if (args.simulator != "msim"):  # ModelSim/Questa still generates a "transcript" file, even when compilation fails.  VCS does not - requiring this code.
                unit_test_fail = True 
                unit_test_pass = False
                if args.run_regression_locally :
                    test_result_object = Test(test_name, sim_dir, unit_test_pass, test_times_dict[test_name])
                else:
                    test_result_object = FarmTest(test_name, sim_dir, unit_test_pass, test_info_dict[test_name])
                test_results.append(test_result_object)
                logger.debug(f"SCAN: Simulation compilation failed for test {test_name}.")


def print_results():
    failing_tests = []
    failing_lines = []
    passing_tests = []
    passing_lines = []
    longest_line = 0
    longest_name = 0
    for test in test_results:
        if test.unit_test_pass:
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


def sim_process_normal(index, test, test_dir_top, simulator):
    sim_elapsed = datetime.timedelta(seconds = 0)
    total_processes = len(all_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    sim_start = datetime.datetime.now()
    test_name_extracted = test.rstrip()
    test = test.replace('\n', '')
    test_dir = test_dir_top + '/' + test
    # test_file = test_dir_top + '/' + test + "/" + "run_sim.sh"
    # test_file = test_dir_top + "/scripts/run_sim.sh"
    test_file = os.getenv('OFS_ROOTDIR') + "/ofs-common/scripts/common/sim/run_sim.sh"
    test_param = "TEST=" + test
    logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
    logger.info(f"   Test Dir : {test_dir}")
    if (os.path.exists(test_file)):
        if (simulator == 'vcs'):
            sim_command_line  = f"sh {test_file} {test_param}"
        elif (simulator == 'vcsmx'):
            sim_command_line  = f"sh {test_file} {test_param} VCSMX=1"
        else:
            sim_command_line  = f"sh {test_file} {test_param} MSIM=1"
        sim = subprocess.Popen(sim_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
        sim.wait()
        sim_result = sim.poll()
        sim_end = datetime.datetime.now()
        sim_elapsed = sim_end - sim_start
        if sim_result == 0:
            logger.debug(f"   Simulation has returned normally for test <{test_name_extracted}> with return value {sim_result}.")
        else:
            logger.warning(f"WARNING: Simulation has returned abnormally for test <{test_name_extracted}> with return value {sim_result}.")
        logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
        logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
    else:
        logger.warning(f"WARNING: Unit Test {test_file} could not be found.")
    queue_normal.put((test_name_extracted, sim_elapsed))


def sim_process_pmci(index, test, test_dir_top, simulator):
    sim_elapsed = datetime.timedelta(seconds = 0)
    total_processes = len(all_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    sim_start = datetime.datetime.now()
    test_name_extracted = test.rstrip()
    test = test.replace('\n', '')
    test_dir = test_dir_top + '/' + test
    #test_file = test_dir_top + '/' + test + "/" + "run_sim.sh"
    # test_file = test_dir_top + "/scripts/run_sim.sh"
    test_file = os.getenv('OFS_ROOTDIR') + "/ofs-common/scripts/common/sim/run_sim.sh"
    test_param = "TEST=" + test
    logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
    logger.info(f"   Test Dir : {test_dir}")
    if (os.path.exists(test_file)):
        if (simulator == 'vcs'):
            sim_command_line  = f"sh {test_file} {test_param}"
        elif (simulator == 'vcsmx'):
            sim_command_line  = f"sh {test_file} {test_param} VCSMX=1"
        else:
            sim_command_line  = f"sh {test_file} {test_param} MSIM=1"
        sim = subprocess.Popen(sim_command_line.split(), stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
        sim.wait()
        sim_result = sim.poll()
        sim_end = datetime.datetime.now()
        sim_elapsed = sim_end - sim_start
        if sim_result == 0:
            logger.debug(f"   Simulation has returned normally for test <{test_name_extracted}> with return value {sim_result}.")
        else:
            logger.warning(f"WARNING: Simulation has returned abnormally for test <{test_name_extracted}> with return value {sim_result}.")
        logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
        logger.info(f"   Process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
    else:
        logger.warning(f"WARNING: Unit Test {test_file} could not be found.")
    queue_pmci.put((test_name_extracted, sim_elapsed))


def sim_farm_process_normal(index, test, test_dir_top, simulator):
    arc_submit_return = r'(\w+)'
    arc_submit_return_found = False
    arc_job_pattern = r'id\s*:\s*(\w+)'
    arc_job_status_pattern = r'status\s*:\s*(\w+)'
    arc_job_start_time_pattern = r'set_running_at\s*:\s*(\w+)'
    arc_job_finish_time_pattern = r'set_done_at\s*:\s*(\w+)'
    arc_job_host_name_pattern = r'host\s*:\s*(\w+)'
    arc_job_return_code_pattern = r'return_code\s*:\s*(\w+)'
    sim_elapsed = datetime.timedelta(seconds = 0)
    arc_job_id = "0"
    arc_job_status = "None"
    arc_job_host_name = "None"
    arc_job_return_code = "1"
    total_processes = len(all_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    sim_start = datetime.datetime.now()
    test_name_extracted = test.replace('\n', '')
    test = test.replace('\n', '')
    test_dir = test_dir_top + "/" + test
    test_file = os.getenv('OFS_ROOTDIR') + "/ofs-common/scripts/common/sim/run_sim.sh"
    test_param = "TEST=" + test
    inherited_variables = "OFS_ROOTDIR=$OFS_ROOTDIR"
    logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
    if (os.path.exists(test_file)):
        if (simulator == 'vcs'):
            arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param}"
        elif (simulator == 'vcsmx'):
            arc_submit_command_line  = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param} VCSMX=1"
        else:
            arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param} MSIM=1"
        arc_submit = subprocess.Popen(arc_submit_command_line.split(), stdout=subprocess.PIPE, bufsize=1, universal_newlines=True, env=dict(os.environ))
        with arc_submit.stdout:
            for line in iter(arc_submit.stdout.readline, ""):
                line_contains_arc_submit_return_pattern = re.search(arc_submit_return, line)
                if (line_contains_arc_submit_return_pattern):
                    arc_submit_return_id = line_contains_arc_submit_return_pattern.group(1)
                    arc_submit_return_found = True
        arc_submit.wait()
        arc_submit_result = arc_submit.poll()
        if (arc_submit_result == 0) and arc_submit_return_found:
            logger.debug(f"   Farm job via ARC submit has returned normally for test <{test_name_extracted}> with return value {arc_submit_result} and ARC Job ID:{arc_submit_return_id}")
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
                time.sleep(1)
            sim_end = datetime.datetime.now()
            sim_elapsed = sim_end - sim_start
            logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
            logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
        else:
            if (arc_submit_result != 0):
                logger.warning(f"WARNING: ARC submit has returned abnormally for test <{test_name_extracted}> with return value {arc_submit_result}.")
            if not arc_submit_return_found:
                logger.warning(f"WARNING: ARC submit has failed to provide a job ID normally for test <{test_name_extracted}>.")
    else:
        logger.warning(f"WARNING: Unit Test {test_file} could not be found.")
    queue_normal.put((test_name_extracted, sim_elapsed, arc_job_id, arc_job_status, arc_job_host_name, arc_job_return_code))


def sim_farm_process_pmci(index, test, test_dir_top, simulator):
    arc_submit_return = r'(\w+)'
    arc_submit_return_found = False
    arc_job_pattern = r'id\s*:\s*(\w+)'
    arc_job_status_pattern = r'status\s*:\s*(\w+)'
    arc_job_start_time_pattern = r'set_running_at\s*:\s*(\w+)'
    arc_job_finish_time_pattern = r'set_done_at\s*:\s*(\w+)'
    arc_job_host_name_pattern = r'host\s*:\s*(\w+)'
    arc_job_return_code_pattern = r'return_code\s*:\s*(\w+)'
    sim_elapsed = datetime.timedelta(seconds = 0)
    arc_job_id = "0"
    arc_job_status = "None"
    arc_job_host_name = "None"
    arc_job_return_code = "1"
    total_processes = len(all_tests)-1
    length_index_field = len(str(total_processes))
    index_string = f"{index:>{length_index_field}}/{total_processes}"
    sim_start = datetime.datetime.now()
    test_name_extracted = test.replace('\n', '')
    test = test.replace('\n', '')
    test_dir = test_dir_top + "/" + test
    # test_file = test_dir_top + "/" + test + "/" + "run_sim.sh"
    # test_file = test_dir_top + "/scripts/run_sim.sh"
    test_file = os.getenv('OFS_ROOTDIR') + "/ofs-common/scripts/common/sim/run_sim.sh"
    test_param = "TEST=" + test
    logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time started....: {sim_start}")
    if (os.path.exists(test_file)):
        if (simulator == 'vcs'):
            arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param}"
        elif (simulator == 'vcsmx'):
            arc_submit_command_line  = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param} VCSMX=1"
        else:
            arc_submit_command_line = f"arc submit -PE flow/sw/bigmem mem=20000 -- sh {test_file} {test_param} MSIM=1"
        arc_submit = subprocess.Popen(arc_submit_command_line.split(), stdout=subprocess.PIPE, bufsize=1, universal_newlines=True, env=dict(os.environ))
        with arc_submit.stdout:
            for line in iter(arc_submit.stdout.readline, ""):
                line_contains_arc_submit_return_pattern = re.search(arc_submit_return, line)
                if (line_contains_arc_submit_return_pattern):
                    arc_submit_return_id = line_contains_arc_submit_return_pattern.group(1)
                    arc_submit_return_found = True
        arc_submit.wait()
        arc_submit_result = arc_submit.poll()
        if (arc_submit_result == 0) and arc_submit_return_found:
            logger.debug(f"   Farm job via ARC submit has returned normally for test <{test_name_extracted}> with return value {arc_submit_result} and ARC Job ID:{arc_submit_return_id}")
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
                time.sleep(1)
            sim_end = datetime.datetime.now()
            sim_elapsed = sim_end - sim_start
            logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> date/time completed..: {sim_end}")
            logger.info(f"   Farm process {index_string} for test <{test_name_extracted:.<{longest_test_name}}> time elapsed.........: {sim_elapsed}")
        else:
            if (arc_submit_result != 0):
                logger.warning(f"WARNING: ARC submit has returned abnormally for test <{test_name_extracted}> with return value {arc_submit_result}.")
            if not arc_submit_return_found:
                logger.warning(f"WARNING: ARC submit has failed to provide a job ID normally for test <{test_name_extracted}>.")
    else:
        logger.warning(f"WARNING: Unit Test {test_file} could not be found.")
    queue_pmci.put((test_name_extracted, sim_elapsed, arc_job_id, arc_job_status, arc_job_host_name, arc_job_return_code))


if __name__ == "__main__":
    test_times_dict = {}
    test_info_dict = {}
    test_results = []
    regression_run_start = datetime.datetime.now()
    format = "%(asctime)s: %(message)s"
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    #logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter(format)
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.INFO)
    #stdout_handler.setLevel(logging.DEBUG)
    stdout_handler.setFormatter(formatter)
    file_handler = logging.FileHandler('regression.log')
    file_handler.setLevel(logging.INFO)
    #file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.addHandler(stdout_handler)
    parser = argparse.ArgumentParser(
            formatter_class=argparse.RawDescriptionHelpFormatter,
            description=textwrap.dedent('''OFS Unit Test Simulation Regression Test Runner'''),
            epilog=textwrap.dedent('''\
            Example: below performs a Unit Test regression, run locally, with 8 processes, using package of "all" tests, using VCS.
               python regress_run.py -l -n 8 -k all -s vcs
            Same as above using long-form args: 
               python regress_run.py --local --n_procs 8 --pack all --sim vcs
            Same as above, but run on Intel Farm (no --local): 
               python regress_run.py --pack all --sim vcs
            Running script using defaults: run on Farm, using package of "all" tests, using VCS:
               python regress_run.py'''))
    parser.add_argument('-l', '--local', dest='run_regression_locally', action='store_true', help='Run regression locally, or run it on Farm.  (Default: %(default)s)')
    parser.add_argument('-n', '--n_procs', dest='max_parallel_running_process_count', type=check_positive_process_count, metavar='N', nargs='?', default=multiprocessing.cpu_count()-1, help='Maximum number of processes/tests to run in parallel when run locally.  This has no effect on Farm run.  (Default #CPUs-1: %(default)s)')
    parser.add_argument('-k', '--pack', dest='package', type=str, nargs='?', default='all', choices=['all','fme','he','hssi','list','mem','pmci'], help='Test package to run during regression.  The "list" option will look for a text file named "list.txt" in the "unit_test" directory for a text list of tests to run (top directory names).  (Default: %(default)s)')
    parser.add_argument('-s', '--sim', dest='simulator', type=str, nargs='?', default='vcs', choices=['vcs','msim','vcsmx'], help='Simulator used for regression test.  (Default: %(default)s)')
    parser.add_argument('-g', '--gen_sim_files', dest='gen_sim_files', action='store_true', help='Generate IP simulation files.  This should only be done once per repo update.  (Default: %(default)s)')
    parser.add_argument('-o', '--ofss', dest='ofss', nargs='+', help='Pass ofss file to configure IPs')
    parser.add_argument('-b', '--board_name', dest='board_name', choices=['n6000','n6001','fseries-dk','iseries-dk'], default='n6001',  help='Board name. (Default: %(default)s)')
    parser.add_argument('-e', '--email_list', dest='email_list', action='store_true', help='To send mail to multiple receipients')
    args = parser.parse_args()
    logger.info(f">>> Running Unit Test Regression Run Python Script: {os.path.basename(__file__)}")
    logger.info(f"    Begin running at date/time..............: {regression_run_start}")
    logger.info(f"    Simulator used for run..................: {args.simulator}")
    if args.run_regression_locally:
        logger.info(f"    Simulation environment..................: Local")
    else:
        logger.info(f"    Simulation environment..................: Farm")
    logger.info(f"    Number of CPUs/Processes selected.......: {args.max_parallel_running_process_count}")
    logger.info(f"    Package of Tests to run.................: {args.package}")
    rootdir = get_rootdir()
    logger.info(f"      OFS Root Directory is........: {rootdir}")
    if args.email_list:
       email_list = get_email_list()
    git_commit = get_last_commit()
    logger.info(f"      Git Repo Last Commit is.....: {git_commit}")
    script_dir = os.path.dirname(os.path.realpath(__file__))
    logger.info(f"      Script Location is..........: {script_dir}")
    top_test_dir = rootdir + "/sim/unit_test"
    current_dir = os.getcwd()
    logger.info(f"      Current Working Directory is: {current_dir}")
    if(os.path.exists(top_test_dir)):
        logger.info(f"      Test Directory..............: {top_test_dir}")
    else:
        logger.error(f"ERROR: Test Directory NOT found...: {top_test_dir}")
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
    if args.gen_sim_files:
        generate_sim_files()
    list_of_tests = create_test_list()
    pmci_problem_list_of_tests = pmci_problem_test_filter()
    all_tests = list_of_tests + pmci_problem_list_of_tests
    logger.info(f"      List of Tests to Run ({len(all_tests)})..: >>>>")
    longest_test_name = 0
    for test in all_tests:
        logger.info(f"         {test}")
        if (len(test)>longest_test_name):
            longest_test_name = len(test)
    total_processes_to_run = len(all_tests)
    if (total_processes_to_run > 0):
        if args.run_regression_locally:
            logger.info(f"          Beginning Test Regression with {total_processes_to_run} processes.")
            logger.info(f"          Parallel Running Process Count limited to {args.max_parallel_running_process_count} processes.")
            queue_normal = multiprocessing.Queue()
            pool_normal = multiprocessing.Pool(processes=args.max_parallel_running_process_count)
            test_items_normal = []
            for i in range(len(list_of_tests)):
                item_normal = pool_normal.apply_async(sim_process_normal, (i, list_of_tests[i], top_test_dir, args.simulator))
                test_items_normal.append(item_normal)
            ilast = i
            logger.info(f"Unit Test Pool Launch for Normal Tests Completed. Processes: {len(list_of_tests)}")
            for item_normal in test_items_normal:
                item_normal.get()
            while (queue_normal.qsize() < len(test_items_normal)):
                logger.debug(f"Queue Normal QSize: {queue_normal.qsize()} Target: {len(test_items_normal)}")
                time.sleep(0.1)
            for i in range(len(list_of_tests)):
                time_tuple = queue_normal.get()
                test = time_tuple[0]
                test_time_elapsed = time_tuple[1]
                test_times_dict[test] = test_time_elapsed
                time.sleep(0.1)
            pool_normal.close()
            pool_normal.terminate()
            queue_pmci = multiprocessing.Queue()
            pool_pmci = multiprocessing.Pool(2)
            test_items_pmci = []
            for i in range(len(pmci_problem_list_of_tests)):
                item_pmci = pool_pmci.apply_async(sim_process_pmci, (i+ilast+1, pmci_problem_list_of_tests[i], top_test_dir, args.simulator))
                test_items_pmci.append(item_pmci)
            logger.info(f"Unit Test Pool Launch for PMCI Problem Tests Completed. Processes: {len(pmci_problem_list_of_tests)}")
            for item_pmci in test_items_pmci:
                item_pmci.get()
            while (queue_pmci.qsize() < len(test_items_pmci)):
                logger.debug(f"Queue PMCI QSize: {queue_pmci.qsize()} Target: {len(test_items_pmci)}")
                time.sleep(0.1)
            for i in range(len(pmci_problem_list_of_tests)):
                time_tuple = queue_pmci.get()
                test = time_tuple[0]
                test_time_elapsed = time_tuple[1]
                test_times_dict[test] = test_time_elapsed
                time.sleep(0.1)
            logger.info(f"Unit Test Processing Completed.  Total of {total_processes_to_run} processes run.")
        else:
            logger.info(f"          Beginning Farm Test Regression with {total_processes_to_run} processes.")
            queue_normal = multiprocessing.Queue()
            pool_normal = multiprocessing.Pool(len(list_of_tests))
            test_items_normal = []
            for i in range(len(list_of_tests)):
                item_normal = pool_normal.apply_async(sim_farm_process_normal, (i, list_of_tests[i], top_test_dir, args.simulator))
                test_items_normal.append(item_normal)
            ilast = i
            logger.info(f"Unit Test Farm Pool Launch #1 Completed. Processes: {len(list_of_tests)}")
            for item_normal in test_items_normal:
                item_normal.get()
            while (queue_normal.qsize() < len(test_items_normal)):
                logger.debug(f"Queue Normal QSize: {queue_normal.qsize()} Target: {len(test_items_normal)}")
                time.sleep(0.1)
            for i in range(len(list_of_tests)):
                info_tuple = queue_normal.get()
                test = info_tuple[0]
                info = info_tuple[1:]
                test_info_dict[test] = info 
                time.sleep(0.1)
            pool_normal.close()
            pool_normal.terminate()
            queue_pmci = multiprocessing.Queue()
            pool_pmci = multiprocessing.Pool(2)
            test_items_pmci = []
            for i in range(len(pmci_problem_list_of_tests)):
                item_pmci = pool_pmci.apply_async(sim_farm_process_pmci, (i+ilast+1, pmci_problem_list_of_tests[i], top_test_dir, args.simulator))
                test_items_pmci.append(item_pmci)
            logger.info(f"Unit Test Farm Test Pool Launch #2 Completed. Processes: {len(pmci_problem_list_of_tests)}")
            for item_pmci in test_items_pmci:
                item_pmci.get()
            while (queue_pmci.qsize() < len(test_items_pmci)):
                logger.debug(f"Queue PMCI QSize: {queue_pmci.qsize()} Target: {len(test_items_pmci)}")
                time.sleep(0.1)
            for i in range(len(pmci_problem_list_of_tests)):
                info_tuple = queue_pmci.get()
                test = info_tuple[0]
                info = info_tuple[1:]
                test_info_dict[test] = info 
                time.sleep(0.1)
            pool_pmci.close()
            pool_pmci.terminate()
            logger.info(f"Unit Test Farm Test Processing Completed.  Total of {total_processes_to_run} processes run.")
        scan_test_results(all_tests)
        length_count_field = len(str(test_results[0].get_test_count()))
        logger.info(f"      Number of Unit test results captured: {test_results[-1].get_test_count():>{length_count_field}}")
        logger.info(f"      Number of Unit test results passing.: {test_results[-1].get_test_count_passed():>{length_count_field}}")
        logger.info(f"      Number of Unit test results failing.: {test_results[-1].get_test_count_failed():>{length_count_field}}")
        for test_object in test_results:
            test_object.print()
        print_results()
        regression_run_end = datetime.datetime.now()
        regression_run_elapsed = regression_run_end - regression_run_start
        logger.info(f"      Number of Unit test results captured: {test_results[-1].get_test_count():>{length_count_field}}")
        logger.info(f"      Number of Unit test results passing.: {test_results[-1].get_test_count_passed():>{length_count_field}}")
        logger.info(f"      Number of Unit test results failing.: {test_results[-1].get_test_count_failed():>{length_count_field}}")
        logger.info(f"    End Unit regression running at date/time................: {regression_run_end}")
        logger.info(f"    Elapsed time for Unit regression run....................: {regression_run_elapsed}")
        send_email_report()
    else:
        logger.info(f"Number of Unit Tests is less than or equal to zero -- there is nothing to do.")

