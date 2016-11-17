SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	04/26/2016
-- Description:	Loads all the Satellites from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.prDV_HEDIS_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[prDV_HEDIS_LoadSats]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

		  --LOAD HEDISDetail Satellite
		  INSERT INTO dbo.S_HEDISDetail
			(
			  S_HEDISDetail_RK,
			  H_HEDIS_RK,
			  CLIENT,
			  CLIENT_MEMBER_STATUS,
			  PRODUCT_ROLLUP_ID,
			  MEM_NBR,
			  RecordSource,
			  LoadDate,
			  MMS_MED,
			  MMS_RX,
			  MMS_MH_INP,
			  MMS_MH_INT,
			  MMS_MH_AMB,
			  MMS_CD_INP,
			  MMS_CD_INT,
			  MMS_CD_AMB,
			  MMS_DENT,
			  AAP_DEN1,
			  AAP_DEN2,
			  AAP_DEN3,
			  AAP_NUM1,
			  AAP_NUM2,
			  AAP_NUM3,
			  CAP_DEN1,
			  CAP_DEN2,
			  CAP_DEN3,
			  CAP_DEN4,
			  CAP_NUM1,
			  CAP_NUM2,
			  CAP_NUM3,
			  CAP_NUM4,
			  PPC_DEN,
			  PPC_NUM1,
			  PPC_NUM2,
			  ADV_DEN1,
			  ADV_DEN2,
			  ADV_DEN3,
			  ADV_DEN4,
			  ADV_DEN5,
			  ADV_DEN6,
			  ADV_NUM1,
			  ADV_NUM2,
			  ADV_NUM3,
			  ADV_NUM4,
			  ADV_NUM5,
			  ADV_NUM6,
			  IET_DEN1,
			  IET_DEN2,
			  IET_NUM1_1,
			  IET_NUM1_2,
			  IET_NUM2_1,
			  IET_NUM2_2,
			  APP_DEN1,
			  APP_DEN2,
			  APP_DEN3,
			  APP_NUM1,
			  APP_NUM2,
			  APP_NUM3,
			  CIS_DEN,
			  CIS_NUM1,
			  CIS_NUM2,
			  CIS_NUM3,
			  CIS_NUM4,
			  CIS_NUM5,
			  CIS_NUM6,
			  CIS_NUM7,
			  CIS_NUM8,
			  CIS_NUM9,
			  CIS_NUM10,
			  CIS_NUM11,
			  CIS_NUM12,
			  CIS_NUM13,
			  CIS_NUM14,
			  CIS_NUM15,
			  CIS_NUM16,
			  CIS_NUM17,
			  CIS_NUM18,
			  CIS_NUM19,
			  URI_DEN,
			  URI_NUM,
			  CWP_DEN,
			  CWP_NUM,
			  COL_DEN,
			  COL_NUM,
			  BCS_DEN,
			  BCS_NUM,
			  CCS_DEN,
			  CCS_NUM,
			  CHL_DEN1,
			  CHL_DEN2,
			  CHL_NUM1,
			  CHL_NUM2,
			  OMW_DEN,
			  OMW_NUM,
			  CBP_DEN,
			  CBP_NUM,
			  PBH_DEN,
			  PBH_NUM,
			  CMC_DEN,
			  CMC_NUM1,
			  CMC_NUM2,
			  CMC_NUM3,
			  CDC_DEN,
			  CDC_NUM1,
			  CDC_NUM2,
			  CDC_NUM3,
			  CDC_NUM4,
			  CDC_NUM5,
			  CDC_NUM6,
			  CDC_NUM7,
			  CDC_NUM8,
			  CDC_NUM9,
			  CDC_NUM10,
			  ASM_DEN1,
			  ASM_DEN2,
			  ASM_DEN3,
			  ASM_DEN4,
			  ASM_NUM1,
			  ASM_NUM2,
			  ASM_NUM3,
			  ASM_NUM4,
			  FUH_DEN,
			  FUH_NUM1,
			  FUH_NUM2,
			  AMM_DEN,
			  AMM_NUM1,
			  AMM_NUM2,
			  AMM_NUM3,
			  GSO_DEN,
			  GSO_NUM,
			  LBP_DEN,
			  LBP_NUM,
			  AAB_DEN,
			  AAB_NUM,
			  SPR_DEN,
			  SPR_NUM,
			  ADD_DEN1,
			  ADD_NUM1,
			  ADD_DEN2,
			  ADD_NUM2,
			  ART_DEN,
			  ART_NUM,
			  MPM_DEN1,
			  MPM_DEN2,
			  MPM_DEN3,
			  MPM_DEN4,
			  MPM_NE1,
			  MPM_NE2,
			  MPM_NE3,
			  MPM_NE4,
			  DAE_DEN,
			  DAE_NUM1,
			  DAE_NUM2,
			  DDE_DEN1,
			  DDE_DEN2,
			  DDE_DEN3,
			  DDE_NUM1,
			  DDE_NUM2,
			  DDE_NUM3,
			  PCE_DEN,
			  PCE_NUM1,
			  PCE_NUM2,
			  LSC_DEN,
			  LSC_NUM,
			  ABA_DEN,
			  ABA_NUM,
			  WCC_DEN1_1,
			  WCC_NUM1_1,
			  WCC_DEN1_2,
			  WCC_NUM1_2,
			  WCC_DEN2_1,
			  WCC_NUM2_1,
			  WCC_DEN2_2,
			  WCC_NUM2_2,
			  WCC_DEN3_1,
			  WCC_NUM3_1,
			  WCC_DEN3_2,
			  WCC_NUM3_2,
			  COA_DEN,
			  COA_NUM1,
			  COA_NUM2,
			  COA_NUM3,
			  COA_NUM4,
			  MRP_DEN,
			  MRP_NUM,
			  IMA_DEN,
			  IMA_NUM1,
			  IMA_NUM2,
			  IMA_NUM3,
			  HPV_DEN,
			  HPV_NUM,
			  MMA_DEN1,
			  MMA_NUM1_1,
			  MMA_NUM1_2,
			  MMA_DEN2,
			  MMA_NUM2_1,
			  MMA_NUM2_2,
			  MMA_DEN3,
			  MMA_NUM3_1,
			  MMA_NUM3_2,
			  MMA_DEN4,
			  MMA_NUM4_1,
			  MMA_NUM4_2,
			  AMR_DEN1,
			  AMR_DEN2,
			  AMR_DEN3,
			  AMR_DEN4,
			  AMR_NUM1,
			  AMR_NUM2,
			  AMR_NUM3,
			  AMR_NUM4,
			  SMD_DEN,
			  SMD_NUM,
			  SAA_DEN,
			  SAA_NUM,
			  SSD_DEN,
			  SSD_NUM,
			  SMC_DEN,
			  SMC_NUM,
			  NCS_DEN,
			  NCS_NUM,
			  PSA_DEN,
			  PSA_NUM,
			  APC_DEN1,
			  APC_DEN2,
			  APC_DEN3,
			  APC_NUM1,
			  APC_NUM2,
			  APC_NUM3,
			  APM_DEN1,
			  APM_DEN2,
			  APM_DEN3,
			  APM_NUM1,
			  APM_NUM2,
			  APM_NUM3,
			  FPC_DEN,
			  FPC_NUM1,
			  FPC_NUM2,
			  FPC_NUM3,
			  FPC_NUM4,
			  FPC_NUM5,
			  W15_DEN,
			  W15_NUM1,
			  W15_NUM2,
			  W15_NUM3,
			  W15_NUM4,
			  W15_NUM5,
			  W15_NUM6,
			  W15_NUM7,
			  W34_DEN,
			  W34_NUM,
			  AWC_DEN,
			  AWC_NUM,
			  FSP_CABG,
			  FSP_PTCA,
			  FSP_CC,
			  FSP_CE,
			  FSP_RDF,
			  FSP_THR,
			  FSP_TKR,
			  FSP_EXL,
			  FSP_CHO,
			  FSP_CHC,
			  FSP_HYA,
			  FSP_HYV,
			  FSP_PROS,
			  FSP_DC,
			  FSP_BACK,
			  FSP_MYR,
			  FSP_TON,
			  FSP_MAST,
			  FSP_LUMP,
			  FSP_BARI,
			  IPU_DISCH_TOT,
			  IPU_DAYS_TOT,
			  IPU_DISCH_MAT,
			  IPU_DAYS_MAT,
			  IPU_DISCH_SUR,
			  IPU_DAYS_SUR,
			  IPU_DISCH_MED,
			  IPU_DAYS_MED,
			  AMB_OV,
			  AMB_ED,
			  AMB_AS,
			  AMB_OR,
			  MPT_ANY,
			  MPT_INP,
			  MPT_DN,
			  MPT_AMB,
			  IAD_ANY,
			  IAD_INP,
			  IAD_DN,
			  IAD_AMB,
			  TOTAL_ABX_SCRIPTS,
			  TOTAL_ABX_DAYS,
			  ABX_CONCERN_SCRIPTS,
			  ABXQUIN_PMPY,
			  ABXZITH_PMPY,
			  ABXCEPH2_PMPY,
			  ABXCEPH3_PMPY,
			  ABXAMOX_PMPY,
			  ABXKETO_PMPY,
			  ABXCLIND_PMPY,
			  ABXMISC_PMPY,
			  ABXABSORB_PMPY,
			  ABXAMINO_PMPY,
			  ABXCEPH1_PMPY,
			  ABXLINCO_PMPY,
			  ABXMACRO_PMPY,
			  ABXPEN_PMPY,
			  ABXTET_PMPY,
			  ABXMISO_PMPY,
			  ABX_ALLOTHER_SCRIPTS,
			  PCR_DEN,
			  PCR_NUM,
			  SUM_WEIGHTS,
			  PRED_READM,
			  RDI_DEN,
			  RDI_EXCL_REQ,
			  RAS_DEN,
			  RAS_EXCL_REQ,
			  RCA_DEN,
			  RCA_EXCL_REQ,
			  RCO_DEN,
			  RCO_EXCL_REQ,
			  RHY_DEN,
			  RHY_EXCL_REQ,
			  EM_COUNT,
			  RRU_LOS,
			  RX_COUNT,
			  PROC_COUNT,
			  CAP_INPATIENT,
			  CAP_EM_INPATIENT,
			  CAP_EM_OUTPATIENT,
			  CAP_PROC_INPATIENT,
			  CAP_PROC_OUTPATIENT,
			  CAP_RX,
			  CAP_LAB,
			  CAP_IMG,
			  NCQA_PRICE_EM_INP,
			  NCQA_PRICE_EM_OUT,
			  TOTAL_COST_EM,
			  NCQA_PRICE_INP,
			  TOTAL_COST_INP,
			  NCQA_PRICE_PROC_INP,
			  NCQA_PRICE_PROC_OUT,
			  TOTAL_COST_PROC,
			  NCQA_PRICE_RX,
			  TOTAL_COST_RX,
			  NCQA_PRICE_LAB,
			  NCQA_PRICE_IMG,
			  LAB_COUNT,
			  IMG_COUNT,
			  RRU_MMS_MED,
			  RRU_MMS_RX,
			  ED_COUNT,
			  FREQ_CABG,
			  FREQ_CE,
			  FREQ_PCI,
			  FREQ_CC,
			  FREQ_CASDT,
			  FREQ_CAD_EBCT,
			  FREQ_CCT,
			  RRU_INP_DISCH,
			  RRU_INP_DAYS,
			  RRU_IPU_DISCH,
			  RRU_IPU_DAYS,
			  RRU_IPU_MED_DISCH,
			  RRU_IPU_MED_DAYS,
			  RRU_IPU_SURG_DISCH,
			  RRU_IPU_SURG_DAYS,
			  RRU_NON_DISCH,
			  RRU_NON_DAYS,
			  RX_N1,
			  RX_N2,
			  RX_G1,
			  RX_G2,
			  RRUAG_WEIGHT,
			  RASAG_WEIGHT,
			  COMORB_WEIGHT,
			  RRU_RISK_GROUP,
			  RAS_RISK_GROUP,
			  [Case Manager],
			  [PHO ID],
			  [PHO Name],
			  [PCP Name],
			  [PCP ID],
			  HashDiff
			)
			    SELECT DISTINCT
				    i.S_HEDISDetail_RK,
				    i.H_HEDIS_RK,
				    i.CLIENT,
				    i.CLIENT_MEMBER_STATUS,
				    i.PRODUCT_ROLLUP_ID,
				    i.MEM_NBR,
				    i.RecordSource,
				    i.LoadDate,
				    i.MMS_MED,
				    i.MMS_RX,
				    i.MMS_MH_INP,
				    i.MMS_MH_INT,
				    i.MMS_MH_AMB,
				    i.MMS_CD_INP,
				    i.MMS_CD_INT,
				    i.MMS_CD_AMB,
				    i.MMS_DENT,
				    i.AAP_DEN1,
				    i.AAP_DEN2,
				    i.AAP_DEN3,
				    i.AAP_NUM1,
				    i.AAP_NUM2,
				    i.AAP_NUM3,
				    i.CAP_DEN1,
				    i.CAP_DEN2,
				    i.CAP_DEN3,
				    i.CAP_DEN4,
				    i.CAP_NUM1,
				    i.CAP_NUM2,
				    i.CAP_NUM3,
				    i.CAP_NUM4,
				    i.PPC_DEN,
				    i.PPC_NUM1,
				    i.PPC_NUM2,
				    i.ADV_DEN1,
				    i.ADV_DEN2,
				    i.ADV_DEN3,
				    i.ADV_DEN4,
				    i.ADV_DEN5,
				    i.ADV_DEN6,
				    i.ADV_NUM1,
				    i.ADV_NUM2,
				    i.ADV_NUM3,
				    i.ADV_NUM4,
				    i.ADV_NUM5,
				    i.ADV_NUM6,
				    i.IET_DEN1,
				    i.IET_DEN2,
				    i.IET_NUM1_1,
				    i.IET_NUM1_2,
				    i.IET_NUM2_1,
				    i.IET_NUM2_2,
				    i.APP_DEN1,
				    i.APP_DEN2,
				    i.APP_DEN3,
				    i.APP_NUM1,
				    i.APP_NUM2,
				    i.APP_NUM3,
				    i.CIS_DEN,
				    i.CIS_NUM1,
				    i.CIS_NUM2,
				    i.CIS_NUM3,
				    i.CIS_NUM4,
				    i.CIS_NUM5,
				    i.CIS_NUM6,
				    i.CIS_NUM7,
				    i.CIS_NUM8,
				    i.CIS_NUM9,
				    i.CIS_NUM10,
				    i.CIS_NUM11,
				    i.CIS_NUM12,
				    i.CIS_NUM13,
				    i.CIS_NUM14,
				    i.CIS_NUM15,
				    i.CIS_NUM16,
				    i.CIS_NUM17,
				    i.CIS_NUM18,
				    i.CIS_NUM19,
				    i.URI_DEN,
				    i.URI_NUM,
				    i.CWP_DEN,
				    i.CWP_NUM,
				    i.COL_DEN,
				    i.COL_NUM,
				    i.BCS_DEN,
				    i.BCS_NUM,
				    i.CCS_DEN,
				    i.CCS_NUM,
				    i.CHL_DEN1,
				    i.CHL_DEN2,
				    i.CHL_NUM1,
				    i.CHL_NUM2,
				    i.OMW_DEN,
				    i.OMW_NUM,
				    i.CBP_DEN,
				    i.CBP_NUM,
				    i.PBH_DEN,
				    i.PBH_NUM,
				    i.CMC_DEN,
				    i.CMC_NUM1,
				    i.CMC_NUM2,
				    i.CMC_NUM3,
				    i.CDC_DEN,
				    i.CDC_NUM1,
				    i.CDC_NUM2,
				    i.CDC_NUM3,
				    i.CDC_NUM4,
				    i.CDC_NUM5,
				    i.CDC_NUM6,
				    i.CDC_NUM7,
				    i.CDC_NUM8,
				    i.CDC_NUM9,
				    i.CDC_NUM10,
				    i.ASM_DEN1,
				    i.ASM_DEN2,
				    i.ASM_DEN3,
				    i.ASM_DEN4,
				    i.ASM_NUM1,
				    i.ASM_NUM2,
				    i.ASM_NUM3,
				    i.ASM_NUM4,
				    i.FUH_DEN,
				    i.FUH_NUM1,
				    i.FUH_NUM2,
				    i.AMM_DEN,
				    i.AMM_NUM1,
				    i.AMM_NUM2,
				    i.AMM_NUM3,
				    i.GSO_DEN,
				    i.GSO_NUM,
				    i.LBP_DEN,
				    i.LBP_NUM,
				    i.AAB_DEN,
				    i.AAB_NUM,
				    i.SPR_DEN,
				    i.SPR_NUM,
				    i.ADD_DEN1,
				    i.ADD_NUM1,
				    i.ADD_DEN2,
				    i.ADD_NUM2,
				    i.ART_DEN,
				    i.ART_NUM,
				    i.MPM_DEN1,
				    i.MPM_DEN2,
				    i.MPM_DEN3,
				    i.MPM_DEN4,
				    i.MPM_NE1,
				    i.MPM_NE2,
				    i.MPM_NE3,
				    i.MPM_NE4,
				    i.DAE_DEN,
				    i.DAE_NUM1,
				    i.DAE_NUM2,
				    i.DDE_DEN1,
				    i.DDE_DEN2,
				    i.DDE_DEN3,
				    i.DDE_NUM1,
				    i.DDE_NUM2,
				    i.DDE_NUM3,
				    i.PCE_DEN,
				    i.PCE_NUM1,
				    i.PCE_NUM2,
				    i.LSC_DEN,
				    i.LSC_NUM,
				    i.ABA_DEN,
				    i.ABA_NUM,
				    i.WCC_DEN1_1,
				    i.WCC_NUM1_1,
				    i.WCC_DEN1_2,
				    i.WCC_NUM1_2,
				    i.WCC_DEN2_1,
				    i.WCC_NUM2_1,
				    i.WCC_DEN2_2,
				    i.WCC_NUM2_2,
				    i.WCC_DEN3_1,
				    i.WCC_NUM3_1,
				    i.WCC_DEN3_2,
				    i.WCC_NUM3_2,
				    i.COA_DEN,
				    i.COA_NUM1,
				    i.COA_NUM2,
				    i.COA_NUM3,
				    i.COA_NUM4,
				    i.MRP_DEN,
				    i.MRP_NUM,
				    i.IMA_DEN,
				    i.IMA_NUM1,
				    i.IMA_NUM2,
				    i.IMA_NUM3,
				    i.HPV_DEN,
				    i.HPV_NUM,
				    i.MMA_DEN1,
				    i.MMA_NUM1_1,
				    i.MMA_NUM1_2,
				    i.MMA_DEN2,
				    i.MMA_NUM2_1,
				    i.MMA_NUM2_2,
				    i.MMA_DEN3,
				    i.MMA_NUM3_1,
				    i.MMA_NUM3_2,
				    i.MMA_DEN4,
				    i.MMA_NUM4_1,
				    i.MMA_NUM4_2,
				    i.AMR_DEN1,
				    i.AMR_DEN2,
				    i.AMR_DEN3,
				    i.AMR_DEN4,
				    i.AMR_NUM1,
				    i.AMR_NUM2,
				    i.AMR_NUM3,
				    i.AMR_NUM4,
				    i.SMD_DEN,
				    i.SMD_NUM,
				    i.SAA_DEN,
				    i.SAA_NUM,
				    i.SSD_DEN,
				    i.SSD_NUM,
				    i.SMC_DEN,
				    i.SMC_NUM,
				    i.NCS_DEN,
				    i.NCS_NUM,
				    i.PSA_DEN,
				    i.PSA_NUM,
				    i.APC_DEN1,
				    i.APC_DEN2,
				    i.APC_DEN3,
				    i.APC_NUM1,
				    i.APC_NUM2,
				    i.APC_NUM3,
				    i.APM_DEN1,
				    i.APM_DEN2,
				    i.APM_DEN3,
				    i.APM_NUM1,
				    i.APM_NUM2,
				    i.APM_NUM3,
				    i.FPC_DEN,
				    i.FPC_NUM1,
				    i.FPC_NUM2,
				    i.FPC_NUM3,
				    i.FPC_NUM4,
				    i.FPC_NUM5,
				    i.W15_DEN,
				    i.W15_NUM1,
				    i.W15_NUM2,
				    i.W15_NUM3,
				    i.W15_NUM4,
				    i.W15_NUM5,
				    i.W15_NUM6,
				    i.W15_NUM7,
				    i.W34_DEN,
				    i.W34_NUM,
				    i.AWC_DEN,
				    i.AWC_NUM,
				    i.FSP_CABG,
				    i.FSP_PTCA,
				    i.FSP_CC,
				    i.FSP_CE,
				    i.FSP_RDF,
				    i.FSP_THR,
				    i.FSP_TKR,
				    i.FSP_EXL,
				    i.FSP_CHO,
				    i.FSP_CHC,
				    i.FSP_HYA,
				    i.FSP_HYV,
				    i.FSP_PROS,
				    i.FSP_DC,
				    i.FSP_BACK,
				    i.FSP_MYR,
				    i.FSP_TON,
				    i.FSP_MAST,
				    i.FSP_LUMP,
				    i.FSP_BARI,
				    i.IPU_DISCH_TOT,
				    i.IPU_DAYS_TOT,
				    i.IPU_DISCH_MAT,
				    i.IPU_DAYS_MAT,
				    i.IPU_DISCH_SUR,
				    i.IPU_DAYS_SUR,
				    i.IPU_DISCH_MED,
				    i.IPU_DAYS_MED,
				    i.AMB_OV,
				    i.AMB_ED,
				    i.AMB_AS,
				    i.AMB_OR,
				    i.MPT_ANY,
				    i.MPT_INP,
				    i.MPT_DN,
				    i.MPT_AMB,
				    i.IAD_ANY,
				    i.IAD_INP,
				    i.IAD_DN,
				    i.IAD_AMB,
				    i.TOTAL_ABX_SCRIPTS,
				    i.TOTAL_ABX_DAYS,
				    i.ABX_CONCERN_SCRIPTS,
				    i.ABXQUIN_PMPY,
				    i.ABXZITH_PMPY,
				    i.ABXCEPH2_PMPY,
				    i.ABXCEPH3_PMPY,
				    i.ABXAMOX_PMPY,
				    i.ABXKETO_PMPY,
				    i.ABXCLIND_PMPY,
				    i.ABXMISC_PMPY,
				    i.ABXABSORB_PMPY,
				    i.ABXAMINO_PMPY,
				    i.ABXCEPH1_PMPY,
				    i.ABXLINCO_PMPY,
				    i.ABXMACRO_PMPY,
				    i.ABXPEN_PMPY,
				    i.ABXTET_PMPY,
				    i.ABXMISO_PMPY,
				    i.ABX_ALLOTHER_SCRIPTS,
				    i.PCR_DEN,
				    i.PCR_NUM,
				    i.SUM_WEIGHTS,
				    i.PRED_READM,
				    i.RDI_DEN,
				    i.RDI_EXCL_REQ,
				    i.RAS_DEN,
				    i.RAS_EXCL_REQ,
				    i.RCA_DEN,
				    i.RCA_EXCL_REQ,
				    i.RCO_DEN,
				    i.RCO_EXCL_REQ,
				    i.RHY_DEN,
				    i.RHY_EXCL_REQ,
				    i.EM_COUNT,
				    i.RRU_LOS,
				    i.RX_COUNT,
				    i.PROC_COUNT,
				    i.CAP_INPATIENT,
				    i.CAP_EM_INPATIENT,
				    i.CAP_EM_OUTPATIENT,
				    i.CAP_PROC_INPATIENT,
				    i.CAP_PROC_OUTPATIENT,
				    i.CAP_RX,
				    i.CAP_LAB,
				    i.CAP_IMG,
				    i.NCQA_PRICE_EM_INP,
				    i.NCQA_PRICE_EM_OUT,
				    i.TOTAL_COST_EM,
				    i.NCQA_PRICE_INP,
				    i.TOTAL_COST_INP,
				    i.NCQA_PRICE_PROC_INP,
				    i.NCQA_PRICE_PROC_OUT,
				    i.TOTAL_COST_PROC,
				    i.NCQA_PRICE_RX,
				    i.TOTAL_COST_RX,
				    i.NCQA_PRICE_LAB,
				    i.NCQA_PRICE_IMG,
				    i.LAB_COUNT,
				    i.IMG_COUNT,
				    i.RRU_MMS_MED,
				    i.RRU_MMS_RX,
				    i.ED_COUNT,
				    i.FREQ_CABG,
				    i.FREQ_CE,
				    i.FREQ_PCI,
				    i.FREQ_CC,
				    i.FREQ_CASDT,
				    i.FREQ_CAD_EBCT,
				    i.FREQ_CCT,
				    i.RRU_INP_DISCH,
				    i.RRU_INP_DAYS,
				    i.RRU_IPU_DISCH,
				    i.RRU_IPU_DAYS,
				    i.RRU_IPU_MED_DISCH,
				    i.RRU_IPU_MED_DAYS,
				    i.RRU_IPU_SURG_DISCH,
				    i.RRU_IPU_SURG_DAYS,
				    i.RRU_NON_DISCH,
				    i.RRU_NON_DAYS,
				    i.RX_N1,
				    i.RX_N2,
				    i.RX_G1,
				    i.RX_G2,
				    i.RRUAG_WEIGHT,
				    i.RASAG_WEIGHT,
				    i.COMORB_WEIGHT,
				    i.RRU_RISK_GROUP,
				    i.RAS_RISK_GROUP,
				    i.[Case Manager],
				    i.[PHO ID],
				    i.[PHO Name],
				    i.[PCP Name],
				    i.[PCP ID],
				    i.HashDiff
			    FROM CHSStaging.dv.HEDIS_Import i 
				    LEFT JOIN dbo.S_HEDISDetail h ON i.H_HEDIS_RK = h.H_HEDIS_RK AND h.RecordEndDate IS NULL AND i.HashDiff = h.HashDiff
			    WHERE h.S_HEDISDetail_RK IS NULL;

		  --RECORD END DATE CLEANUP
		  UPDATE dbo.S_HEDISDetail
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.S_HEDISDetail AS z
			 WHERE z.H_HEDIS_RK = a.H_HEDIS_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.S_HEDISDetail a
		  WHERE
				a.RecordEndDate IS NULL;

		  --LOAD ProviderDemo Satellite
		  INSERT INTO dbo.S_ProviderDemo
			(
			  S_ProviderDemo_RK,
			  H_Provider_RK,
			  NPI,
			  LoadDate,
			  LastName,
			  FirstName,
			  HashDiff,
			  RecordSource
			)
			    SELECT DISTINCT
				    p.S_ProviderDemo_RK,
				    p.H_Provider_RK,
				    NULL AS NPI,
				    p.LoadDate,
				    p.ProviderLastName,
				    p.ProviderFirstName,
				    p.ProviderDemoHashDiff,
				    p.RecordSource
			    FROM  CHSStaging.dv.HEDIS_Provider p 
			    LEFT JOIN dbo.S_ProviderDemo h ON p.H_Provider_RK = h.H_Provider_RK AND h.RecordEndDate IS NULL AND p.ProviderDemoHashDiff = h.HashDiff
			    WHERE h.S_ProviderDemo_RK IS NULL;

		  --RECORD END DATE CLEANUP
		  UPDATE dbo.S_ProviderDemo
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.S_ProviderDemo AS z
			 WHERE z.H_Provider_RK = a.H_Provider_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.S_ProviderDemo a
		  WHERE
				a.RecordEndDate IS NULL;
		  
		  --LOAD ProviderNetworkClient Link Satellite
		  INSERT INTO dbo.LS_ProviderNetworkClient
			(
			  LS_ProviderNetworkClient_RK,
			  LoadDate,
			  L_ProviderNetworkClient_RK,
			  ClientProviderID,
			  HashDiff,
			  RecordSource
			)
			    SELECT DISTINCT
				    p.LS_ProviderNetworkClient_RK,
				    p.LoadDate,
				    p.L_ProviderNetworkClient_RK,
				    p.[PCP ID],
				    p.ProviderNetworkClientHashDiff,
				    p.RecordSource
			    FROM  CHSStaging.dv.HEDIS_Provider AS p
					LEFT JOIN dbo.LS_ProviderNetworkClient AS h ON p.L_ProviderNetworkClient_RK = h.L_ProviderNetworkClient_RK
																    AND h.RecordEndDate IS NULL
																    AND p.ProviderNetworkClientHashDiff = h.HashDiff
			    WHERE h.LS_ProviderNetworkClient_RK IS NULL;

		  --RECORD END DATE CLEANUP
		  UPDATE dbo.LS_ProviderNetworkClient
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.LS_ProviderNetworkClient AS z
			 WHERE z.L_ProviderNetworkClient_RK = a.L_ProviderNetworkClient_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.LS_ProviderNetworkClient a
		  WHERE
				a.RecordEndDate IS NULL;

		  ----LOAD MemberClient Link Satellite
		  INSERT INTO dbo.LS_MemberClient
			(
			  LS_MemberClient_RK,
			  LoadDate,
			  L_MemberClient_RK,
			  ClientMemberID,
			  HashDiff,
			  RecordSource
			)
			    SELECT DISTINCT
				    m.LS_MemberClient_RK,
				    m.LoadDate,
				    m.L_MemberClient_RK,
				    m.ClientMemberID,
				    m.MemberClientHashDiff,
				    m.RecordSource
			    FROM  CHSStaging.dv.HEDIS_Member AS m
					LEFT JOIN dbo.LS_MemberClient AS h ON m.L_MemberClient_RK = h.L_MemberClient_RK
																    AND h.RecordEndDate IS NULL
																    AND m.MemberClientHashDiff = h.HashDiff
			    WHERE h.LS_MemberClient_RK IS NULL;
	  
		  --RECORD END DATE CLEANUP
		  UPDATE dbo.LS_MemberClient
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.LS_MemberClient AS z
			 WHERE z.L_MemberClient_RK = a.L_MemberClient_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.LS_MemberClient a
		  WHERE
				a.RecordEndDate IS NULL;

         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
