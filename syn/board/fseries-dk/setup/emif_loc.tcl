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
set_location_assignment PIN_CW29 -to "ddr4_mem[0].ref_clk(n)"
set_location_assignment PIN_CV28 -to ddr4_mem[0].ref_clk
set_location_assignment PIN_CP34 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_CR25 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_CT24 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_CW25 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_CK34 -to ddr4_mem[0].cs_n[0]
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
set_location_assignment PIN_CN31 -to ddr4_mem[0].ck_n[0]
set_location_assignment PIN_CP30 -to ddr4_mem[0].ck[0]
set_location_assignment PIN_CK32 -to ddr4_mem[0].cke[0]
set_location_assignment PIN_CP32 -to ddr4_mem[0].odt[0]
set_location_assignment PIN_CL35 -to ddr4_mem[0].act_n
set_location_assignment PIN_CP24 -to ddr4_mem[0].alert_n
set_location_assignment PIN_CT28 -to ddr4_mem[0].oct_rzqin
set_location_assignment PIN_CL31 -to ddr4_mem[0].par
set_location_assignment PIN_CN35 -to ddr4_mem[0].reset_n

# CH0 DQS0
set_location_assignment PIN_CY28 -to ddr4_mem[0].dbi_n[0]
set_location_assignment PIN_DC29 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_DD28 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_DC31 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_DD30 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_CY30 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_DA31 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_DA27 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_CY26 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_DC27 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_DD26 -to ddr4_mem[0].dq[7]

# CH0 DQS1
set_location_assignment PIN_DF18 -to ddr4_mem[0].dbi_n[1]
set_location_assignment PIN_DJ19 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_DH18 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_DF20 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_DJ21 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_DH20 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_DE21 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_DF16 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_DH16 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_DE17 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_DJ17 -to ddr4_mem[0].dq[15]

# CH0 DQS2
set_location_assignment PIN_DF6 -to ddr4_mem[0].dbi_n[2]
set_location_assignment PIN_DJ7 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_DH6 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_DF8 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_DH8 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_DE9 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_DJ9 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_DF2 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_DE3 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_DF4 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_DE5 -to ddr4_mem[0].dq[23]

# CH0 DQS3
set_location_assignment PIN_DF12 -to ddr4_mem[0].dbi_n[3]
set_location_assignment PIN_DJ13 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_DH12 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_DE15 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_DF14 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_DJ15 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_DH14 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_DF10 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_DH10 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_DJ11 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_DE11 -to ddr4_mem[0].dq[31]

# CH0 DQS4
set_location_assignment PIN_DF24 -to ddr4_mem[0].dbi_n[4]
set_location_assignment PIN_DJ25 -to ddr4_mem[0].dqs_n[4]
set_location_assignment PIN_DH24 -to ddr4_mem[0].dqs[4]
set_location_assignment PIN_DH26 -to ddr4_mem[0].dq[32]
set_location_assignment PIN_DE27 -to ddr4_mem[0].dq[33]
set_location_assignment PIN_DF26 -to ddr4_mem[0].dq[34]
set_location_assignment PIN_DJ27 -to ddr4_mem[0].dq[35]
set_location_assignment PIN_DE23 -to ddr4_mem[0].dq[36]
set_location_assignment PIN_DF22 -to ddr4_mem[0].dq[37]
set_location_assignment PIN_DJ23 -to ddr4_mem[0].dq[38]
set_location_assignment PIN_DH22 -to ddr4_mem[0].dq[39]

# CH0 DQS5
set_location_assignment PIN_CY16 -to ddr4_mem[0].dbi_n[5]
set_location_assignment PIN_DC17 -to ddr4_mem[0].dqs_n[5]
set_location_assignment PIN_DD16 -to ddr4_mem[0].dqs[5]
set_location_assignment PIN_DC19 -to ddr4_mem[0].dq[40]
set_location_assignment PIN_DD18 -to ddr4_mem[0].dq[41]
set_location_assignment PIN_CY18 -to ddr4_mem[0].dq[42]
set_location_assignment PIN_DA19 -to ddr4_mem[0].dq[43]
set_location_assignment PIN_CY14 -to ddr4_mem[0].dq[44]
set_location_assignment PIN_DA15 -to ddr4_mem[0].dq[45]
set_location_assignment PIN_DC15 -to ddr4_mem[0].dq[46]
set_location_assignment PIN_DD14 -to ddr4_mem[0].dq[47]

# CH0 DQS6
set_location_assignment PIN_CY22 -to ddr4_mem[0].dbi_n[6]
set_location_assignment PIN_DC23 -to ddr4_mem[0].dqs_n[6]
set_location_assignment PIN_DD22 -to ddr4_mem[0].dqs[6]
set_location_assignment PIN_CY24 -to ddr4_mem[0].dq[48]
set_location_assignment PIN_DD24 -to ddr4_mem[0].dq[49]
set_location_assignment PIN_DC25 -to ddr4_mem[0].dq[50]
set_location_assignment PIN_DA25 -to ddr4_mem[0].dq[51]
set_location_assignment PIN_CY20 -to ddr4_mem[0].dq[52]
set_location_assignment PIN_DC21 -to ddr4_mem[0].dq[53]
set_location_assignment PIN_DA21 -to ddr4_mem[0].dq[54]
set_location_assignment PIN_DD20 -to ddr4_mem[0].dq[55]

# CH0 DQS7
set_location_assignment PIN_CY10 -to ddr4_mem[0].dbi_n[7]
set_location_assignment PIN_DC11 -to ddr4_mem[0].dqs_n[7]
set_location_assignment PIN_DD10 -to ddr4_mem[0].dqs[7]
set_location_assignment PIN_CY12 -to ddr4_mem[0].dq[56]
set_location_assignment PIN_DC13 -to ddr4_mem[0].dq[57]
set_location_assignment PIN_DA13 -to ddr4_mem[0].dq[58]
set_location_assignment PIN_DD12 -to ddr4_mem[0].dq[59]
set_location_assignment PIN_DC9  -to ddr4_mem[0].dq[60]
set_location_assignment PIN_DA9  -to ddr4_mem[0].dq[61]
set_location_assignment PIN_CY8  -to ddr4_mem[0].dq[62]
set_location_assignment PIN_DD8  -to ddr4_mem[0].dq[63]

#-----------------------------------------------------------------------------
# EMIF CH1
#-----------------------------------------------------------------------------
set_location_assignment PIN_DC37 -to "ddr4_mem[1].ref_clk(n)"
set_location_assignment PIN_DD36 -to ddr4_mem[1].ref_clk
set_location_assignment PIN_DD42 -to ddr4_mem[1].bg[1]
set_location_assignment PIN_DA33 -to ddr4_mem[1].bg[0]
set_location_assignment PIN_CY32 -to ddr4_mem[1].ba[1]
set_location_assignment PIN_DC33 -to ddr4_mem[1].ba[0]
set_location_assignment PIN_CY42 -to ddr4_mem[1].cs_n[0]
set_location_assignment PIN_CV24 -to ddr4_mem[1].a[17]
set_location_assignment PIN_DA35 -to ddr4_mem[1].a[16]
set_location_assignment PIN_CY34 -to ddr4_mem[1].a[15]
set_location_assignment PIN_DC35 -to ddr4_mem[1].a[14]
set_location_assignment PIN_DD34 -to ddr4_mem[1].a[13]
set_location_assignment PIN_DA37 -to ddr4_mem[1].a[12]
set_location_assignment PIN_DE35 -to ddr4_mem[1].a[11]
set_location_assignment PIN_DF34 -to ddr4_mem[1].a[10]
set_location_assignment PIN_DJ35 -to ddr4_mem[1].a[9]
set_location_assignment PIN_DH34 -to ddr4_mem[1].a[8]
set_location_assignment PIN_DE37 -to ddr4_mem[1].a[7]
set_location_assignment PIN_DF36 -to ddr4_mem[1].a[6]
set_location_assignment PIN_DJ37 -to ddr4_mem[1].a[5]
set_location_assignment PIN_DH36 -to ddr4_mem[1].a[4]
set_location_assignment PIN_DE39 -to ddr4_mem[1].a[3]
set_location_assignment PIN_DF38 -to ddr4_mem[1].a[2]
set_location_assignment PIN_DJ39 -to ddr4_mem[1].a[1]
set_location_assignment PIN_DH38 -to ddr4_mem[1].a[0]
set_location_assignment PIN_DC39 -to ddr4_mem[1].ck_n[0]
set_location_assignment PIN_DD38 -to ddr4_mem[1].ck[0]
set_location_assignment PIN_CY40 -to ddr4_mem[1].cke[0]
set_location_assignment PIN_DD40 -to ddr4_mem[1].odt[0]
set_location_assignment PIN_DA43 -to ddr4_mem[1].act_n
set_location_assignment PIN_DH28 -to ddr4_mem[1].alert_n
set_location_assignment PIN_CY36 -to ddr4_mem[1].oct_rzqin
set_location_assignment PIN_DA39 -to ddr4_mem[1].par
set_location_assignment PIN_DC43 -to ddr4_mem[1].reset_n

# CH1 DQS0
set_location_assignment PIN_CK44 -to ddr4_mem[1].dbi_n[0]
set_location_assignment PIN_CN45 -to ddr4_mem[1].dqs_n[0]
set_location_assignment PIN_CP44 -to ddr4_mem[1].dqs[0]
set_location_assignment PIN_CK46 -to ddr4_mem[1].dq[0]
set_location_assignment PIN_CL47 -to ddr4_mem[1].dq[1]
set_location_assignment PIN_CN47 -to ddr4_mem[1].dq[2]
set_location_assignment PIN_CP46 -to ddr4_mem[1].dq[3]
set_location_assignment PIN_CL43 -to ddr4_mem[1].dq[4]
set_location_assignment PIN_CK42 -to ddr4_mem[1].dq[5]
set_location_assignment PIN_CN43 -to ddr4_mem[1].dq[6]
set_location_assignment PIN_CP42 -to ddr4_mem[1].dq[7]

# CH1 DQS1
set_location_assignment PIN_CY46 -to ddr4_mem[1].dbi_n[1]
set_location_assignment PIN_DC47 -to ddr4_mem[1].dqs_n[1]
set_location_assignment PIN_DD46 -to ddr4_mem[1].dqs[1]
set_location_assignment PIN_DA45 -to ddr4_mem[1].dq[8]
set_location_assignment PIN_DC45 -to ddr4_mem[1].dq[9]
set_location_assignment PIN_DD44 -to ddr4_mem[1].dq[10]
set_location_assignment PIN_CY44 -to ddr4_mem[1].dq[11]
set_location_assignment PIN_DA49 -to ddr4_mem[1].dq[12]
set_location_assignment PIN_CY48 -to ddr4_mem[1].dq[13]
set_location_assignment PIN_DD48 -to ddr4_mem[1].dq[14]
set_location_assignment PIN_DC49 -to ddr4_mem[1].dq[15]

# CH1 DQS2
set_location_assignment PIN_CK50 -to ddr4_mem[1].dbi_n[2]
set_location_assignment PIN_CN51 -to ddr4_mem[1].dqs_n[2]
set_location_assignment PIN_CP50 -to ddr4_mem[1].dqs[2]
set_location_assignment PIN_CN49 -to ddr4_mem[1].dq[16]
set_location_assignment PIN_CL49 -to ddr4_mem[1].dq[18]
set_location_assignment PIN_CP48 -to ddr4_mem[1].dq[17]
set_location_assignment PIN_CK48 -to ddr4_mem[1].dq[19]
set_location_assignment PIN_CM52 -to ddr4_mem[1].dq[20]
set_location_assignment PIN_CT52 -to ddr4_mem[1].dq[21]
set_location_assignment PIN_CN53 -to ddr4_mem[1].dq[22]
set_location_assignment PIN_CR53 -to ddr4_mem[1].dq[23]

# CH1 DQS3
set_location_assignment PIN_CT44 -to ddr4_mem[1].dbi_n[3]
set_location_assignment PIN_CW45 -to ddr4_mem[1].dqs_n[3]
set_location_assignment PIN_CV44 -to ddr4_mem[1].dqs[3]
set_location_assignment PIN_CR47 -to ddr4_mem[1].dq[24]
set_location_assignment PIN_CT46 -to ddr4_mem[1].dq[25]
set_location_assignment PIN_CV46 -to ddr4_mem[1].dq[26]
set_location_assignment PIN_CW47 -to ddr4_mem[1].dq[27]
set_location_assignment PIN_CW43 -to ddr4_mem[1].dq[28]
set_location_assignment PIN_CV42 -to ddr4_mem[1].dq[29]
set_location_assignment PIN_CR43 -to ddr4_mem[1].dq[30]
set_location_assignment PIN_CT42 -to ddr4_mem[1].dq[31]

# CH1 DQS4
set_location_assignment PIN_CT50 -to ddr4_mem[1].dbi_n[4]
set_location_assignment PIN_CW51 -to ddr4_mem[1].dqs_n[4]
set_location_assignment PIN_CV50 -to ddr4_mem[1].dqs[4]
set_location_assignment PIN_CV48 -to ddr4_mem[1].dq[32]
set_location_assignment PIN_CT48 -to ddr4_mem[1].dq[33]
set_location_assignment PIN_CW49 -to ddr4_mem[1].dq[34]
set_location_assignment PIN_CR49 -to ddr4_mem[1].dq[35]
set_location_assignment PIN_CW53 -to ddr4_mem[1].dq[36]
set_location_assignment PIN_CV52 -to ddr4_mem[1].dq[37]
set_location_assignment PIN_CW55 -to ddr4_mem[1].dq[38]
set_location_assignment PIN_CV54 -to ddr4_mem[1].dq[39]

# CH1 DQS5
set_location_assignment PIN_CY52 -to ddr4_mem[1].dbi_n[5]
set_location_assignment PIN_DC53 -to ddr4_mem[1].dqs_n[5]
set_location_assignment PIN_DD52 -to ddr4_mem[1].dqs[5]
set_location_assignment PIN_CY50 -to ddr4_mem[1].dq[40]
set_location_assignment PIN_DC51 -to ddr4_mem[1].dq[41]
set_location_assignment PIN_DA51 -to ddr4_mem[1].dq[42]
set_location_assignment PIN_DD50 -to ddr4_mem[1].dq[43]
set_location_assignment PIN_CY54 -to ddr4_mem[1].dq[44]
set_location_assignment PIN_DA55 -to ddr4_mem[1].dq[45]
set_location_assignment PIN_DD54 -to ddr4_mem[1].dq[46]
set_location_assignment PIN_DC55 -to ddr4_mem[1].dq[47]

# CH1 DQS6
set_location_assignment PIN_CK38 -to ddr4_mem[1].dbi_n[6]
set_location_assignment PIN_CN39 -to ddr4_mem[1].dqs_n[6]
set_location_assignment PIN_CP38 -to ddr4_mem[1].dqs[6]
set_location_assignment PIN_CL41 -to ddr4_mem[1].dq[48]
set_location_assignment PIN_CN41 -to ddr4_mem[1].dq[49]
set_location_assignment PIN_CK40 -to ddr4_mem[1].dq[50]
set_location_assignment PIN_CP40 -to ddr4_mem[1].dq[51]
set_location_assignment PIN_CK36 -to ddr4_mem[1].dq[52]
set_location_assignment PIN_CN37 -to ddr4_mem[1].dq[53]
set_location_assignment PIN_CL37 -to ddr4_mem[1].dq[54]
set_location_assignment PIN_CP36 -to ddr4_mem[1].dq[55]

# CH1 DQS7
set_location_assignment PIN_DF48 -to ddr4_mem[1].dbi_n[7]
set_location_assignment PIN_DJ49 -to ddr4_mem[1].dqs_n[7]
set_location_assignment PIN_DH48 -to ddr4_mem[1].dqs[7]
set_location_assignment PIN_DF46 -to ddr4_mem[1].dq[56]
set_location_assignment PIN_DE47 -to ddr4_mem[1].dq[57]
set_location_assignment PIN_DH46 -to ddr4_mem[1].dq[58]
set_location_assignment PIN_DJ47 -to ddr4_mem[1].dq[59]
set_location_assignment PIN_DE53 -to ddr4_mem[1].dq[60]
set_location_assignment PIN_DF52 -to ddr4_mem[1].dq[61]
set_location_assignment PIN_DG51 -to ddr4_mem[1].dq[62]
set_location_assignment PIN_DH50 -to ddr4_mem[1].dq[63]

#-----------------------------------------------------------------------------
# EMIF HPS
#-----------------------------------------------------------------------------
set_location_assignment PIN_T6  -to "ddr4_hps.ref_clk(n)"
set_location_assignment PIN_U5  -to ddr4_hps.ref_clk
set_location_assignment PIN_L11 -to ddr4_hps.bg[1]
set_location_assignment PIN_Y2  -to ddr4_hps.bg[0]
set_location_assignment PIN_W1  -to ddr4_hps.ba[1]
set_location_assignment PIN_T2  -to ddr4_hps.ba[0]
set_location_assignment PIN_U1  -to ddr4_hps.alert_n
set_location_assignment PIN_Y4  -to ddr4_hps.a[16]
set_location_assignment PIN_W3  -to ddr4_hps.a[15]
set_location_assignment PIN_T4  -to ddr4_hps.a[14]
set_location_assignment PIN_U3  -to ddr4_hps.a[13]
set_location_assignment PIN_Y6  -to ddr4_hps.a[12]
set_location_assignment PIN_W5  -to ddr4_hps.oct_rzqin
set_location_assignment PIN_Y8  -to ddr4_hps.a[11]
set_location_assignment PIN_W7  -to ddr4_hps.a[10]
set_location_assignment PIN_T8  -to ddr4_hps.a[9]
set_location_assignment PIN_U7  -to ddr4_hps.a[8]
set_location_assignment PIN_Y10 -to ddr4_hps.a[7]
set_location_assignment PIN_W9  -to ddr4_hps.a[6]
set_location_assignment PIN_T10 -to ddr4_hps.a[5]
set_location_assignment PIN_U9  -to ddr4_hps.a[4]
set_location_assignment PIN_Y12 -to ddr4_hps.a[3]
set_location_assignment PIN_W11 -to ddr4_hps.a[2]
set_location_assignment PIN_T12 -to ddr4_hps.a[1]
set_location_assignment PIN_U11 -to ddr4_hps.a[0]
set_location_assignment PIN_P8  -to ddr4_hps.par
set_location_assignment PIN_R11 -to ddr4_hps.cs_n[1]
set_location_assignment PIN_M8  -to ddr4_hps.ck_n
set_location_assignment PIN_L7  -to ddr4_hps.ck
set_location_assignment PIN_R9  -to ddr4_hps.cke
set_location_assignment PIN_L9  -to ddr4_hps.odt
set_location_assignment PIN_P12 -to ddr4_hps.act_n
set_location_assignment PIN_R11 -to ddr4_hps.cs_n[0]
set_location_assignment PIN_M12 -to ddr4_hps.reset_n

# HPS DQS0
set_location_assignment PIN_J9 -to ddr4_hps.dbi_n[0]
set_location_assignment PIN_F10 -to ddr4_hps.dqs_n[0]
set_location_assignment PIN_G9 -to ddr4_hps.dqs[0]
set_location_assignment PIN_F12 -to ddr4_hps.dq[0]
set_location_assignment PIN_F8 -to ddr4_hps.dq[1]
set_location_assignment PIN_G11 -to ddr4_hps.dq[2]
set_location_assignment PIN_K8 -to ddr4_hps.dq[3]
set_location_assignment PIN_J11 -to ddr4_hps.dq[4]
set_location_assignment PIN_G7 -to ddr4_hps.dq[5]
set_location_assignment PIN_K12 -to ddr4_hps.dq[6]
set_location_assignment PIN_J7 -to ddr4_hps.dq[7]

# HPS DQS1
set_location_assignment PIN_R3 -to ddr4_hps.dbi_n[1]
set_location_assignment PIN_M4 -to ddr4_hps.dqs_n[1]
set_location_assignment PIN_L3 -to ddr4_hps.dqs[1]
set_location_assignment PIN_M6 -to ddr4_hps.dq[8]
set_location_assignment PIN_P2 -to ddr4_hps.dq[9]
set_location_assignment PIN_L5 -to ddr4_hps.dq[10]
set_location_assignment PIN_R1 -to ddr4_hps.dq[11]
set_location_assignment PIN_P6 -to ddr4_hps.dq[12]
set_location_assignment PIN_M2 -to ddr4_hps.dq[14]
set_location_assignment PIN_R5 -to ddr4_hps.dq[13]
set_location_assignment PIN_L1 -to ddr4_hps.dq[15]

# HPS DQS2
set_location_assignment PIN_E7 -to ddr4_hps.dbi_n[2]
set_location_assignment PIN_B8 -to ddr4_hps.dqs_n[2]
set_location_assignment PIN_A7 -to ddr4_hps.dqs[2]
set_location_assignment PIN_A9 -to ddr4_hps.dq[16]
set_location_assignment PIN_B6 -to ddr4_hps.dq[17]
set_location_assignment PIN_E9 -to ddr4_hps.dq[18]
set_location_assignment PIN_D6 -to ddr4_hps.dq[19]
set_location_assignment PIN_D10 -to ddr4_hps.dq[20]
set_location_assignment PIN_C5 -to ddr4_hps.dq[21]
set_location_assignment PIN_B10 -to ddr4_hps.dq[22]
set_location_assignment PIN_E5 -to ddr4_hps.dq[23]

# HPS DQS3
set_location_assignment PIN_J3 -to ddr4_hps.dbi_n[3]
set_location_assignment PIN_F4 -to ddr4_hps.dqs_n[3]
set_location_assignment PIN_G3 -to ddr4_hps.dqs[3]
set_location_assignment PIN_G5 -to ddr4_hps.dq[30]
set_location_assignment PIN_K2 -to ddr4_hps.dq[27]
set_location_assignment PIN_J1 -to ddr4_hps.dq[25]
set_location_assignment PIN_F6 -to ddr4_hps.dq[24]
set_location_assignment PIN_J5 -to ddr4_hps.dq[29]
set_location_assignment PIN_K6 -to ddr4_hps.dq[28]
set_location_assignment PIN_G1 -to ddr4_hps.dq[31]
set_location_assignment PIN_F2 -to ddr4_hps.dq[26]

# HPS DQS4 (ECC)
set_location_assignment PIN_AA3 -to ddr4_hps.dbi_n[4]
set_location_assignment PIN_AB6 -to ddr4_hps.dqs_n[4]
set_location_assignment PIN_AA5 -to ddr4_hps.dqs[4]
set_location_assignment PIN_AD2 -to ddr4_hps.dq[33]
set_location_assignment PIN_AA7 -to ddr4_hps.dq[32]
set_location_assignment PIN_AB2 -to ddr4_hps.dq[34]
set_location_assignment PIN_AB8 -to ddr4_hps.dq[35]
set_location_assignment PIN_AA1 -to ddr4_hps.dq[36]
set_location_assignment PIN_AE7 -to ddr4_hps.dq[37]
set_location_assignment PIN_AE1 -to ddr4_hps.dq[38]
set_location_assignment PIN_AD6 -to ddr4_hps.dq[39]
