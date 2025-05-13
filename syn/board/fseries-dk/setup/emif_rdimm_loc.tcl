# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Memory pin and location assignments
#
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# EMIF CH0
#-----------------------------------------------------------------------------

set_location_assignment PIN_CW29 -to "ddr4_mem_ref_clk[0].clk(n)"
set_location_assignment PIN_CV28 -to ddr4_mem_ref_clk[0].clk
set_location_assignment PIN_CT28 -to ddr4_mem_ref_clk[0].oct_rzqin
set_location_assignment PIN_CP34 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_CR25 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_CT24 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_CW25 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_CK34 -to ddr4_mem[0].cs_n
set_location_assignment PIN_CV24 -to ddr4_mem[0].a[17]
set_location_assignment PIN_CR27 -to ddr4_mem[0].a[16]
set_location_assignment PIN_CT26 -to ddr4_mem[0].a[15]
set_location_assignment PIN_CW27 -to ddr4_mem[0].a[14]
set_location_assignment PIN_CV26 -to ddr4_mem[0].a[13]
set_location_assignment PIN_CR29 -to ddr4_mem[0].a[12]
set_location_assignment PIN_CR31 -to ddr4_mem[0].a[11]
set_location_assignment PIN_CT30 -to ddr4_mem[0].a[10]
set_location_assignment PIN_CW31 -to ddr4_mem[0].a[9]
set_location_assignment PIN_CV30 -to ddr4_mem[0].a[8]
set_location_assignment PIN_CR33 -to ddr4_mem[0].a[7]
set_location_assignment PIN_CT32 -to ddr4_mem[0].a[6]
set_location_assignment PIN_CW33 -to ddr4_mem[0].a[5]
set_location_assignment PIN_CV32 -to ddr4_mem[0].a[4]
set_location_assignment PIN_CR35 -to ddr4_mem[0].a[3]
set_location_assignment PIN_CT34 -to ddr4_mem[0].a[2]
set_location_assignment PIN_CW35 -to ddr4_mem[0].a[1]
set_location_assignment PIN_CV34 -to ddr4_mem[0].a[0]
set_location_assignment PIN_CN31 -to ddr4_mem[0].ck_n
set_location_assignment PIN_CP30 -to ddr4_mem[0].ck
set_location_assignment PIN_CK32 -to ddr4_mem[0].cke
set_location_assignment PIN_CP32 -to ddr4_mem[0].odt
set_location_assignment PIN_CL35 -to ddr4_mem[0].act_n
set_location_assignment PIN_CP24 -to ddr4_mem[0].alert_n
set_location_assignment PIN_CL31 -to ddr4_mem[0].par
set_location_assignment PIN_CN35 -to ddr4_mem[0].reset_n

set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to ddr4_mem_ref_clk[0].clk
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to ddr4_mem_ref_clk[0].clk

# CH0 DQS0
set_location_assignment PIN_DC29 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_DD28 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_DC31 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_DD30 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_CY30 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_DA31 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_DA29 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_CY28 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_DA27 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_CY26 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_DC27 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_DD26 -to ddr4_mem[0].dq[7]

# CH0 DQS1
set_location_assignment PIN_DJ19 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_DH18 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_DF20 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_DJ21 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_DH20 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_DE21 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_DE19 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_DF18 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_DF16 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_DH16 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_DE17 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_DJ17 -to ddr4_mem[0].dq[15]

# CH0 DQS2
set_location_assignment PIN_DJ7 -to ddr4_mem[0].dqs_n[4]
set_location_assignment PIN_DH6 -to ddr4_mem[0].dqs[4]
set_location_assignment PIN_DF8 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_DH8 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_DE9 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_DJ9 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_DE7 -to ddr4_mem[0].dqs_n[5]
set_location_assignment PIN_DF6 -to ddr4_mem[0].dqs[5]
set_location_assignment PIN_DF2 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_DE3 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_DF4 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_DE5 -to ddr4_mem[0].dq[23]

# CH0 DQS3
set_location_assignment PIN_DJ13 -to ddr4_mem[0].dqs_n[6]
set_location_assignment PIN_DH12 -to ddr4_mem[0].dqs[6]
set_location_assignment PIN_DE15 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_DF14 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_DJ15 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_DH14 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_DE13 -to ddr4_mem[0].dqs_n[7]
set_location_assignment PIN_DF12 -to ddr4_mem[0].dqs[7]
set_location_assignment PIN_DF10 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_DH10 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_DJ11 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_DE11 -to ddr4_mem[0].dq[31]

# CH0 DQS4
set_location_assignment PIN_DJ25 -to ddr4_mem[0].dqs_n[8]
set_location_assignment PIN_DH24 -to ddr4_mem[0].dqs[8]
set_location_assignment PIN_DH26 -to ddr4_mem[0].dq[32]
set_location_assignment PIN_DE27 -to ddr4_mem[0].dq[33]
set_location_assignment PIN_DF26 -to ddr4_mem[0].dq[34]
set_location_assignment PIN_DJ27 -to ddr4_mem[0].dq[35]
set_location_assignment PIN_DE25 -to ddr4_mem[0].dqs_n[9]
set_location_assignment PIN_DF24 -to ddr4_mem[0].dqs[9]
set_location_assignment PIN_DE23 -to ddr4_mem[0].dq[36]
set_location_assignment PIN_DF22 -to ddr4_mem[0].dq[37]
set_location_assignment PIN_DJ23 -to ddr4_mem[0].dq[38]
set_location_assignment PIN_DH22 -to ddr4_mem[0].dq[39]

# CH0 DQS5
set_location_assignment PIN_DC17 -to ddr4_mem[0].dqs_n[10]
set_location_assignment PIN_DD16 -to ddr4_mem[0].dqs[10]
set_location_assignment PIN_DC19 -to ddr4_mem[0].dq[40]
set_location_assignment PIN_DD18 -to ddr4_mem[0].dq[41]
set_location_assignment PIN_CY18 -to ddr4_mem[0].dq[42]
set_location_assignment PIN_DA19 -to ddr4_mem[0].dq[43]
set_location_assignment PIN_DA17 -to ddr4_mem[0].dqs_n[11]
set_location_assignment PIN_CY16 -to ddr4_mem[0].dqs[11]
set_location_assignment PIN_CY14 -to ddr4_mem[0].dq[44]
set_location_assignment PIN_DA15 -to ddr4_mem[0].dq[45]
set_location_assignment PIN_DC15 -to ddr4_mem[0].dq[46]
set_location_assignment PIN_DD14 -to ddr4_mem[0].dq[47]

# CH0 DQS6
set_location_assignment PIN_DC23 -to ddr4_mem[0].dqs_n[12]
set_location_assignment PIN_DD22 -to ddr4_mem[0].dqs[12]
set_location_assignment PIN_CY24 -to ddr4_mem[0].dq[48]
set_location_assignment PIN_DD24 -to ddr4_mem[0].dq[49]
set_location_assignment PIN_DC25 -to ddr4_mem[0].dq[50]
set_location_assignment PIN_DA25 -to ddr4_mem[0].dq[51]
set_location_assignment PIN_DA23 -to ddr4_mem[0].dqs_n[13]
set_location_assignment PIN_CY22 -to ddr4_mem[0].dqs[13]
set_location_assignment PIN_CY20 -to ddr4_mem[0].dq[52]
set_location_assignment PIN_DC21 -to ddr4_mem[0].dq[53]
set_location_assignment PIN_DA21 -to ddr4_mem[0].dq[54]
set_location_assignment PIN_DD20 -to ddr4_mem[0].dq[55]

# CH0 DQS7
set_location_assignment PIN_DC11 -to ddr4_mem[0].dqs_n[14]
set_location_assignment PIN_DD10 -to ddr4_mem[0].dqs[14]
set_location_assignment PIN_CY12 -to ddr4_mem[0].dq[56]
set_location_assignment PIN_DC13 -to ddr4_mem[0].dq[57]
set_location_assignment PIN_DA13 -to ddr4_mem[0].dq[58]
set_location_assignment PIN_DD12 -to ddr4_mem[0].dq[59]
set_location_assignment PIN_DA11 -to ddr4_mem[0].dqs_n[15]
set_location_assignment PIN_CY10 -to ddr4_mem[0].dqs[15]
set_location_assignment PIN_DC9  -to ddr4_mem[0].dq[60]
set_location_assignment PIN_DA9  -to ddr4_mem[0].dq[61]
set_location_assignment PIN_CY8  -to ddr4_mem[0].dq[62]
set_location_assignment PIN_DD8  -to ddr4_mem[0].dq[63]

# CH0 DQS8
set_location_assignment PIN_CW21 -to ddr4_mem[0].dqs_n[16]
set_location_assignment PIN_CV20 -to ddr4_mem[0].dqs[16]
set_location_assignment PIN_CW23 -to ddr4_mem[0].dq[64]
set_location_assignment PIN_CV22 -to ddr4_mem[0].dq[65]
set_location_assignment PIN_CT22 -to ddr4_mem[0].dq[66]
set_location_assignment PIN_CR23 -to ddr4_mem[0].dq[67]
set_location_assignment PIN_CR21 -to ddr4_mem[0].dqs_n[17]
set_location_assignment PIN_CT20 -to ddr4_mem[0].dqs[17]
set_location_assignment PIN_CR19 -to ddr4_mem[0].dq[68]
set_location_assignment PIN_CV18 -to ddr4_mem[0].dq[69]
set_location_assignment PIN_CW19 -to ddr4_mem[0].dq[70]
set_location_assignment PIN_CT18 -to ddr4_mem[0].dq[71]

#-----------------------------------------------------------------------------
# EMIF HPS
#-----------------------------------------------------------------------------
set_location_assignment PIN_T6  -to "ddr4_mem_ref_clk[1].clk(n)"
set_location_assignment PIN_U5  -to ddr4_mem_ref_clk[1].clk
set_location_assignment PIN_W5  -to ddr4_mem_ref_clk[1].oct_rzqin
set_location_assignment PIN_L11 -to ddr4_mem_group_1[0].bg[1]
set_location_assignment PIN_Y2  -to ddr4_mem_group_1[0].bg[0]
set_location_assignment PIN_W1  -to ddr4_mem_group_1[0].ba[1]
set_location_assignment PIN_T2  -to ddr4_mem_group_1[0].ba[0]
set_location_assignment PIN_U1  -to ddr4_mem_group_1[0].alert_n
set_location_assignment PIN_Y4  -to ddr4_mem_group_1[0].a[16]
set_location_assignment PIN_W3  -to ddr4_mem_group_1[0].a[15]
set_location_assignment PIN_T4  -to ddr4_mem_group_1[0].a[14]
set_location_assignment PIN_U3  -to ddr4_mem_group_1[0].a[13]
set_location_assignment PIN_Y6  -to ddr4_mem_group_1[0].a[12]
set_location_assignment PIN_Y8  -to ddr4_mem_group_1[0].a[11]
set_location_assignment PIN_W7  -to ddr4_mem_group_1[0].a[10]
set_location_assignment PIN_T8  -to ddr4_mem_group_1[0].a[9]
set_location_assignment PIN_U7  -to ddr4_mem_group_1[0].a[8]
set_location_assignment PIN_Y10 -to ddr4_mem_group_1[0].a[7]
set_location_assignment PIN_W9  -to ddr4_mem_group_1[0].a[6]
set_location_assignment PIN_T10 -to ddr4_mem_group_1[0].a[5]
set_location_assignment PIN_U9  -to ddr4_mem_group_1[0].a[4]
set_location_assignment PIN_Y12 -to ddr4_mem_group_1[0].a[3]
set_location_assignment PIN_W11 -to ddr4_mem_group_1[0].a[2]
set_location_assignment PIN_T12 -to ddr4_mem_group_1[0].a[1]
set_location_assignment PIN_U11 -to ddr4_mem_group_1[0].a[0]
set_location_assignment PIN_P8  -to ddr4_mem_group_1[0].par
set_location_assignment PIN_M8  -to ddr4_mem_group_1[0].ck_n
set_location_assignment PIN_L7  -to ddr4_mem_group_1[0].ck
set_location_assignment PIN_R9  -to ddr4_mem_group_1[0].cke
set_location_assignment PIN_L9  -to ddr4_mem_group_1[0].odt
set_location_assignment PIN_P12 -to ddr4_mem_group_1[0].act_n
set_location_assignment PIN_R11 -to ddr4_mem_group_1[0].cs_n
set_location_assignment PIN_M12 -to ddr4_mem_group_1[0].reset_n

# HPS DQS0
set_location_assignment PIN_J9 -to ddr4_mem_group_1[0].dbi_n[0]
set_location_assignment PIN_F10 -to ddr4_mem_group_1[0].dqs_n[0]
set_location_assignment PIN_G9 -to ddr4_mem_group_1[0].dqs[0]
set_location_assignment PIN_F12 -to ddr4_mem_group_1[0].dq[0]
set_location_assignment PIN_F8 -to ddr4_mem_group_1[0].dq[1]
set_location_assignment PIN_G11 -to ddr4_mem_group_1[0].dq[2]
set_location_assignment PIN_K8 -to ddr4_mem_group_1[0].dq[3]
set_location_assignment PIN_J11 -to ddr4_mem_group_1[0].dq[4]
set_location_assignment PIN_G7 -to ddr4_mem_group_1[0].dq[5]
set_location_assignment PIN_K12 -to ddr4_mem_group_1[0].dq[6]
set_location_assignment PIN_J7 -to ddr4_mem_group_1[0].dq[7]

# HPS DQS1
set_location_assignment PIN_R3 -to ddr4_mem_group_1[0].dbi_n[1]
set_location_assignment PIN_M4 -to ddr4_mem_group_1[0].dqs_n[1]
set_location_assignment PIN_L3 -to ddr4_mem_group_1[0].dqs[1]
set_location_assignment PIN_M6 -to ddr4_mem_group_1[0].dq[8]
set_location_assignment PIN_P2 -to ddr4_mem_group_1[0].dq[9]
set_location_assignment PIN_L5 -to ddr4_mem_group_1[0].dq[10]
set_location_assignment PIN_R1 -to ddr4_mem_group_1[0].dq[11]
set_location_assignment PIN_P6 -to ddr4_mem_group_1[0].dq[12]
set_location_assignment PIN_M2 -to ddr4_mem_group_1[0].dq[14]
set_location_assignment PIN_R5 -to ddr4_mem_group_1[0].dq[13]
set_location_assignment PIN_L1 -to ddr4_mem_group_1[0].dq[15]

# HPS DQS2
set_location_assignment PIN_E7 -to ddr4_mem_group_1[0].dbi_n[2]
set_location_assignment PIN_B8 -to ddr4_mem_group_1[0].dqs_n[2]
set_location_assignment PIN_A7 -to ddr4_mem_group_1[0].dqs[2]
set_location_assignment PIN_A9 -to ddr4_mem_group_1[0].dq[16]
set_location_assignment PIN_B6 -to ddr4_mem_group_1[0].dq[17]
set_location_assignment PIN_E9 -to ddr4_mem_group_1[0].dq[18]
set_location_assignment PIN_D6 -to ddr4_mem_group_1[0].dq[19]
set_location_assignment PIN_D10 -to ddr4_mem_group_1[0].dq[20]
set_location_assignment PIN_C5 -to ddr4_mem_group_1[0].dq[21]
set_location_assignment PIN_B10 -to ddr4_mem_group_1[0].dq[22]
set_location_assignment PIN_E5 -to ddr4_mem_group_1[0].dq[23]

# HPS DQS3
set_location_assignment PIN_J3 -to ddr4_mem_group_1[0].dbi_n[3]
set_location_assignment PIN_F4 -to ddr4_mem_group_1[0].dqs_n[3]
set_location_assignment PIN_G3 -to ddr4_mem_group_1[0].dqs[3]
set_location_assignment PIN_G5 -to ddr4_mem_group_1[0].dq[30]
set_location_assignment PIN_K2 -to ddr4_mem_group_1[0].dq[27]
set_location_assignment PIN_J1 -to ddr4_mem_group_1[0].dq[25]
set_location_assignment PIN_F6 -to ddr4_mem_group_1[0].dq[24]
set_location_assignment PIN_J5 -to ddr4_mem_group_1[0].dq[29]
set_location_assignment PIN_K6 -to ddr4_mem_group_1[0].dq[28]
set_location_assignment PIN_G1 -to ddr4_mem_group_1[0].dq[31]
set_location_assignment PIN_F2 -to ddr4_mem_group_1[0].dq[26]

# HPS DQS4 (ECC)
set_location_assignment PIN_AA3 -to ddr4_mem_group_1[0].dbi_n[4]
set_location_assignment PIN_AB6 -to ddr4_mem_group_1[0].dqs_n[4]
set_location_assignment PIN_AA5 -to ddr4_mem_group_1[0].dqs[4]
set_location_assignment PIN_AD2 -to ddr4_mem_group_1[0].dq[33]
set_location_assignment PIN_AA7 -to ddr4_mem_group_1[0].dq[32]
set_location_assignment PIN_AB2 -to ddr4_mem_group_1[0].dq[34]
set_location_assignment PIN_AB8 -to ddr4_mem_group_1[0].dq[35]
set_location_assignment PIN_AA1 -to ddr4_mem_group_1[0].dq[36]
set_location_assignment PIN_AE7 -to ddr4_mem_group_1[0].dq[37]
set_location_assignment PIN_AE1 -to ddr4_mem_group_1[0].dq[38]
set_location_assignment PIN_AD6 -to ddr4_mem_group_1[0].dq[39]
