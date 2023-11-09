#!/usr/bin/env python3
# Copyright (C) 2021-2022 Intel Corporation
# SPDX-License-Identifier: MIT

"""
Collects summary test reports from all UVM regressuib tests once all parallel test
executions are completed. Formats collected summary test reports into an HTML report.
Report contains a intro with git-related information and location of UVM artifacts,
as well as a table listing the status of all executed reports.

Input argument is the input file name.
Ex.,
generate_html.py sample_input.txt

In the input file, to email list file (list of email addresses separated by ","),
cc email list file (list of email addresses separated by ","), test report file,
and head file are specified
Ex.,
To: sample_to.txt
CC: sample_cc.txt
Report: sample_report.txt
Head: sample_head.txt

sample_report.html will be created in the same directory as sample_report.txt, and
email will be automatically sent to the email addresses in sample_to.txt and
sample_cc.txt

"""

import os
import string
import sys
import time
import smtplib

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage

CI_DIR = os.path.dirname(os.path.realpath(__file__))
TEMPLATE_PATH = os.path.join(CI_DIR, "email_template.css")
PICS_DIR = os.path.join(CI_DIR, "pics")

# Header of elements to write to the summary file.
TABLE_HEADER = ["Result Dir or Test Name",
                "Cycles",
                "Status",
                "Bucket",
                "Seed"]

TABLE_STAT1 = [ "Bucket",
                "Count",
                "Bucket Name"]

TABLE_STAT2 = [ "PASS",
                "FAIL",
                "No Status",
                "Total",
                "% Passing"]

def read_file(fname, delim=None):
    """
    Read file, output 2D list containing lines and words.
    Words are defined by delimiter (Default: space (None)).
    """
    with open(fname, "r") as filehandler:
        data = filehandler.readlines()
    data = [x.rstrip() for x in data]
    lines = [x.split(delim) for x in data]
    return lines

def collect_filenames(input_file):
    info = open(input_file)
    filenames = info.readlines()
    print(filenames)

    input = [
        "to:",
        "cc:",
        "report:",
        "head:"
    ]
    list = []
    for name in filenames:
        for key in input:
            pos = name.lower().find(key)
            if pos >= 0:
                list.append(name[pos+len(key):len(name)].lstrip().strip())
                input.remove(key)
                break

    return list

def collect_results(testsfile):
    # Opening data file
    ftext = open(testsfile)
    test_list = []
    i = 0
    for line in ftext:
        #print(len(line), ":", line)
        i += 1
        if (i <= 2) or (len(line.split()) < 4) or(line.split()[0][0] == '-'):
            continue
        line = line.replace("<", "&lt")
        line = line.replace(">", "&gt")
        test_list.append(line.split())

    ftext.close()

    print("Total ", len(test_list), "  tests")
    return test_list

def collect_head(headfile):
    # Opening data file
    ftext = open(headfile)
    head_info = []
    for line in ftext:
        head_info.append(line.split())

    ftext.close()
    return head_info

def create_head(head_info):
    """
    Create html results table.
    """

    # Create test result table.
    head = []
    head.append("<p>\n")
    head.append(f"<b>Regression test path: </b>{head_info[0][0]}<br>\n")
    head.append(f"<b>Latest commit on test branch: </b>{head_info[1][0]}<br>\n")
    head.append("</p>\n")

    html_head = "".join(head)
    return html_head

def create_table(test_list):
    """
    Create html results table.
    """

    # Create test result table.
    test_table = []
    test_table.append("<table>")
    table_header = [x for x in TABLE_HEADER]
    test_table.append("<thead><tr><th>" +
                     "</th><th>".join(table_header) +
                     "</th></tr></thead>\n")

    stat1_table = []
    stat1_table.append("<table>")
    table_header = [x for x in TABLE_STAT1]
    stat1_table.append("<thead style=\"background-color:CornflowerBlue; font-size:1em\"><tr><th>" +
                     "</th><th>".join(table_header) +
                     "</th></tr></thead>\n")    
    stat2_table = []
    stat2_table.append("<table>")
    # Append table header.
    table_header = [x for x in TABLE_STAT2]
    stat2_table.append("<thead style=\"background-color:CornflowerBlue; font-size:1em\"><tr><th>" +
                     "</th><th>".join(table_header) +
                     "</th></tr></thead>\n")

    # Append table body.
    stat1 = False
    stat2 = False
    for test in test_list:
        if (test[0].lower() == "bucket"):           # Append statistics
            stat1 = True
        elif (test[0].lower() == "pass"):           # Append statistics
            stat2 = True
            stat1 = False
        else:
            if( stat1 ):
                stat1_table.append("<tr>")
                bucketName = " ".join(test[len(TABLE_STAT1)-1:])
                stat1_table.append(f"<td class='center'>{test[0]}</td>")
                stat1_table.append(f"<td class='center'>{test[1]}</td>")
                stat1_table.append(f"<td class='center'>{bucketName}</td>")
                stat1_table.append("</tr>\n")
            elif( stat2 ):
                stat2_table.append("<tr>")
                for item in test:
                    stat2_table.append(f"<td class='center'>{item}</td>")  
                stat2_table.append("</tr>\n") 
                stat2 = False            
            else:
                test_table.append("<tr>")
                pos = 0
                for item in test:
                    pos += 1
                    if (pos <= 2):
                        continue
                    if (item.lower() == "pass"):
                        test_table.append(f"<td style=\"background-color:ForestGreen; color:White; text-align:center;\">PASS</td>")
                        test_table.append("<td class='left'>"  "</td>")
                    elif (item.lower() == "fail"):
                        test_table.append(f"<td style=\"background-color:Red; color:White; text-align:center;\">Fail</td>")
                    else:             
                        test_table.append(f"<td class='left'>{item}</td>")
                test_table.append("</tr>\n")

    test_table.append("</tbody>\n")
    # Append table footer.
    test_table.append("<tfoot></tfoot>\n")
    # Complete table.
    test_table.append("</table>\n")

    stat1_table.append("</tbody>\n")
    # Append table footer.
    stat1_table.append("<tfoot></tfoot>\n")
    # Complete table.
    stat1_table.append("</table>\n")
    stat1_table.append("<p> </p>\n") 

    stat2_table.append("</tbody>\n")
    # Append table footer.
    stat2_table.append("<tfoot></tfoot>\n")
    # Complete table.
    stat2_table.append("</table>\n")    
    stat2_table.append("<p> </p>\n") 

    tables = stat1_table + stat2_table + test_table
    html_tables = "".join(tables)
    return html_tables


def create_message(test_list, head_info):
    """
    Create HTML email report using optional args vars and test results.
    """

    # TODO - add timestamp user arg later to overwrite (would rather want
    # pipeline start timestamp than timestamp this job executes at)
    # TODO - drive title with platform-based var
    timestamp = time.strftime("%Y%m%dT%H%M")
    title = f"UVM Regression Tests {timestamp}"

    # Create html message body.

    # Create html title
    html_title = f"<h1>{title}</h1>"

    # Create html head
    html_head = create_head(head_info)
    # Create html tables.
    html_tables = create_table(test_list)

    # Import and process CSS template file for email report.
    template = read_file(TEMPLATE_PATH, delim="\n")
    template = ["".join(line) for line in template]
    template = "\n".join(template)
    template = string.Template(template)

    # Assemble complete message.
    html_report = html_title + html_head + html_tables
    html_report = template.substitute(body=html_report)

    return html_report

def create_email(to_file, cc_file, html_report):
    """
    Send email report.
    """
    # TODO: enable SSL secured email reports?
    domain = "intel.com"
    mail_host = "smtp.intel.com"
    user = "psgpac"
    sender_email = user + "@" + domain

    message = MIMEMultipart("related")
    message_subject = "Regression results for OFS FIM UVM simulation"
    message["Subject"] = message_subject
    message["From"] = sender_email
    file = open(to_file, "r")
    message["To"] = file.read()
    file.close()
    file = open(cc_file, "r")
    message["CC"] = file.read()
    file.close()
    message["X-Regtest-Title"] = message_subject
    message["X-Regtest-Failed"] = ""
    message["X-Regtest-Passed"] = ""
    message["X-Regtest-Timeout"] = ""
    message["X-Regtest-Missing"] = ""
    message["X-Regtest-Total"] = ""

    html_report = MIMEText(html_report, "html")
    message.attach(html_report)

    with smtplib.SMTP(mail_host) as smtp:
        smtp.send_message(message)

def main(input_file
         ):
    """
    Collect test results from parallel test sim runs.
    Send email report with results.
    """
    to_email, cc_email, report_name, head_name = collect_filenames(input_file)
    print("to: ", to_email, "\ncc: ", cc_email, "\nplain text report: ", report_name, "\nhead:", head_name )

    test_list = collect_results(report_name)
    head_info = collect_head(head_name)
    html_report = create_message(test_list, head_info)
    create_email(to_email, cc_email, html_report)
    base = os.path.splitext(report_name)[0]
    html_file = base + ".html"
    fhtml = open(html_file, 'w')
    fhtml.write(html_report)
    fhtml.close()

help = "The input file should be edited as following:\n\
To: to_email list file\n\
CC: cc_email list file\n\
report file name\n\
head file name\n\n\
For example,\n\
To: email/to.txt\n\
CC: email/cc.txt\n\
Report: reports_tst/sample.txt\n\
Head: reports_tst/head.txt"

if __name__ == '__main__':
    if( len(sys.argv) != 2 ):
        print("Usage: generate_html.py input_file\n\n")
        print(help)
        exit(-1)

    main(
        sys.argv[1],    # input file name
    )
