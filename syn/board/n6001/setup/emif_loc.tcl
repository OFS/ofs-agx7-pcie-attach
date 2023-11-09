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
set_location_assignment PIN_DA52 -to "ddr4_mem[0].ref_clk(n)"
set_location_assignment PIN_DC52 -to ddr4_mem[0].ref_clk
set_location_assignment PIN_CY57 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_DB57 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_DA56 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_DC56 -to ddr4_mem[0].alert_n
set_location_assignment PIN_CY55 -to ddr4_mem[0].a[16]
set_location_assignment PIN_DB55 -to ddr4_mem[0].a[15]
set_location_assignment PIN_DA54 -to ddr4_mem[0].a[14]
set_location_assignment PIN_DC54 -to ddr4_mem[0].a[13]
set_location_assignment PIN_CY53 -to ddr4_mem[0].a[12]
set_location_assignment PIN_DB53 -to ddr4_mem[0].oct_rzqin
set_location_assignment PIN_CR50 -to ddr4_mem[0].a[11]
set_location_assignment PIN_CU50 -to ddr4_mem[0].a[10]
set_location_assignment PIN_CT49 -to ddr4_mem[0].a[9]
set_location_assignment PIN_CV49 -to ddr4_mem[0].a[8]
set_location_assignment PIN_CR48 -to ddr4_mem[0].a[7]
set_location_assignment PIN_CU48 -to ddr4_mem[0].a[6]
set_location_assignment PIN_CT47 -to ddr4_mem[0].a[5]
set_location_assignment PIN_CV47 -to ddr4_mem[0].a[4]
set_location_assignment PIN_CR46 -to ddr4_mem[0].a[3]
set_location_assignment PIN_CU46 -to ddr4_mem[0].a[2]
set_location_assignment PIN_CT45 -to ddr4_mem[0].a[1]
set_location_assignment PIN_CV45 -to ddr4_mem[0].a[0]
set_location_assignment PIN_DA50 -to ddr4_mem[0].par
set_location_assignment PIN_DC50 -to ddr4_mem[0].cs_n[1]
set_location_assignment PIN_CY49 -to ddr4_mem[0].ck_n
set_location_assignment PIN_DB49 -to ddr4_mem[0].ck
set_location_assignment PIN_DC48 -to ddr4_mem[0].cke
set_location_assignment PIN_DB47 -to ddr4_mem[0].odt
set_location_assignment PIN_DA46 -to ddr4_mem[0].act_n
set_location_assignment PIN_DC46 -to ddr4_mem[0].cs_n[0]
set_location_assignment PIN_CY45 -to ddr4_mem[0].reset_n

# CH0 DQS0
set_location_assignment PIN_CH55 -to ddr4_mem[0].dbi_n[0]
set_location_assignment PIN_CE54 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_CG54 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_CG56 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_CF53 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_CH57 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_CG52 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_CE56 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_CH53 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_CF57 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_CE52 -to ddr4_mem[0].dq[7]

# CH0 DQS1
set_location_assignment PIN_CM55 -to ddr4_mem[0].dbi_n[1]
set_location_assignment PIN_CL54 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_CN54 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_CL52 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_CN52 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_CM53 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_CN56 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_CL56 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_CM57 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_CK57 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_CK53 -to ddr4_mem[0].dq[15]

# CH0 DQS2
set_location_assignment PIN_CV55 -to ddr4_mem[0].dbi_n[2]
set_location_assignment PIN_CR54 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_CU54 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_CU56 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_CV53 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_CT57 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_CT53 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_CU52 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_CR52 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_CR56 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_CV57 -to ddr4_mem[0].dq[23]

# CH0 DQS3
set_location_assignment PIN_CN48 -to ddr4_mem[0].dbi_n[3]
set_location_assignment PIN_CK47 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_CM47 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_CL50 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_CK49 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_CK45 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_CL46 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_CN46 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_CM49 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_CN50 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_CM45 -to ddr4_mem[0].dq[31]


#-----------------------------------------------------------------------------
# EMIF CH1
#-----------------------------------------------------------------------------
set_location_assignment PIN_CL38 -to "ddr4_mem[1].ref_clk(n)"
set_location_assignment PIN_CN38 -to ddr4_mem[1].ref_clk
set_location_assignment PIN_CK43 -to ddr4_mem[1].bg[0]
set_location_assignment PIN_CM43 -to ddr4_mem[1].ba[1]
set_location_assignment PIN_CL42 -to ddr4_mem[1].ba[0]
set_location_assignment PIN_CN42 -to ddr4_mem[1].alert_n
set_location_assignment PIN_CK41 -to ddr4_mem[1].a[16]
set_location_assignment PIN_CM41 -to ddr4_mem[1].a[15]
set_location_assignment PIN_CL40 -to ddr4_mem[1].a[14]
set_location_assignment PIN_CN40 -to ddr4_mem[1].a[13]
set_location_assignment PIN_CK39 -to ddr4_mem[1].a[12]
set_location_assignment PIN_CM39 -to ddr4_mem[1].oct_rzqin
set_location_assignment PIN_CE36 -to ddr4_mem[1].a[11]
set_location_assignment PIN_CG36 -to ddr4_mem[1].a[10]
set_location_assignment PIN_CF35 -to ddr4_mem[1].a[9]
set_location_assignment PIN_CH35 -to ddr4_mem[1].a[8]
set_location_assignment PIN_CE34 -to ddr4_mem[1].a[7]
set_location_assignment PIN_CG34 -to ddr4_mem[1].a[6]
set_location_assignment PIN_CF33 -to ddr4_mem[1].a[5]
set_location_assignment PIN_CH33 -to ddr4_mem[1].a[4]
set_location_assignment PIN_CE32 -to ddr4_mem[1].a[3]
set_location_assignment PIN_CG32 -to ddr4_mem[1].a[2]
set_location_assignment PIN_CF31 -to ddr4_mem[1].a[1]
set_location_assignment PIN_CH31 -to ddr4_mem[1].a[0]
set_location_assignment PIN_CL36 -to ddr4_mem[1].par
set_location_assignment PIN_CN36 -to ddr4_mem[1].cs_n[1]
set_location_assignment PIN_CK35 -to ddr4_mem[1].ck_n
set_location_assignment PIN_CM35 -to ddr4_mem[1].ck
set_location_assignment PIN_CN34 -to ddr4_mem[1].cke
set_location_assignment PIN_CM33 -to ddr4_mem[1].odt
set_location_assignment PIN_CL32 -to ddr4_mem[1].act_n
set_location_assignment PIN_CN32 -to ddr4_mem[1].cs_n[0]
set_location_assignment PIN_CK31 -to ddr4_mem[1].reset_n

# CH1 DQS0
set_location_assignment PIN_CH41 -to ddr4_mem[1].dbi_n[0]
set_location_assignment PIN_CE40 -to ddr4_mem[1].dqs_n[0]
set_location_assignment PIN_CG40 -to ddr4_mem[1].dqs[0]
set_location_assignment PIN_CF43 -to ddr4_mem[1].dq[3]
set_location_assignment PIN_CH43 -to ddr4_mem[1].dq[5]
set_location_assignment PIN_CE42 -to ddr4_mem[1].dq[2]
set_location_assignment PIN_CG42 -to ddr4_mem[1].dq[1]
set_location_assignment PIN_CF39 -to ddr4_mem[1].dq[4]
set_location_assignment PIN_CH39 -to ddr4_mem[1].dq[7]
set_location_assignment PIN_CE38 -to ddr4_mem[1].dq[6]
set_location_assignment PIN_CG38 -to ddr4_mem[1].dq[0]

# CH1 DQS1
set_location_assignment PIN_CU34 -to ddr4_mem[1].dbi_n[1]
set_location_assignment PIN_CT33 -to ddr4_mem[1].dqs_n[1]
set_location_assignment PIN_CV33 -to ddr4_mem[1].dqs[1]
set_location_assignment PIN_CU32 -to ddr4_mem[1].dq[8]
set_location_assignment PIN_CU36 -to ddr4_mem[1].dq[9]
set_location_assignment PIN_CV31 -to ddr4_mem[1].dq[10]
set_location_assignment PIN_CR32 -to ddr4_mem[1].dq[11]
set_location_assignment PIN_CV35 -to ddr4_mem[1].dq[12]
set_location_assignment PIN_CR36 -to ddr4_mem[1].dq[13]
set_location_assignment PIN_CT35 -to ddr4_mem[1].dq[14]
set_location_assignment PIN_CT31 -to ddr4_mem[1].dq[15]

# CH1 DQS2
set_location_assignment PIN_DB41 -to ddr4_mem[1].dbi_n[2]
set_location_assignment PIN_DA40 -to ddr4_mem[1].dqs_n[2]
set_location_assignment PIN_DC40 -to ddr4_mem[1].dqs[2]
set_location_assignment PIN_DC42 -to ddr4_mem[1].dq[16]
set_location_assignment PIN_DB43 -to ddr4_mem[1].dq[18]
set_location_assignment PIN_DA38 -to ddr4_mem[1].dq[17]
set_location_assignment PIN_CY39 -to ddr4_mem[1].dq[19]
set_location_assignment PIN_DA42 -to ddr4_mem[1].dq[20]
set_location_assignment PIN_DC38 -to ddr4_mem[1].dq[21]
set_location_assignment PIN_CY43 -to ddr4_mem[1].dq[22]
set_location_assignment PIN_DB39 -to ddr4_mem[1].dq[23]

# CH1 DQS3
set_location_assignment PIN_CV41 -to ddr4_mem[1].dbi_n[3]
set_location_assignment PIN_CR40 -to ddr4_mem[1].dqs_n[3]
set_location_assignment PIN_CU40 -to ddr4_mem[1].dqs[3]
set_location_assignment PIN_CR42 -to ddr4_mem[1].dq[24]
set_location_assignment PIN_CU38 -to ddr4_mem[1].dq[25]
set_location_assignment PIN_CV43 -to ddr4_mem[1].dq[26]
set_location_assignment PIN_CT39 -to ddr4_mem[1].dq[27]
set_location_assignment PIN_CT43 -to ddr4_mem[1].dq[28]
set_location_assignment PIN_CV39 -to ddr4_mem[1].dq[29]
set_location_assignment PIN_CU42 -to ddr4_mem[1].dq[30]
set_location_assignment PIN_CR38 -to ddr4_mem[1].dq[31]


#-----------------------------------------------------------------------------
# EMIF CH2
#-----------------------------------------------------------------------------
set_location_assignment PIN_P45 -to ddr4_mem[2].bg[0]
set_location_assignment PIN_M45 -to ddr4_mem[2].ba[1]
set_location_assignment PIN_N44 -to ddr4_mem[2].ba[0]
set_location_assignment PIN_L44 -to ddr4_mem[2].alert_n
set_location_assignment PIN_P43 -to ddr4_mem[2].a[16]
set_location_assignment PIN_M43 -to ddr4_mem[2].a[15]
set_location_assignment PIN_N42 -to ddr4_mem[2].a[14]
set_location_assignment PIN_L42 -to ddr4_mem[2].a[13]
set_location_assignment PIN_P41 -to ddr4_mem[2].a[12]
set_location_assignment PIN_M41 -to ddr4_mem[2].oct_rzqin
set_location_assignment PIN_N40 -to "ddr4_mem[2].ref_clk(n)"
set_location_assignment PIN_L40 -to ddr4_mem[2].ref_clk
set_location_assignment PIN_W38 -to ddr4_mem[2].a[11]
set_location_assignment PIN_U38 -to ddr4_mem[2].a[10]
set_location_assignment PIN_V37 -to ddr4_mem[2].a[9]
set_location_assignment PIN_T37 -to ddr4_mem[2].a[8]
set_location_assignment PIN_W36 -to ddr4_mem[2].a[7]
set_location_assignment PIN_U36 -to ddr4_mem[2].a[6]
set_location_assignment PIN_V35 -to ddr4_mem[2].a[5]
set_location_assignment PIN_T35 -to ddr4_mem[2].a[4]
set_location_assignment PIN_W34 -to ddr4_mem[2].a[3]
set_location_assignment PIN_U34 -to ddr4_mem[2].a[2]
set_location_assignment PIN_V33 -to ddr4_mem[2].a[1]
set_location_assignment PIN_T33 -to ddr4_mem[2].a[0]
set_location_assignment PIN_N38 -to ddr4_mem[2].par
set_location_assignment PIN_L38 -to ddr4_mem[2].cs_n[1]
set_location_assignment PIN_P37 -to ddr4_mem[2].ck_n
set_location_assignment PIN_M37 -to ddr4_mem[2].ck
set_location_assignment PIN_L36 -to ddr4_mem[2].cke
set_location_assignment PIN_M35 -to ddr4_mem[2].odt
set_location_assignment PIN_N34 -to ddr4_mem[2].act_n
set_location_assignment PIN_L34 -to ddr4_mem[2].cs_n[0]
set_location_assignment PIN_P33 -to ddr4_mem[2].reset_n

# CH2 DQS0
set_location_assignment PIN_J42 -to ddr4_mem[2].dqs_n[0]
set_location_assignment PIN_F43 -to ddr4_mem[2].dbi_n[0]
set_location_assignment PIN_G42 -to ddr4_mem[2].dqs[0]
set_location_assignment PIN_G44 -to ddr4_mem[2].dq[0]
set_location_assignment PIN_F41 -to ddr4_mem[2].dq[1]
set_location_assignment PIN_H45 -to ddr4_mem[2].dq[2]
set_location_assignment PIN_J44 -to ddr4_mem[2].dq[3]
set_location_assignment PIN_H41 -to ddr4_mem[2].dq[4]
set_location_assignment PIN_F45 -to ddr4_mem[2].dq[5]
set_location_assignment PIN_J40 -to ddr4_mem[2].dq[6]
set_location_assignment PIN_G40 -to ddr4_mem[2].dq[7]

# CH2 DQS1
set_location_assignment PIN_C42 -to ddr4_mem[2].dqs_n[1]
set_location_assignment PIN_B43 -to ddr4_mem[2].dbi_n[1]
set_location_assignment PIN_A42 -to ddr4_mem[2].dqs[1]
set_location_assignment PIN_C44 -to ddr4_mem[2].dq[8]
set_location_assignment PIN_A40 -to ddr4_mem[2].dq[9]
set_location_assignment PIN_B45 -to ddr4_mem[2].dq[10]
set_location_assignment PIN_B41 -to ddr4_mem[2].dq[11]
set_location_assignment PIN_A44 -to ddr4_mem[2].dq[12]
set_location_assignment PIN_C40 -to ddr4_mem[2].dq[13]
set_location_assignment PIN_D45 -to ddr4_mem[2].dq[14]
set_location_assignment PIN_D41 -to ddr4_mem[2].dq[15]

# CH2 DQS2
set_location_assignment PIN_T43 -to ddr4_mem[2].dbi_n[2]
set_location_assignment PIN_W42 -to ddr4_mem[2].dqs_n[2]
set_location_assignment PIN_U42 -to ddr4_mem[2].dqs[2]
set_location_assignment PIN_U44 -to ddr4_mem[2].dq[16]
set_location_assignment PIN_U40 -to ddr4_mem[2].dq[17]
set_location_assignment PIN_T41 -to ddr4_mem[2].dq[18]
set_location_assignment PIN_V45 -to ddr4_mem[2].dq[19]
set_location_assignment PIN_W44 -to ddr4_mem[2].dq[20]
set_location_assignment PIN_V41 -to ddr4_mem[2].dq[21]
set_location_assignment PIN_W40 -to ddr4_mem[2].dq[22]
set_location_assignment PIN_T45 -to ddr4_mem[2].dq[23]

# CH2 DQS3
set_location_assignment PIN_A36 -to ddr4_mem[2].dbi_n[3]
set_location_assignment PIN_D35 -to ddr4_mem[2].dqs_n[3]
set_location_assignment PIN_B35 -to ddr4_mem[2].dqs[3]
set_location_assignment PIN_C34 -to ddr4_mem[2].dq[24]
set_location_assignment PIN_D33 -to ddr4_mem[2].dq[25]
set_location_assignment PIN_A38 -to ddr4_mem[2].dq[26]
set_location_assignment PIN_A34 -to ddr4_mem[2].dq[27]
set_location_assignment PIN_B37 -to ddr4_mem[2].dq[28]
set_location_assignment PIN_D37 -to ddr4_mem[2].dq[29]
set_location_assignment PIN_B33 -to ddr4_mem[2].dq[30]
set_location_assignment PIN_C38 -to ddr4_mem[2].dq[31]

# CH2 DQS4 (ECC)
# set_location_assignment PIN_G36 -to ddr4_ecc_mem[0].dbi_n[4]
# set_location_assignment PIN_H35 -to ddr4_ecc_mem[0].dqs_n[4]
# set_location_assignment PIN_F35 -to ddr4_ecc_mem[0].dqs[4]
# set_location_assignment PIN_G38 -to ddr4_ecc_mem[0].dq[32]
# set_location_assignment PIN_J38 -to ddr4_ecc_mem[0].dq[33]
# set_location_assignment PIN_H33 -to ddr4_ecc_mem[0].dq[34]
# set_location_assignment PIN_J34 -to ddr4_ecc_mem[0].dq[35]
# set_location_assignment PIN_F33 -to ddr4_ecc_mem[0].dq[36]
# set_location_assignment PIN_H37 -to ddr4_ecc_mem[0].dq[37]
# set_location_assignment PIN_F37 -to ddr4_ecc_mem[0].dq[38]
# set_location_assignment PIN_G34 -to ddr4_ecc_mem[0].dq[39]


#-----------------------------------------------------------------------------
# EMIF CH3
#-----------------------------------------------------------------------------
set_location_assignment PIN_A54 -to ddr4_mem[3].ref_clk
set_location_assignment PIN_C54 -to "ddr4_mem[3].ref_clk(n)"
set_location_assignment PIN_H61 -to ddr4_mem[3].bg[0]
set_location_assignment PIN_F61 -to ddr4_mem[3].ba[1]
set_location_assignment PIN_D59 -to ddr4_mem[3].ba[0]
set_location_assignment PIN_C58 -to ddr4_mem[3].alert_n
set_location_assignment PIN_D57 -to ddr4_mem[3].a[16]
set_location_assignment PIN_B57 -to ddr4_mem[3].a[15]
set_location_assignment PIN_C56 -to ddr4_mem[3].a[14]
set_location_assignment PIN_A56 -to ddr4_mem[3].a[13]
set_location_assignment PIN_D55 -to ddr4_mem[3].a[12]
set_location_assignment PIN_B55 -to ddr4_mem[3].oct_rzqin
set_location_assignment PIN_J52 -to ddr4_mem[3].a[11]
set_location_assignment PIN_G52 -to ddr4_mem[3].a[10]
set_location_assignment PIN_H51 -to ddr4_mem[3].a[9]
set_location_assignment PIN_F51 -to ddr4_mem[3].a[8]
set_location_assignment PIN_J50 -to ddr4_mem[3].a[7]
set_location_assignment PIN_G50 -to ddr4_mem[3].a[6]
set_location_assignment PIN_H49 -to ddr4_mem[3].a[5]
set_location_assignment PIN_F49 -to ddr4_mem[3].a[4]
set_location_assignment PIN_J48 -to ddr4_mem[3].a[3]
set_location_assignment PIN_G48 -to ddr4_mem[3].a[2]
set_location_assignment PIN_H47 -to ddr4_mem[3].a[1]
set_location_assignment PIN_F47 -to ddr4_mem[3].a[0]
set_location_assignment PIN_C52 -to ddr4_mem[3].par
set_location_assignment PIN_A52 -to ddr4_mem[3].cs_n[1]
set_location_assignment PIN_D51 -to ddr4_mem[3].ck_n
set_location_assignment PIN_B51 -to ddr4_mem[3].ck
set_location_assignment PIN_A50 -to ddr4_mem[3].cke
set_location_assignment PIN_B49 -to ddr4_mem[3].odt
set_location_assignment PIN_C48 -to ddr4_mem[3].act_n
set_location_assignment PIN_A48 -to ddr4_mem[3].cs_n[0]
set_location_assignment PIN_D47 -to ddr4_mem[3].reset_n

# CH3 DQS0
set_location_assignment PIN_F57 -to ddr4_mem[3].dbi_n[0]
set_location_assignment PIN_J56 -to ddr4_mem[3].dqs_n[0]
set_location_assignment PIN_G56 -to ddr4_mem[3].dqs[0]
set_location_assignment PIN_G54 -to ddr4_mem[3].dq[0]
set_location_assignment PIN_H55 -to ddr4_mem[3].dq[1]
set_location_assignment PIN_J54 -to ddr4_mem[3].dq[2]
set_location_assignment PIN_F55 -to ddr4_mem[3].dq[3]
set_location_assignment PIN_G58 -to ddr4_mem[3].dq[4]
set_location_assignment PIN_J58 -to ddr4_mem[3].dq[5]
set_location_assignment PIN_F59 -to ddr4_mem[3].dq[6]
set_location_assignment PIN_H59 -to ddr4_mem[3].dq[7]

# CH3 DQS1
set_location_assignment PIN_M57 -to ddr4_mem[3].dbi_n[1]
set_location_assignment PIN_N56 -to ddr4_mem[3].dqs_n[1]
set_location_assignment PIN_L56 -to ddr4_mem[3].dqs[1]
set_location_assignment PIN_P59 -to ddr4_mem[3].dq[8]
set_location_assignment PIN_P55 -to ddr4_mem[3].dq[9]
set_location_assignment PIN_N58 -to ddr4_mem[3].dq[10]
set_location_assignment PIN_M55 -to ddr4_mem[3].dq[11]
set_location_assignment PIN_M59 -to ddr4_mem[3].dq[12]
set_location_assignment PIN_N54 -to ddr4_mem[3].dq[13]
set_location_assignment PIN_L58 -to ddr4_mem[3].dq[14]
set_location_assignment PIN_L54 -to ddr4_mem[3].dq[15]

# CH3 DQS2
set_location_assignment PIN_U50 -to ddr4_mem[3].dbi_n[2]
set_location_assignment PIN_V49 -to ddr4_mem[3].dqs_n[2]
set_location_assignment PIN_T49 -to ddr4_mem[3].dqs[2]
set_location_assignment PIN_U52 -to ddr4_mem[3].dq[16]
set_location_assignment PIN_W52 -to ddr4_mem[3].dq[17]
set_location_assignment PIN_V47 -to ddr4_mem[3].dq[18]
set_location_assignment PIN_W48 -to ddr4_mem[3].dq[19]
set_location_assignment PIN_T51 -to ddr4_mem[3].dq[20]
set_location_assignment PIN_V51 -to ddr4_mem[3].dq[21]
set_location_assignment PIN_T47 -to ddr4_mem[3].dq[22]
set_location_assignment PIN_U48 -to ddr4_mem[3].dq[23]

# CH3 DQS3
set_location_assignment PIN_T57 -to ddr4_mem[3].dbi_n[3]
set_location_assignment PIN_W56 -to ddr4_mem[3].dqs_n[3]
set_location_assignment PIN_U56 -to ddr4_mem[3].dqs[3]
set_location_assignment PIN_V59 -to ddr4_mem[3].dq[24]
set_location_assignment PIN_V55 -to ddr4_mem[3].dq[25]
set_location_assignment PIN_T55 -to ddr4_mem[3].dq[26]
set_location_assignment PIN_W54 -to ddr4_mem[3].dq[27]
set_location_assignment PIN_T59 -to ddr4_mem[3].dq[28]
set_location_assignment PIN_W58 -to ddr4_mem[3].dq[29]
set_location_assignment PIN_U54 -to ddr4_mem[3].dq[30]
set_location_assignment PIN_U58 -to ddr4_mem[3].dq[31]

# CH3 DQS4 (ECC)
# set_location_assignment PIN_L50 -to ddr4_ecc_mem[1].dbi_n[4]
# set_location_assignment PIN_P49 -to ddr4_ecc_mem[1].dqs_n[4]
# set_location_assignment PIN_M49 -to ddr4_ecc_mem[1].dqs[4]
# set_location_assignment PIN_M51 -to ddr4_ecc_mem[1].dq[32]
# set_location_assignment PIN_N48 -to ddr4_ecc_mem[1].dq[33]
# set_location_assignment PIN_M47 -to ddr4_ecc_mem[1].dq[34]
# set_location_assignment PIN_L48 -to ddr4_ecc_mem[1].dq[35]
# set_location_assignment PIN_P47 -to ddr4_ecc_mem[1].dq[36]
# set_location_assignment PIN_P51 -to ddr4_ecc_mem[1].dq[37]
# set_location_assignment PIN_N52 -to ddr4_ecc_mem[1].dq[38]
# set_location_assignment PIN_L52 -to ddr4_ecc_mem[1].dq[39]


#-----------------------------------------------------------------------------
# EMIF HPS
#-----------------------------------------------------------------------------
set_location_assignment PIN_N10 -to "ddr4_hps.ref_clk(n)"
set_location_assignment PIN_L10 -to ddr4_hps.ref_clk
set_location_assignment PIN_P5  -to ddr4_hps.bg[0]
set_location_assignment PIN_M5  -to ddr4_hps.ba[1]
set_location_assignment PIN_N6  -to ddr4_hps.ba[0]
set_location_assignment PIN_L6  -to ddr4_hps.alert_n
set_location_assignment PIN_P7  -to ddr4_hps.a[16]
set_location_assignment PIN_M7  -to ddr4_hps.a[15]
set_location_assignment PIN_N8  -to ddr4_hps.a[14]
set_location_assignment PIN_L8  -to ddr4_hps.a[13]
set_location_assignment PIN_P9  -to ddr4_hps.a[12]
set_location_assignment PIN_M9  -to ddr4_hps.oct_rzqin
set_location_assignment PIN_W12 -to ddr4_hps.a[11]
set_location_assignment PIN_U12 -to ddr4_hps.a[10]
set_location_assignment PIN_V13 -to ddr4_hps.a[9]
set_location_assignment PIN_T13 -to ddr4_hps.a[8]
set_location_assignment PIN_W14 -to ddr4_hps.a[7]
set_location_assignment PIN_U14 -to ddr4_hps.a[6]
set_location_assignment PIN_V15 -to ddr4_hps.a[5]
set_location_assignment PIN_T15 -to ddr4_hps.a[4]
set_location_assignment PIN_W16 -to ddr4_hps.a[3]
set_location_assignment PIN_U16 -to ddr4_hps.a[2]
set_location_assignment PIN_V17 -to ddr4_hps.a[1]
set_location_assignment PIN_T17 -to ddr4_hps.a[0]
set_location_assignment PIN_N12 -to ddr4_hps.par
set_location_assignment PIN_L12 -to ddr4_hps.cs_n[1]
set_location_assignment PIN_P13 -to ddr4_hps.ck_n
set_location_assignment PIN_M13 -to ddr4_hps.ck
set_location_assignment PIN_L14 -to ddr4_hps.cke
set_location_assignment PIN_M15 -to ddr4_hps.odt
set_location_assignment PIN_N16 -to ddr4_hps.act_n
set_location_assignment PIN_L16 -to ddr4_hps.cs_n[0]
set_location_assignment PIN_P17 -to ddr4_hps.reset_n

# HPS DQS0
set_location_assignment PIN_A14 -to ddr4_hps.dbi_n[0]
set_location_assignment PIN_D15 -to ddr4_hps.dqs_n[0]
set_location_assignment PIN_B15 -to ddr4_hps.dqs[0]
set_location_assignment PIN_B13 -to ddr4_hps.dq[0]
set_location_assignment PIN_C12 -to ddr4_hps.dq[1]
set_location_assignment PIN_A16 -to ddr4_hps.dq[2]
set_location_assignment PIN_D13 -to ddr4_hps.dq[3]
set_location_assignment PIN_C16 -to ddr4_hps.dq[4]
set_location_assignment PIN_A12 -to ddr4_hps.dq[5]
set_location_assignment PIN_D17 -to ddr4_hps.dq[6]
set_location_assignment PIN_B17 -to ddr4_hps.dq[7]

# HPS DQS1
set_location_assignment PIN_F7  -to ddr4_hps.dbi_n[1]
set_location_assignment PIN_J8  -to ddr4_hps.dqs_n[1]
set_location_assignment PIN_G8  -to ddr4_hps.dqs[1]
set_location_assignment PIN_G6  -to ddr4_hps.dq[8]
set_location_assignment PIN_G10 -to ddr4_hps.dq[9]
set_location_assignment PIN_F5  -to ddr4_hps.dq[10]
set_location_assignment PIN_F9  -to ddr4_hps.dq[11]
set_location_assignment PIN_H9  -to ddr4_hps.dq[12]
set_location_assignment PIN_H5  -to ddr4_hps.dq[14]
set_location_assignment PIN_J6  -to ddr4_hps.dq[13]
set_location_assignment PIN_J10 -to ddr4_hps.dq[15]

# HPS DQS2
set_location_assignment PIN_G14 -to ddr4_hps.dbi_n[2]
set_location_assignment PIN_H15 -to ddr4_hps.dqs_n[2]
set_location_assignment PIN_F15 -to ddr4_hps.dqs[2]
set_location_assignment PIN_G12 -to ddr4_hps.dq[16]
set_location_assignment PIN_J12 -to ddr4_hps.dq[17]
set_location_assignment PIN_J16 -to ddr4_hps.dq[18]
set_location_assignment PIN_G16 -to ddr4_hps.dq[19]
set_location_assignment PIN_H13 -to ddr4_hps.dq[20]
set_location_assignment PIN_H17 -to ddr4_hps.dq[21]
set_location_assignment PIN_F17 -to ddr4_hps.dq[22]
set_location_assignment PIN_F13 -to ddr4_hps.dq[23]

# HPS DQS3
set_location_assignment PIN_B7  -to ddr4_hps.dbi_n[3]
set_location_assignment PIN_C8  -to ddr4_hps.dqs_n[3]
set_location_assignment PIN_A8  -to ddr4_hps.dqs[3]
set_location_assignment PIN_D9  -to ddr4_hps.dq[30]
set_location_assignment PIN_B9  -to ddr4_hps.dq[27]
set_location_assignment PIN_C10 -to ddr4_hps.dq[25]
set_location_assignment PIN_A10 -to ddr4_hps.dq[24]
set_location_assignment PIN_D5  -to ddr4_hps.dq[29]
set_location_assignment PIN_B5  -to ddr4_hps.dq[28]
set_location_assignment PIN_C6  -to ddr4_hps.dq[31]
set_location_assignment PIN_A6  -to ddr4_hps.dq[26]

# HPS DQS4 (ECC)
set_location_assignment PIN_T7  -to ddr4_hps.dbi_n[4]
set_location_assignment PIN_W8  -to ddr4_hps.dqs_n[4]
set_location_assignment PIN_U8  -to ddr4_hps.dqs[4]
set_location_assignment PIN_V9  -to ddr4_hps.dq[33]
set_location_assignment PIN_U6  -to ddr4_hps.dq[32]
set_location_assignment PIN_W6  -to ddr4_hps.dq[34]
set_location_assignment PIN_W10 -to ddr4_hps.dq[35]
set_location_assignment PIN_T5  -to ddr4_hps.dq[36]
set_location_assignment PIN_U10 -to ddr4_hps.dq[37]
set_location_assignment PIN_V5  -to ddr4_hps.dq[38]
set_location_assignment PIN_T9  -to ddr4_hps.dq[39]

