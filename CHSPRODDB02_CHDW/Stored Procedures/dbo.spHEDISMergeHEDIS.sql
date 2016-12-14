SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	11/10/2016
-- Description:	merges the stage to dim for HEDIS
-- Usage:			
--		  EXECUTE dbo.spHEDISMergeHEDIS
-- =============================================
CREATE PROC [dbo].[spHEDISMergeHEDIS]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;

    BEGIN
    
        MERGE INTO [CHSDW].[fact].[HEDIS] AS T
        USING (SELECT  h.CLIENT ,
        h.CLIENT_MEMBER_STATUS ,
        h.PRODUCT_ROLLUP_ID ,
        h.MEM_NBR ,
        h.MMS_MED ,
        h.MMS_RX ,
        h.MMS_MH_INP ,
        h.MMS_MH_INT ,
        h.MMS_MH_AMB ,
        h.MMS_CD_INP ,
        h.MMS_CD_INT ,
        h.MMS_CD_AMB ,
        h.MMS_DENT ,
        h.AAP_DEN1 ,
        h.AAP_DEN2 ,
        h.AAP_DEN3 ,
        h.AAP_NUM1 ,
        h.AAP_NUM2 ,
        h.AAP_NUM3 ,
        h.CAP_DEN1 ,
        h.CAP_DEN2 ,
        h.CAP_DEN3 ,
        h.CAP_DEN4 ,
        h.CAP_NUM1 ,
        h.CAP_NUM2 ,
        h.CAP_NUM3 ,
        h.CAP_NUM4 ,
        h.PPC_DEN ,
        h.PPC_NUM1 ,
        h.PPC_NUM2 ,
        h.ADV_DEN1 ,
        h.ADV_DEN2 ,
        h.ADV_DEN3 ,
        h.ADV_DEN4 ,
        h.ADV_DEN5 ,
        h.ADV_DEN6 ,
        h.ADV_NUM1 ,
        h.ADV_NUM2 ,
        h.ADV_NUM3 ,
        h.ADV_NUM4 ,
        h.ADV_NUM5 ,
        h.ADV_NUM6 ,
        h.IET_DEN1 ,
        h.IET_DEN2 ,
        h.IET_NUM1_1 ,
        h.IET_NUM1_2 ,
        h.IET_NUM2_1 ,
        h.IET_NUM2_2 ,
        h.APP_DEN1 ,
        h.APP_DEN2 ,
        h.APP_DEN3 ,
        h.APP_NUM1 ,
        h.APP_NUM2 ,
        h.APP_NUM3 ,
        h.CIS_DEN ,
        h.CIS_NUM1 ,
        h.CIS_NUM2 ,
        h.CIS_NUM3 ,
        h.CIS_NUM4 ,
        h.CIS_NUM5 ,
        h.CIS_NUM6 ,
        h.CIS_NUM7 ,
        h.CIS_NUM8 ,
        h.CIS_NUM9 ,
        h.CIS_NUM10 ,
        h.CIS_NUM11 ,
        h.CIS_NUM12 ,
        h.CIS_NUM13 ,
        h.CIS_NUM14 ,
        h.CIS_NUM15 ,
        h.CIS_NUM16 ,
        h.CIS_NUM17 ,
        h.CIS_NUM18 ,
        h.CIS_NUM19 ,
        h.URI_DEN ,
        h.URI_NUM ,
        h.CWP_DEN ,
        h.CWP_NUM ,
        h.COL_DEN ,
        h.COL_NUM ,
        h.BCS_DEN ,
        h.BCS_NUM ,
        h.CCS_DEN ,
        h.CCS_NUM ,
        h.CHL_DEN1 ,
        h.CHL_DEN2 ,
        h.CHL_NUM1 ,
        h.CHL_NUM2 ,
        h.OMW_DEN ,
        h.OMW_NUM ,
        h.CBP_DEN ,
        h.CBP_NUM ,
        h.PBH_DEN ,
        h.PBH_NUM ,
        h.CMC_DEN ,
        h.CDC_DEN3 ,
        h.CMC_NUM1 ,
        h.CMC_NUM2 ,
        h.CMC_NUM3 ,
        h.CDC_DEN ,
        h.CDC_NUM1 ,
        h.CDC_NUM2 ,
        h.CDC_NUM3 ,
        h.CDC_NUM4 ,
        h.CDC_NUM5 ,
        h.CDC_NUM6 ,
        h.CDC_NUM7 ,
        h.CDC_NUM8 ,
        h.CDC_NUM9 ,
        h.CDC_NUM10 ,
        h.ASM_DEN1 ,
        h.ASM_DEN2 ,
        h.ASM_DEN3 ,
        h.ASM_DEN4 ,
        h.ASM_NUM1 ,
        h.ASM_NUM2 ,
        h.ASM_NUM3 ,
        h.ASM_NUM4 ,
        h.FUH_DEN ,
        h.FUH_NUM1 ,
        h.FUH_NUM2 ,
        h.AMM_DEN ,
        h.AMM_NUM1 ,
        h.AMM_NUM2 ,
        h.AMM_NUM3 ,
        h.GSO_DEN ,
        h.GSO_NUM ,
        h.LBP_DEN ,
        h.LBP_NUM ,
        h.AAB_DEN ,
        h.AAB_NUM ,
        h.SPR_DEN ,
        h.SPR_NUM ,
        h.ADD_DEN1 ,
        h.ADD_NUM1 ,
        h.ADD_DEN2 ,
        h.ADD_NUM2 ,
        h.ART_DEN ,
        h.ART_NUM ,
        h.MPM_DEN1 ,
        h.MPM_DEN2 ,
        h.MPM_DEN3 ,
        h.MPM_DEN4 ,
        h.MPM_NE1 ,
        h.MPM_NE2 ,
        h.MPM_NE3 ,
        h.MPM_NE4 ,
        h.DAE_DEN ,
        h.DAE_NUM1 ,
        h.DAE_NUM2 ,
        h.DDE_DEN1 ,
        h.DDE_DEN2 ,
        h.DDE_DEN3 ,
        h.DDE_NUM1 ,
        h.DDE_NUM2 ,
        h.DDE_NUM3 ,
        h.PCE_DEN ,
        h.PCE_NUM1 ,
        h.PCE_NUM2 ,
        h.LSC_DEN ,
        h.LSC_NUM ,
        h.ABA_DEN ,
        h.ABA_NUM ,
        h.WCC_DEN1_1 ,
        h.WCC_NUM1_1 ,
        h.WCC_DEN1_2 ,
        h.WCC_NUM1_2 ,
        h.WCC_DEN2_1 ,
        h.WCC_NUM2_1 ,
        h.WCC_DEN2_2 ,
        h.WCC_NUM2_2 ,
        h.WCC_DEN3_1 ,
        h.WCC_NUM3_1 ,
        h.WCC_DEN3_2 ,
        h.WCC_NUM3_2 ,
        h.COA_DEN ,
        h.COA_NUM1 ,
        h.COA_NUM2 ,
        h.COA_NUM3 ,
        h.COA_NUM4 ,
        h.MRP_DEN ,
        h.MRP_NUM ,
        h.IMA_DEN ,
        h.IMA_NUM1 ,
        h.IMA_NUM2 ,
        h.IMA_NUM3 ,
        h.HPV_DEN ,
        h.HPV_NUM ,
        h.MMA_DEN1 ,
        h.MMA_NUM1_1 ,
        h.MMA_NUM1_2 ,
        h.MMA_DEN2 ,
        h.MMA_NUM2_1 ,
        h.MMA_NUM2_2 ,
        h.MMA_DEN3 ,
        h.MMA_NUM3_1 ,
        h.MMA_NUM3_2 ,
        h.MMA_DEN4 ,
        h.MMA_NUM4_1 ,
        h.MMA_NUM4_2 ,
        h.MMA_DEN5 ,
        h.MMA_NUM5_1 ,
        h.MMA_NUM5_2 ,
        h.MMA_DEN6 ,
        h.MMA_NUM6_1 ,
        h.MMA_NUM6_2 ,
        h.AMR_DEN1 ,
        h.AMR_DEN2 ,
        h.AMR_DEN3 ,
        h.AMR_DEN4 ,
        h.AMR_DEN5 ,
        h.AMR_DEN6 ,
        h.AMR_NUM1 ,
        h.AMR_NUM2 ,
        h.AMR_NUM3 ,
        h.AMR_NUM4 ,
        h.AMR_NUM5 ,
        h.AMR_NUM6 ,
        h.SMD_DEN ,
        h.SMD_NUM ,
        h.SAA_DEN ,
        h.SAA_NUM ,
        h.SSD_DEN ,
        h.SSD_NUM ,
        h.SMC_DEN ,
        h.SMC_NUM ,
        h.NCS_DEN ,
        h.NCS_NUM ,
        h.PSA_DEN ,
        h.PSA_NUM ,
        h.APC_DEN1 ,
        h.APC_DEN2 ,
        h.APC_DEN3 ,
        h.APC_NUM1 ,
        h.APC_NUM2 ,
        h.APC_NUM3 ,
        h.APM_DEN1 ,
        h.APM_DEN2 ,
        h.APM_DEN3 ,
        h.APM_NUM1 ,
        h.APM_NUM2 ,
        h.APM_NUM3 ,
        h.FPC_DEN ,
        h.FPC_NUM1 ,
        h.FPC_NUM2 ,
        h.FPC_NUM3 ,
        h.FPC_NUM4 ,
        h.FPC_NUM5 ,
        h.W15_DEN ,
        h.W15_NUM1 ,
        h.W15_NUM2 ,
        h.W15_NUM3 ,
        h.W15_NUM4 ,
        h.W15_NUM5 ,
        h.W15_NUM6 ,
        h.W15_NUM7 ,
        h.W34_DEN ,
        h.W34_NUM ,
        h.AWC_DEN ,
        h.AWC_NUM ,
        h.FSP_CABG ,
        h.FSP_PTCA ,
        h.FSP_CC ,
        h.FSP_CE ,
        h.FSP_RDF ,
        h.FSP_THR ,
        h.FSP_TKR ,
        h.FSP_EXL ,
        h.FSP_CHO ,
        h.FSP_CHC ,
        h.FSP_HYA ,
        h.FSP_HYV ,
        h.FSP_PROS ,
        h.FSP_DC ,
        h.FSP_BACK ,
        h.FSP_MYR ,
        h.FSP_TON ,
        h.FSP_MAST ,
        h.FSP_LUMP ,
        h.FSP_BARI ,
        h.IPU_DISCH_TOT ,
        h.IPU_DAYS_TOT ,
        h.IPU_DISCH_MAT ,
        h.IPU_DAYS_MAT ,
        h.IPU_DISCH_SUR ,
        h.IPU_DAYS_SUR ,
        h.IPU_DISCH_MED ,
        h.IPU_DAYS_MED ,
        h.AMB_OV ,
        h.AMB_ED ,
        h.AMB_AS ,
        h.AMB_OR ,
        h.MPT_ANY ,
        h.MPT_INP ,
        h.MPT_DN ,
        h.MPT_AMB ,
        h.IAD_ANY ,
        h.IAD_INP ,
        h.IAD_DN ,
        h.IAD_AMB ,
        h.TOTAL_ABX_SCRIPTS ,
        h.TOTAL_ABX_DAYS ,
        h.ABX_CONCERN_SCRIPTS ,
        h.ABXQUIN_PMPY ,
        h.ABXZITH_PMPY ,
        h.ABXCEPH2_PMPY ,
        h.ABXCEPH3_PMPY ,
        h.ABXAMOX_PMPY ,
        h.ABXKETO_PMPY ,
        h.ABXCLIND_PMPY ,
        h.ABXMISC_PMPY ,
        h.ABXABSORB_PMPY ,
        h.ABXAMINO_PMPY ,
        h.ABXCEPH1_PMPY ,
        h.ABXLINCO_PMPY ,
        h.ABXMACRO_PMPY ,
        h.ABXPEN_PMPY ,
        h.ABXTET_PMPY ,
        h.ABXMISO_PMPY ,
        h.ABX_ALLOTHER_SCRIPTS ,
        h.PCR_DEN ,
        h.PCR_NUM ,
        h.SUM_WEIGHTS ,
        h.PRED_READM ,
        h.RDI_DEN ,
        h.RDI_EXCL_REQ ,
        h.RAS_DEN ,
        h.RAS_EXCL_REQ ,
        h.RCA_DEN ,
        h.RCA_EXCL_REQ ,
        h.RCO_DEN ,
        h.RCO_EXCL_REQ ,
        h.RHY_DEN ,
        h.RHY_EXCL_REQ ,
        h.EM_COUNT ,
        h.RRU_LOS ,
        h.RX_COUNT ,
        h.PROC_COUNT ,
        h.CAP_INPATIENT ,
        h.CAP_EM_INPATIENT ,
        h.CAP_EM_OUTPATIENT ,
        h.CAP_PROC_INPATIENT ,
        h.CAP_PROC_OUTPATIENT ,
        h.CAP_RX ,
        h.CAP_LAB ,
        h.CAP_IMG ,
        h.NCQA_PRICE_EM_INP ,
        h.NCQA_PRICE_EM_OUT ,
        h.TOTAL_COST_EM ,
        h.NCQA_PRICE_INP ,
        h.TOTAL_COST_INP ,
        h.NCQA_PRICE_PROC_INP ,
        h.NCQA_PRICE_PROC_OUT ,
        h.TOTAL_COST_PROC ,
        h.NCQA_PRICE_RX ,
        h.TOTAL_COST_RX ,
        h.NCQA_PRICE_LAB ,
        h.NCQA_PRICE_IMG ,
        h.LAB_COUNT ,
        h.IMG_COUNT ,
        h.RRU_MMS_MED ,
        h.RRU_MMS_RX ,
        h.ED_COUNT ,
        h.FREQ_CABG ,
        h.FREQ_CE ,
        h.FREQ_PCI ,
        h.FREQ_CC ,
        h.FREQ_CASDT ,
        h.FREQ_CAD_EBCT ,
        h.FREQ_CCT ,
        h.RRU_INP_DISCH ,
        h.RRU_INP_DAYS ,
        h.RRU_IPU_DISCH ,
        h.RRU_IPU_DAYS ,
        h.RRU_IPU_MED_DISCH ,
        h.RRU_IPU_MED_DAYS ,
        h.RRU_IPU_SURG_DISCH ,
        h.RRU_IPU_SURG_DAYS ,
        h.RRU_NON_DISCH ,
        h.RRU_NON_DAYS ,
        h.RX_N1 ,
        h.RX_N2 ,
        h.RX_G1 ,
        h.RX_G2 ,
        h.RRUAG_WEIGHT ,
        h.RASAG_WEIGHT ,
        h.COMORB_WEIGHT ,
        h.RRU_RISK_GROUP ,
        h.RAS_RISK_GROUP ,
        h.SPC_DEN1_1 ,
        h.SPC_DEN2_1 ,
        h.SPC_NUM1_1 ,
        h.SPC_NUM2_1 ,
        h.SPC_DEN1_2 ,
        h.SPC_DEN2_2 ,
        h.SPC_NUM1_2 ,
        h.SPC_NUM2_2 ,
        h.SPD_DEN1 ,
        h.SPD_DEN2 ,
        h.SPD_NUM1 ,
        h.SPD_NUM2 ,
        h.PDC_DEN1 ,
        h.PDC_NUM1 ,
        h.PDC_DEN2 ,
        h.PDC_NUM2 ,
        h.PDC_DEN3 ,
        h.PDC_NUM3 ,
        h.IHU_DEN ,
        h.INP_SUR_CNT ,
        h.INP_MED_CNT ,
        h.INP_TOT_CNT ,
        h.EDU_DEN ,
        h.ER_CNT ,
        h.EXP_ER_CNT ,
        h.HPC_DEN ,
        h.CHRONIC_ACSC_CNT ,
        h.ACUTE_ACSC_CNT ,
        h.HPC_INP_TOT_CNT ,
        h.EXP_INP_HPCA ,
        h.EXP_INP_HPCCH ,
        h.EXP_INP_HPTOT ,
        h.HPCA_PPD_COMORB_WT ,
        h.HPCCH_PPD_COMORB_WT ,
        h.HPCT_PPD_COMORB_WT ,
        h.HPCA_PPD_AGE_WT ,
        h.HPCCH_PPD_AGE_WT ,
        h.HPCT_PPD_AGE_WT ,
        h.HPCA_PPD_BASE_WT ,
        h.HPCCH_PPD_BASE_WT ,
        h.HPCT_PPD_BASE_WT ,
        h.HPCA_PUCD_COMORB_WT ,
        h.HPCCH_PUCD_COMORB_WT ,
        h.HPCT_PUCD_COMORB_WT ,
        h.HPCA_PUCD_AGE_WT ,
        h.HPCCH_PUCD_AGE_WT ,
        h.HPCT_PUCD_AGE_WT ,
        h.HPCA_PUCD_BASE_WT ,
        h.HPCCH_PUCD_BASE_WT ,
        h.HPCT_PUCD_BASE_WT ,
        h.SUR_PPD_COMORB_WT ,
        h.MED_PPD_COMORB_WT ,
        h.TOT_PPD_COMORB_WT ,
        h.SUR_PPD_AGE_WT ,
        h.MED_PPD_AGE_WT ,
        h.TOT_PPD_AGE_WT ,
        h.SUR_PPD_BASE_WT ,
        h.MED_PPD_BASE_WT ,
        h.TOT_PPD_BASE_WT ,
        h.SUR_PUCD_COMORB_WT ,
        h.MED_PUCD_COMORB_WT ,
        h.TOT_PUCD_COMORB_WT ,
        h.SUR_PUCD_AGE_WT ,
        h.MED_PUCD_AGE_WT ,
        h.TOT_PUCD_AGE_WT ,
        h.SUR_PUCD_BASE_WT ,
        h.MED_PUCD_BASE_WT ,
        h.TOT_PUCD_BASE_WT ,
        h.PPV_COMORB_WT ,
        h.PPV_AGE_WT ,
        h.PPV_BASE_WT ,
        h.PUCV_COMORB_WT ,
        h.PUCV_AGE_WT ,
        h.PUCV_BASE_WT ,
        h.[Case Manager] ,
        h.[PHO ID] ,
        h.[PHO Name] ,
        h.[PCP Name] ,
        h.[PCP ID] ,
        h.RecordSource ,
        h.LoadDate ,
        c.ClientID ,
        p.ProviderID ,
        m.MemberID
FROM    stage.HEDIS h
        LEFT JOIN dim.Provider p ON h.CentauriProviderID = p.CentauriProviderID
        LEFT JOIN dim.Client c ON c.CentauriClientID = h.CentauriClientID
        LEFT JOIN dim.Member m ON m.CentauriMemberID = h.CentauriMemberID) AS S
        ON T.CLIENT = S.CLIENT
            AND T.CLIENT_MEMBER_STATUS = S.CLIENT_MEMBER_STATUS
            AND T.PRODUCT_ROLLUP_ID = S.PRODUCT_ROLLUP_ID
            AND T.MEM_NBR = S.MEM_NBR
            AND T.RecordSource = S.RecordSource
        WHEN MATCHED AND T.[MMS_MED] != S.[MMS_MED]
            OR T.[MMS_RX] != S.[MMS_RX]
            OR T.[MMS_MH_INP] != S.[MMS_MH_INP]
            OR T.[MMS_MH_INT] != S.[MMS_MH_INT]
            OR T.[MMS_MH_AMB] != S.[MMS_MH_AMB]
            OR T.[MMS_CD_INP] != S.[MMS_CD_INP]
            OR T.[MMS_CD_INT] != S.[MMS_CD_INT]
            OR T.[MMS_CD_AMB] != S.[MMS_CD_AMB]
            OR T.[MMS_DENT] != S.[MMS_DENT]
            OR T.[AAP_DEN1] != S.[AAP_DEN1]
            OR T.[AAP_DEN2] != S.[AAP_DEN2]
            OR T.[AAP_DEN3] != S.[AAP_DEN3]
            OR T.[AAP_NUM1] != S.[AAP_NUM1]
            OR T.[AAP_NUM2] != S.[AAP_NUM2]
            OR T.[AAP_NUM3] != S.[AAP_NUM3]
            OR T.[CAP_DEN1] != S.[CAP_DEN1]
            OR T.[CAP_DEN2] != S.[CAP_DEN2]
            OR T.[CAP_DEN3] != S.[CAP_DEN3]
            OR T.[CAP_DEN4] != S.[CAP_DEN4]
            OR T.[CAP_NUM1] != S.[CAP_NUM1]
            OR T.[CAP_NUM2] != S.[CAP_NUM2]
            OR T.[CAP_NUM3] != S.[CAP_NUM3]
            OR T.[CAP_NUM4] != S.[CAP_NUM4]
            OR T.[PPC_DEN] != S.[PPC_DEN]
            OR T.[PPC_NUM1] != S.[PPC_NUM1]
            OR T.[PPC_NUM2] != S.[PPC_NUM2]
            OR T.[ADV_DEN1] != S.[ADV_DEN1]
            OR T.[ADV_DEN2] != S.[ADV_DEN2]
            OR T.[ADV_DEN3] != S.[ADV_DEN3]
            OR T.[ADV_DEN4] != S.[ADV_DEN4]
            OR T.[ADV_DEN5] != S.[ADV_DEN5]
            OR T.[ADV_DEN6] != S.[ADV_DEN6]
            OR T.[ADV_NUM1] != S.[ADV_NUM1]
            OR T.[ADV_NUM2] != S.[ADV_NUM2]
            OR T.[ADV_NUM3] != S.[ADV_NUM3]
            OR T.[ADV_NUM4] != S.[ADV_NUM4]
            OR T.[ADV_NUM5] != S.[ADV_NUM5]
            OR T.[ADV_NUM6] != S.[ADV_NUM6]
            OR T.[IET_DEN1] != S.[IET_DEN1]
            OR T.[IET_DEN2] != S.[IET_DEN2]
            OR T.[IET_NUM1_1] != S.[IET_NUM1_1]
            OR T.[IET_NUM1_2] != S.[IET_NUM1_2]
            OR T.[IET_NUM2_1] != S.[IET_NUM2_1]
            OR T.[IET_NUM2_2] != S.[IET_NUM2_2]
            OR T.[APP_DEN1] != S.[APP_DEN1]
            OR T.[APP_DEN2] != S.[APP_DEN2]
            OR T.[APP_DEN3] != S.[APP_DEN3]
            OR T.[APP_NUM1] != S.[APP_NUM1]
            OR T.[APP_NUM2] != S.[APP_NUM2]
            OR T.[APP_NUM3] != S.[APP_NUM3]
            OR T.[CIS_DEN] != S.[CIS_DEN]
            OR T.[CIS_NUM1] != S.[CIS_NUM1]
            OR T.[CIS_NUM2] != S.[CIS_NUM2]
            OR T.[CIS_NUM3] != S.[CIS_NUM3]
            OR T.[CIS_NUM4] != S.[CIS_NUM4]
            OR T.[CIS_NUM5] != S.[CIS_NUM5]
            OR T.[CIS_NUM6] != S.[CIS_NUM6]
            OR T.[CIS_NUM7] != S.[CIS_NUM7]
            OR T.[CIS_NUM8] != S.[CIS_NUM8]
            OR T.[CIS_NUM9] != S.[CIS_NUM9]
            OR T.[CIS_NUM10] != S.[CIS_NUM10]
            OR T.[CIS_NUM11] != S.[CIS_NUM11]
            OR T.[CIS_NUM12] != S.[CIS_NUM12]
            OR T.[CIS_NUM13] != S.[CIS_NUM13]
            OR T.[CIS_NUM14] != S.[CIS_NUM14]
            OR T.[CIS_NUM15] != S.[CIS_NUM15]
            OR T.[CIS_NUM16] != S.[CIS_NUM16]
            OR T.[CIS_NUM17] != S.[CIS_NUM17]
            OR T.[CIS_NUM18] != S.[CIS_NUM18]
            OR T.[CIS_NUM19] != S.[CIS_NUM19]
            OR T.[URI_DEN] != S.[URI_DEN]
            OR T.[URI_NUM] != S.[URI_NUM]
            OR T.[CWP_DEN] != S.[CWP_DEN]
            OR T.[CWP_NUM] != S.[CWP_NUM]
            OR T.[COL_DEN] != S.[COL_DEN]
            OR T.[COL_NUM] != S.[COL_NUM]
            OR T.[BCS_DEN] != S.[BCS_DEN]
            OR T.[BCS_NUM] != S.[BCS_NUM]
            OR T.[CCS_DEN] != S.[CCS_DEN]
            OR T.[CCS_NUM] != S.[CCS_NUM]
            OR T.[CHL_DEN1] != S.[CHL_DEN1]
            OR T.[CHL_DEN2] != S.[CHL_DEN2]
            OR T.[CHL_NUM1] != S.[CHL_NUM1]
            OR T.[CHL_NUM2] != S.[CHL_NUM2]
            OR T.[OMW_DEN] != S.[OMW_DEN]
            OR T.[OMW_NUM] != S.[OMW_NUM]
            OR T.[CBP_DEN] != S.[CBP_DEN]
            OR T.[CBP_NUM] != S.[CBP_NUM]
            OR T.[PBH_DEN] != S.[PBH_DEN]
            OR T.[PBH_NUM] != S.[PBH_NUM]
            OR T.[CMC_DEN] != S.[CMC_DEN]
            OR T.[CDC_DEN3] != S.[CDC_DEN3]
            OR T.[CMC_NUM1] != S.[CMC_NUM1]
            OR T.[CMC_NUM2] != S.[CMC_NUM2]
            OR T.[CMC_NUM3] != S.[CMC_NUM3]
            OR T.[CDC_DEN] != S.[CDC_DEN]
            OR T.[CDC_NUM1] != S.[CDC_NUM1]
            OR T.[CDC_NUM2] != S.[CDC_NUM2]
            OR T.[CDC_NUM3] != S.[CDC_NUM3]
            OR T.[CDC_NUM4] != S.[CDC_NUM4]
            OR T.[CDC_NUM5] != S.[CDC_NUM5]
            OR T.[CDC_NUM6] != S.[CDC_NUM6]
            OR T.[CDC_NUM7] != S.[CDC_NUM7]
            OR T.[CDC_NUM8] != S.[CDC_NUM8]
            OR T.[CDC_NUM9] != S.[CDC_NUM9]
            OR T.[CDC_NUM10] != S.[CDC_NUM10]
            OR T.[ASM_DEN1] != S.[ASM_DEN1]
            OR T.[ASM_DEN2] != S.[ASM_DEN2]
            OR T.[ASM_DEN3] != S.[ASM_DEN3]
            OR T.[ASM_DEN4] != S.[ASM_DEN4]
            OR T.[ASM_NUM1] != S.[ASM_NUM1]
            OR T.[ASM_NUM2] != S.[ASM_NUM2]
            OR T.[ASM_NUM3] != S.[ASM_NUM3]
            OR T.[ASM_NUM4] != S.[ASM_NUM4]
            OR T.[FUH_DEN] != S.[FUH_DEN]
            OR T.[FUH_NUM1] != S.[FUH_NUM1]
            OR T.[FUH_NUM2] != S.[FUH_NUM2]
            OR T.[AMM_DEN] != S.[AMM_DEN]
            OR T.[AMM_NUM1] != S.[AMM_NUM1]
            OR T.[AMM_NUM2] != S.[AMM_NUM2]
            OR T.[AMM_NUM3] != S.[AMM_NUM3]
            OR T.[GSO_DEN] != S.[GSO_DEN]
            OR T.[GSO_NUM] != S.[GSO_NUM]
            OR T.[LBP_DEN] != S.[LBP_DEN]
            OR T.[LBP_NUM] != S.[LBP_NUM]
            OR T.[AAB_DEN] != S.[AAB_DEN]
            OR T.[AAB_NUM] != S.[AAB_NUM]
            OR T.[SPR_DEN] != S.[SPR_DEN]
            OR T.[SPR_NUM] != S.[SPR_NUM]
            OR T.[ADD_DEN1] != S.[ADD_DEN1]
            OR T.[ADD_NUM1] != S.[ADD_NUM1]
            OR T.[ADD_DEN2] != S.[ADD_DEN2]
            OR T.[ADD_NUM2] != S.[ADD_NUM2]
            OR T.[ART_DEN] != S.[ART_DEN]
            OR T.[ART_NUM] != S.[ART_NUM]
            OR T.[MPM_DEN1] != S.[MPM_DEN1]
            OR T.[MPM_DEN2] != S.[MPM_DEN2]
            OR T.[MPM_DEN3] != S.[MPM_DEN3]
            OR T.[MPM_DEN4] != S.[MPM_DEN4]
            OR T.[MPM_NE1] != S.[MPM_NE1]
            OR T.[MPM_NE2] != S.[MPM_NE2]
            OR T.[MPM_NE3] != S.[MPM_NE3]
            OR T.[MPM_NE4] != S.[MPM_NE4]
            OR T.[DAE_DEN] != S.[DAE_DEN]
            OR T.[DAE_NUM1] != S.[DAE_NUM1]
            OR T.[DAE_NUM2] != S.[DAE_NUM2]
            OR T.[DDE_DEN1] != S.[DDE_DEN1]
            OR T.[DDE_DEN2] != S.[DDE_DEN2]
            OR T.[DDE_DEN3] != S.[DDE_DEN3]
            OR T.[DDE_NUM1] != S.[DDE_NUM1]
            OR T.[DDE_NUM2] != S.[DDE_NUM2]
            OR T.[DDE_NUM3] != S.[DDE_NUM3]
            OR T.[PCE_DEN] != S.[PCE_DEN]
            OR T.[PCE_NUM1] != S.[PCE_NUM1]
            OR T.[PCE_NUM2] != S.[PCE_NUM2]
            OR T.[LSC_DEN] != S.[LSC_DEN]
            OR T.[LSC_NUM] != S.[LSC_NUM]
            OR T.[ABA_DEN] != S.[ABA_DEN]
            OR T.[ABA_NUM] != S.[ABA_NUM]
            OR T.[WCC_DEN1_1] != S.[WCC_DEN1_1]
            OR T.[WCC_NUM1_1] != S.[WCC_NUM1_1]
            OR T.[WCC_DEN1_2] != S.[WCC_DEN1_2]
            OR T.[WCC_NUM1_2] != S.[WCC_NUM1_2]
            OR T.[WCC_DEN2_1] != S.[WCC_DEN2_1]
            OR T.[WCC_NUM2_1] != S.[WCC_NUM2_1]
            OR T.[WCC_DEN2_2] != S.[WCC_DEN2_2]
            OR T.[WCC_NUM2_2] != S.[WCC_NUM2_2]
            OR T.[WCC_DEN3_1] != S.[WCC_DEN3_1]
            OR T.[WCC_NUM3_1] != S.[WCC_NUM3_1]
            OR T.[WCC_DEN3_2] != S.[WCC_DEN3_2]
            OR T.[WCC_NUM3_2] != S.[WCC_NUM3_2]
            OR T.[COA_DEN] != S.[COA_DEN]
            OR T.[COA_NUM1] != S.[COA_NUM1]
            OR T.[COA_NUM2] != S.[COA_NUM2]
            OR T.[COA_NUM3] != S.[COA_NUM3]
            OR T.[COA_NUM4] != S.[COA_NUM4]
            OR T.[MRP_DEN] != S.[MRP_DEN]
            OR T.[MRP_NUM] != S.[MRP_NUM]
            OR T.[IMA_DEN] != S.[IMA_DEN]
            OR T.[IMA_NUM1] != S.[IMA_NUM1]
            OR T.[IMA_NUM2] != S.[IMA_NUM2]
            OR T.[IMA_NUM3] != S.[IMA_NUM3]
            OR T.[HPV_DEN] != S.[HPV_DEN]
            OR T.[HPV_NUM] != S.[HPV_NUM]
            OR T.[MMA_DEN1] != S.[MMA_DEN1]
            OR T.[MMA_NUM1_1] != S.[MMA_NUM1_1]
            OR T.[MMA_NUM1_2] != S.[MMA_NUM1_2]
            OR T.[MMA_DEN2] != S.[MMA_DEN2]
            OR T.[MMA_NUM2_1] != S.[MMA_NUM2_1]
            OR T.[MMA_NUM2_2] != S.[MMA_NUM2_2]
            OR T.[MMA_DEN3] != S.[MMA_DEN3]
            OR T.[MMA_NUM3_1] != S.[MMA_NUM3_1]
            OR T.[MMA_NUM3_2] != S.[MMA_NUM3_2]
            OR T.[MMA_DEN4] != S.[MMA_DEN4]
            OR T.[MMA_NUM4_1] != S.[MMA_NUM4_1]
            OR T.[MMA_NUM4_2] != S.[MMA_NUM4_2]
            OR T.[MMA_DEN5] != S.[MMA_DEN5]
            OR T.[MMA_NUM5_1] != S.[MMA_NUM5_1]
            OR T.[MMA_NUM5_2] != S.[MMA_NUM5_2]
            OR T.[MMA_DEN6] != S.[MMA_DEN6]
            OR T.[MMA_NUM6_1] != S.[MMA_NUM6_1]
            OR T.[MMA_NUM6_2] != S.[MMA_NUM6_2]
            OR T.[AMR_DEN1] != S.[AMR_DEN1]
            OR T.[AMR_DEN2] != S.[AMR_DEN2]
            OR T.[AMR_DEN3] != S.[AMR_DEN3]
            OR T.[AMR_DEN4] != S.[AMR_DEN4]
            OR T.[AMR_DEN5] != S.[AMR_DEN5]
            OR T.[AMR_DEN6] != S.[AMR_DEN6]
            OR T.[AMR_NUM1] != S.[AMR_NUM1]
            OR T.[AMR_NUM2] != S.[AMR_NUM2]
            OR T.[AMR_NUM3] != S.[AMR_NUM3]
            OR T.[AMR_NUM4] != S.[AMR_NUM4]
            OR T.[AMR_NUM5] != S.[AMR_NUM5]
            OR T.[AMR_NUM6] != S.[AMR_NUM6]
            OR T.[SMD_DEN] != S.[SMD_DEN]
            OR T.[SMD_NUM] != S.[SMD_NUM]
            OR T.[SAA_DEN] != S.[SAA_DEN]
            OR T.[SAA_NUM] != S.[SAA_NUM]
            OR T.[SSD_DEN] != S.[SSD_DEN]
            OR T.[SSD_NUM] != S.[SSD_NUM]
            OR T.[SMC_DEN] != S.[SMC_DEN]
            OR T.[SMC_NUM] != S.[SMC_NUM]
            OR T.[NCS_DEN] != S.[NCS_DEN]
            OR T.[NCS_NUM] != S.[NCS_NUM]
            OR T.[PSA_DEN] != S.[PSA_DEN]
            OR T.[PSA_NUM] != S.[PSA_NUM]
            OR T.[APC_DEN1] != S.[APC_DEN1]
            OR T.[APC_DEN2] != S.[APC_DEN2]
            OR T.[APC_DEN3] != S.[APC_DEN3]
            OR T.[APC_NUM1] != S.[APC_NUM1]
            OR T.[APC_NUM2] != S.[APC_NUM2]
            OR T.[APC_NUM3] != S.[APC_NUM3]
            OR T.[APM_DEN1] != S.[APM_DEN1]
            OR T.[APM_DEN2] != S.[APM_DEN2]
            OR T.[APM_DEN3] != S.[APM_DEN3]
            OR T.[APM_NUM1] != S.[APM_NUM1]
            OR T.[APM_NUM2] != S.[APM_NUM2]
            OR T.[APM_NUM3] != S.[APM_NUM3]
            OR T.[FPC_DEN] != S.[FPC_DEN]
            OR T.[FPC_NUM1] != S.[FPC_NUM1]
            OR T.[FPC_NUM2] != S.[FPC_NUM2]
            OR T.[FPC_NUM3] != S.[FPC_NUM3]
            OR T.[FPC_NUM4] != S.[FPC_NUM4]
            OR T.[FPC_NUM5] != S.[FPC_NUM5]
            OR T.[W15_DEN] != S.[W15_DEN]
            OR T.[W15_NUM1] != S.[W15_NUM1]
            OR T.[W15_NUM2] != S.[W15_NUM2]
            OR T.[W15_NUM3] != S.[W15_NUM3]
            OR T.[W15_NUM4] != S.[W15_NUM4]
            OR T.[W15_NUM5] != S.[W15_NUM5]
            OR T.[W15_NUM6] != S.[W15_NUM6]
            OR T.[W15_NUM7] != S.[W15_NUM7]
            OR T.[W34_DEN] != S.[W34_DEN]
            OR T.[W34_NUM] != S.[W34_NUM]
            OR T.[AWC_DEN] != S.[AWC_DEN]
            OR T.[AWC_NUM] != S.[AWC_NUM]
            OR T.[FSP_CABG] != S.[FSP_CABG]
            OR T.[FSP_PTCA] != S.[FSP_PTCA]
            OR T.[FSP_CC] != S.[FSP_CC]
            OR T.[FSP_CE] != S.[FSP_CE]
            OR T.[FSP_RDF] != S.[FSP_RDF]
            OR T.[FSP_THR] != S.[FSP_THR]
            OR T.[FSP_TKR] != S.[FSP_TKR]
            OR T.[FSP_EXL] != S.[FSP_EXL]
            OR T.[FSP_CHO] != S.[FSP_CHO]
            OR T.[FSP_CHC] != S.[FSP_CHC]
            OR T.[FSP_HYA] != S.[FSP_HYA]
            OR T.[FSP_HYV] != S.[FSP_HYV]
            OR T.[FSP_PROS] != S.[FSP_PROS]
            OR T.[FSP_DC] != S.[FSP_DC]
            OR T.[FSP_BACK] != S.[FSP_BACK]
            OR T.[FSP_MYR] != S.[FSP_MYR]
            OR T.[FSP_TON] != S.[FSP_TON]
            OR T.[FSP_MAST] != S.[FSP_MAST]
            OR T.[FSP_LUMP] != S.[FSP_LUMP]
            OR T.[FSP_BARI] != S.[FSP_BARI]
            OR T.[IPU_DISCH_TOT] != S.[IPU_DISCH_TOT]
            OR T.[IPU_DAYS_TOT] != S.[IPU_DAYS_TOT]
            OR T.[IPU_DISCH_MAT] != S.[IPU_DISCH_MAT]
            OR T.[IPU_DAYS_MAT] != S.[IPU_DAYS_MAT]
            OR T.[IPU_DISCH_SUR] != S.[IPU_DISCH_SUR]
            OR T.[IPU_DAYS_SUR] != S.[IPU_DAYS_SUR]
            OR T.[IPU_DISCH_MED] != S.[IPU_DISCH_MED]
            OR T.[IPU_DAYS_MED] != S.[IPU_DAYS_MED]
            OR T.[AMB_OV] != S.[AMB_OV]
            OR T.[AMB_ED] != S.[AMB_ED]
            OR T.[AMB_AS] != S.[AMB_AS]
            OR T.[AMB_OR] != S.[AMB_OR]
            OR T.[MPT_ANY] != S.[MPT_ANY]
            OR T.[MPT_INP] != S.[MPT_INP]
            OR T.[MPT_DN] != S.[MPT_DN]
            OR T.[MPT_AMB] != S.[MPT_AMB]
            OR T.[IAD_ANY] != S.[IAD_ANY]
            OR T.[IAD_INP] != S.[IAD_INP]
            OR T.[IAD_DN] != S.[IAD_DN]
            OR T.[IAD_AMB] != S.[IAD_AMB]
            OR T.[TOTAL_ABX_SCRIPTS] != S.[TOTAL_ABX_SCRIPTS]
            OR T.[TOTAL_ABX_DAYS] != S.[TOTAL_ABX_DAYS]
            OR T.[ABX_CONCERN_SCRIPTS] != S.[ABX_CONCERN_SCRIPTS]
            OR T.[ABXQUIN_PMPY] != S.[ABXQUIN_PMPY]
            OR T.[ABXZITH_PMPY] != S.[ABXZITH_PMPY]
            OR T.[ABXCEPH2_PMPY] != S.[ABXCEPH2_PMPY]
            OR T.[ABXCEPH3_PMPY] != S.[ABXCEPH3_PMPY]
            OR T.[ABXAMOX_PMPY] != S.[ABXAMOX_PMPY]
            OR T.[ABXKETO_PMPY] != S.[ABXKETO_PMPY]
            OR T.[ABXCLIND_PMPY] != S.[ABXCLIND_PMPY]
            OR T.[ABXMISC_PMPY] != S.[ABXMISC_PMPY]
            OR T.[ABXABSORB_PMPY] != S.[ABXABSORB_PMPY]
            OR T.[ABXAMINO_PMPY] != S.[ABXAMINO_PMPY]
            OR T.[ABXCEPH1_PMPY] != S.[ABXCEPH1_PMPY]
            OR T.[ABXLINCO_PMPY] != S.[ABXLINCO_PMPY]
            OR T.[ABXMACRO_PMPY] != S.[ABXMACRO_PMPY]
            OR T.[ABXPEN_PMPY] != S.[ABXPEN_PMPY]
            OR T.[ABXTET_PMPY] != S.[ABXTET_PMPY]
            OR T.[ABXMISO_PMPY] != S.[ABXMISO_PMPY]
            OR T.[ABX_ALLOTHER_SCRIPTS] != S.[ABX_ALLOTHER_SCRIPTS]
            OR T.[PCR_DEN] != S.[PCR_DEN]
            OR T.[PCR_NUM] != S.[PCR_NUM]
            OR T.[SUM_WEIGHTS] != S.[SUM_WEIGHTS]
            OR T.[PRED_READM] != S.[PRED_READM]
            OR T.[RDI_DEN] != S.[RDI_DEN]
            OR T.[RDI_EXCL_REQ] != S.[RDI_EXCL_REQ]
            OR T.[RAS_DEN] != S.[RAS_DEN]
            OR T.[RAS_EXCL_REQ] != S.[RAS_EXCL_REQ]
            OR T.[RCA_DEN] != S.[RCA_DEN]
            OR T.[RCA_EXCL_REQ] != S.[RCA_EXCL_REQ]
            OR T.[RCO_DEN] != S.[RCO_DEN]
            OR T.[RCO_EXCL_REQ] != S.[RCO_EXCL_REQ]
            OR T.[RHY_DEN] != S.[RHY_DEN]
            OR T.[RHY_EXCL_REQ] != S.[RHY_EXCL_REQ]
            OR T.[EM_COUNT] != S.[EM_COUNT]
            OR T.[RRU_LOS] != S.[RRU_LOS]
            OR T.[RX_COUNT] != S.[RX_COUNT]
            OR T.[PROC_COUNT] != S.[PROC_COUNT]
            OR T.[CAP_INPATIENT] != S.[CAP_INPATIENT]
            OR T.[CAP_EM_INPATIENT] != S.[CAP_EM_INPATIENT]
            OR T.[CAP_EM_OUTPATIENT] != S.[CAP_EM_OUTPATIENT]
            OR T.[CAP_PROC_INPATIENT] != S.[CAP_PROC_INPATIENT]
            OR T.[CAP_PROC_OUTPATIENT] != S.[CAP_PROC_OUTPATIENT]
            OR T.[CAP_RX] != S.[CAP_RX]
            OR T.[CAP_LAB] != S.[CAP_LAB]
            OR T.[CAP_IMG] != S.[CAP_IMG]
            OR T.[NCQA_PRICE_EM_INP] != S.[NCQA_PRICE_EM_INP]
            OR T.[NCQA_PRICE_EM_OUT] != S.[NCQA_PRICE_EM_OUT]
            OR T.[TOTAL_COST_EM] != S.[TOTAL_COST_EM]
            OR T.[NCQA_PRICE_INP] != S.[NCQA_PRICE_INP]
            OR T.[TOTAL_COST_INP] != S.[TOTAL_COST_INP]
            OR T.[NCQA_PRICE_PROC_INP] != S.[NCQA_PRICE_PROC_INP]
            OR T.[NCQA_PRICE_PROC_OUT] != S.[NCQA_PRICE_PROC_OUT]
            OR T.[TOTAL_COST_PROC] != S.[TOTAL_COST_PROC]
            OR T.[NCQA_PRICE_RX] != S.[NCQA_PRICE_RX]
            OR T.[TOTAL_COST_RX] != S.[TOTAL_COST_RX]
            OR T.[NCQA_PRICE_LAB] != S.[NCQA_PRICE_LAB]
            OR T.[NCQA_PRICE_IMG] != S.[NCQA_PRICE_IMG]
            OR T.[LAB_COUNT] != S.[LAB_COUNT]
            OR T.[IMG_COUNT] != S.[IMG_COUNT]
            OR T.[RRU_MMS_MED] != S.[RRU_MMS_MED]
            OR T.[RRU_MMS_RX] != S.[RRU_MMS_RX]
            OR T.[ED_COUNT] != S.[ED_COUNT]
            OR T.[FREQ_CABG] != S.[FREQ_CABG]
            OR T.[FREQ_CE] != S.[FREQ_CE]
            OR T.[FREQ_PCI] != S.[FREQ_PCI]
            OR T.[FREQ_CC] != S.[FREQ_CC]
            OR T.[FREQ_CASDT] != S.[FREQ_CASDT]
            OR T.[FREQ_CAD_EBCT] != S.[FREQ_CAD_EBCT]
            OR T.[FREQ_CCT] != S.[FREQ_CCT]
            OR T.[RRU_INP_DISCH] != S.[RRU_INP_DISCH]
            OR T.[RRU_INP_DAYS] != S.[RRU_INP_DAYS]
            OR T.[RRU_IPU_DISCH] != S.[RRU_IPU_DISCH]
            OR T.[RRU_IPU_DAYS] != S.[RRU_IPU_DAYS]
            OR T.[RRU_IPU_MED_DISCH] != S.[RRU_IPU_MED_DISCH]
            OR T.[RRU_IPU_MED_DAYS] != S.[RRU_IPU_MED_DAYS]
            OR T.[RRU_IPU_SURG_DISCH] != S.[RRU_IPU_SURG_DISCH]
            OR T.[RRU_IPU_SURG_DAYS] != S.[RRU_IPU_SURG_DAYS]
            OR T.[RRU_NON_DISCH] != S.[RRU_NON_DISCH]
            OR T.[RRU_NON_DAYS] != S.[RRU_NON_DAYS]
            OR T.[RX_N1] != S.[RX_N1]
            OR T.[RX_N2] != S.[RX_N2]
            OR T.[RX_G1] != S.[RX_G1]
            OR T.[RX_G2] != S.[RX_G2]
            OR T.[RRUAG_WEIGHT] != S.[RRUAG_WEIGHT]
            OR T.[RASAG_WEIGHT] != S.[RASAG_WEIGHT]
            OR T.[COMORB_WEIGHT] != S.[COMORB_WEIGHT]
            OR T.[RRU_RISK_GROUP] != S.[RRU_RISK_GROUP]
            OR T.[RAS_RISK_GROUP] != S.[RAS_RISK_GROUP]
            OR T.[SPC_DEN1_1] != S.[SPC_DEN1_1]
            OR T.[SPC_DEN2_1] != S.[SPC_DEN2_1]
            OR T.[SPC_NUM1_1] != S.[SPC_NUM1_1]
            OR T.[SPC_NUM2_1] != S.[SPC_NUM2_1]
            OR T.[SPC_DEN1_2] != S.[SPC_DEN1_2]
            OR T.[SPC_DEN2_2] != S.[SPC_DEN2_2]
            OR T.[SPC_NUM1_2] != S.[SPC_NUM1_2]
            OR T.[SPC_NUM2_2] != S.[SPC_NUM2_2]
            OR T.[SPD_DEN1] != S.[SPD_DEN1]
            OR T.[SPD_DEN2] != S.[SPD_DEN2]
            OR T.[SPD_NUM1] != S.[SPD_NUM1]
            OR T.[SPD_NUM2] != S.[SPD_NUM2]
            OR T.[PDC_DEN1] != S.[PDC_DEN1]
            OR T.[PDC_NUM1] != S.[PDC_NUM1]
            OR T.[PDC_DEN2] != S.[PDC_DEN2]
            OR T.[PDC_NUM2] != S.[PDC_NUM2]
            OR T.[PDC_DEN3] != S.[PDC_DEN3]
            OR T.[PDC_NUM3] != S.[PDC_NUM3]
            OR T.[IHU_DEN] != S.[IHU_DEN]
            OR T.[INP_SUR_CNT] != S.[INP_SUR_CNT]
            OR T.[INP_MED_CNT] != S.[INP_MED_CNT]
            OR T.[INP_TOT_CNT] != S.[INP_TOT_CNT]
            OR T.[EDU_DEN] != S.[EDU_DEN]
            OR T.[ER_CNT] != S.[ER_CNT]
            OR T.[EXP_ER_CNT] != S.[EXP_ER_CNT]
            OR T.[HPC_DEN] != S.[HPC_DEN]
            OR T.[CHRONIC_ACSC_CNT] != S.[CHRONIC_ACSC_CNT]
            OR T.[ACUTE_ACSC_CNT] != S.[ACUTE_ACSC_CNT]
            OR T.[HPC_INP_TOT_CNT] != S.[HPC_INP_TOT_CNT]
            OR T.[EXP_INP_HPCA] != S.[EXP_INP_HPCA]
            OR T.[EXP_INP_HPCCH] != S.[EXP_INP_HPCCH]
            OR T.[EXP_INP_HPTOT] != S.[EXP_INP_HPTOT]
            OR T.[HPCA_PPD_COMORB_WT] != S.[HPCA_PPD_COMORB_WT]
            OR T.[HPCCH_PPD_COMORB_WT] != S.[HPCCH_PPD_COMORB_WT]
            OR T.[HPCT_PPD_COMORB_WT] != S.[HPCT_PPD_COMORB_WT]
            OR T.[HPCA_PPD_AGE_WT] != S.[HPCA_PPD_AGE_WT]
            OR T.[HPCCH_PPD_AGE_WT] != S.[HPCCH_PPD_AGE_WT]
            OR T.[HPCT_PPD_AGE_WT] != S.[HPCT_PPD_AGE_WT]
            OR T.[HPCA_PPD_BASE_WT] != S.[HPCA_PPD_BASE_WT]
            OR T.[HPCCH_PPD_BASE_WT] != S.[HPCCH_PPD_BASE_WT]
            OR T.[HPCT_PPD_BASE_WT] != S.[HPCT_PPD_BASE_WT]
            OR T.[HPCA_PUCD_COMORB_WT] != S.[HPCA_PUCD_COMORB_WT]
            OR T.[HPCCH_PUCD_COMORB_WT] != S.[HPCCH_PUCD_COMORB_WT]
            OR T.[HPCT_PUCD_COMORB_WT] != S.[HPCT_PUCD_COMORB_WT]
            OR T.[HPCA_PUCD_AGE_WT] != S.[HPCA_PUCD_AGE_WT]
            OR T.[HPCCH_PUCD_AGE_WT] != S.[HPCCH_PUCD_AGE_WT]
            OR T.[HPCT_PUCD_AGE_WT] != S.[HPCT_PUCD_AGE_WT]
            OR T.[HPCA_PUCD_BASE_WT] != S.[HPCA_PUCD_BASE_WT]
            OR T.[HPCCH_PUCD_BASE_WT] != S.[HPCCH_PUCD_BASE_WT]
            OR T.[HPCT_PUCD_BASE_WT] != S.[HPCT_PUCD_BASE_WT]
            OR T.[SUR_PPD_COMORB_WT] != S.[SUR_PPD_COMORB_WT]
            OR T.[MED_PPD_COMORB_WT] != S.[MED_PPD_COMORB_WT]
            OR T.[TOT_PPD_COMORB_WT] != S.[TOT_PPD_COMORB_WT]
            OR T.[SUR_PPD_AGE_WT] != S.[SUR_PPD_AGE_WT]
            OR T.[MED_PPD_AGE_WT] != S.[MED_PPD_AGE_WT]
            OR T.[TOT_PPD_AGE_WT] != S.[TOT_PPD_AGE_WT]
            OR T.[SUR_PPD_BASE_WT] != S.[SUR_PPD_BASE_WT]
            OR T.[MED_PPD_BASE_WT] != S.[MED_PPD_BASE_WT]
            OR T.[TOT_PPD_BASE_WT] != S.[TOT_PPD_BASE_WT]
            OR T.[SUR_PUCD_COMORB_WT] != S.[SUR_PUCD_COMORB_WT]
            OR T.[MED_PUCD_COMORB_WT] != S.[MED_PUCD_COMORB_WT]
            OR T.[TOT_PUCD_COMORB_WT] != S.[TOT_PUCD_COMORB_WT]
            OR T.[SUR_PUCD_AGE_WT] != S.[SUR_PUCD_AGE_WT]
            OR T.[MED_PUCD_AGE_WT] != S.[MED_PUCD_AGE_WT]
            OR T.[TOT_PUCD_AGE_WT] != S.[TOT_PUCD_AGE_WT]
            OR T.[SUR_PUCD_BASE_WT] != S.[SUR_PUCD_BASE_WT]
            OR T.[MED_PUCD_BASE_WT] != S.[MED_PUCD_BASE_WT]
            OR T.[TOT_PUCD_BASE_WT] != S.[TOT_PUCD_BASE_WT]
            OR T.[PPV_COMORB_WT] != S.[PPV_COMORB_WT]
            OR T.[PPV_AGE_WT] != S.[PPV_AGE_WT]
            OR T.[PPV_BASE_WT] != S.[PPV_BASE_WT]
            OR T.[PUCV_COMORB_WT] != S.[PUCV_COMORB_WT]
            OR T.[PUCV_AGE_WT] != S.[PUCV_AGE_WT]
            OR T.[PUCV_BASE_WT] != S.[PUCV_BASE_WT]
            OR T.[Case Manager] != S.[Case Manager]
            OR T.[PHO ID] != S.[PHO ID]
            OR T.[PHO Name] != S.[PHO Name]
            OR T.[PCP Name] != S.[PCP Name]
            OR T.[PCP ID] != S.[PCP ID]
            OR T.[LoadDate] != S.[LoadDate]
		  OR T.ClientID != S.ClientID
		  OR T.ProviderID != S.ProviderID
		  OR T.MemberID != S.MemberID THEN
            UPDATE SET
                    T.[MMS_MED] = S.[MMS_MED] ,
                    T.[MMS_RX] = S.[MMS_RX] ,
                    T.[MMS_MH_INP] = S.[MMS_MH_INP] ,
                    T.[MMS_MH_INT] = S.[MMS_MH_INT] ,
                    T.[MMS_MH_AMB] = S.[MMS_MH_AMB] ,
                    T.[MMS_CD_INP] = S.[MMS_CD_INP] ,
                    T.[MMS_CD_INT] = S.[MMS_CD_INT] ,
                    T.[MMS_CD_AMB] = S.[MMS_CD_AMB] ,
                    T.[MMS_DENT] = S.[MMS_DENT] ,
                    T.[AAP_DEN1] = S.[AAP_DEN1] ,
                    T.[AAP_DEN2] = S.[AAP_DEN2] ,
                    T.[AAP_DEN3] = S.[AAP_DEN3] ,
                    T.[AAP_NUM1] = S.[AAP_NUM1] ,
                    T.[AAP_NUM2] = S.[AAP_NUM2] ,
                    T.[AAP_NUM3] = S.[AAP_NUM3] ,
                    T.[CAP_DEN1] = S.[CAP_DEN1] ,
                    T.[CAP_DEN2] = S.[CAP_DEN2] ,
                    T.[CAP_DEN3] = S.[CAP_DEN3] ,
                    T.[CAP_DEN4] = S.[CAP_DEN4] ,
                    T.[CAP_NUM1] = S.[CAP_NUM1] ,
                    T.[CAP_NUM2] = S.[CAP_NUM2] ,
                    T.[CAP_NUM3] = S.[CAP_NUM3] ,
                    T.[CAP_NUM4] = S.[CAP_NUM4] ,
                    T.[PPC_DEN] = S.[PPC_DEN] ,
                    T.[PPC_NUM1] = S.[PPC_NUM1] ,
                    T.[PPC_NUM2] = S.[PPC_NUM2] ,
                    T.[ADV_DEN1] = S.[ADV_DEN1] ,
                    T.[ADV_DEN2] = S.[ADV_DEN2] ,
                    T.[ADV_DEN3] = S.[ADV_DEN3] ,
                    T.[ADV_DEN4] = S.[ADV_DEN4] ,
                    T.[ADV_DEN5] = S.[ADV_DEN5] ,
                    T.[ADV_DEN6] = S.[ADV_DEN6] ,
                    T.[ADV_NUM1] = S.[ADV_NUM1] ,
                    T.[ADV_NUM2] = S.[ADV_NUM2] ,
                    T.[ADV_NUM3] = S.[ADV_NUM3] ,
                    T.[ADV_NUM4] = S.[ADV_NUM4] ,
                    T.[ADV_NUM5] = S.[ADV_NUM5] ,
                    T.[ADV_NUM6] = S.[ADV_NUM6] ,
                    T.[IET_DEN1] = S.[IET_DEN1] ,
                    T.[IET_DEN2] = S.[IET_DEN2] ,
                    T.[IET_NUM1_1] = S.[IET_NUM1_1] ,
                    T.[IET_NUM1_2] = S.[IET_NUM1_2] ,
                    T.[IET_NUM2_1] = S.[IET_NUM2_1] ,
                    T.[IET_NUM2_2] = S.[IET_NUM2_2] ,
                    T.[APP_DEN1] = S.[APP_DEN1] ,
                    T.[APP_DEN2] = S.[APP_DEN2] ,
                    T.[APP_DEN3] = S.[APP_DEN3] ,
                    T.[APP_NUM1] = S.[APP_NUM1] ,
                    T.[APP_NUM2] = S.[APP_NUM2] ,
                    T.[APP_NUM3] = S.[APP_NUM3] ,
                    T.[CIS_DEN] = S.[CIS_DEN] ,
                    T.[CIS_NUM1] = S.[CIS_NUM1] ,
                    T.[CIS_NUM2] = S.[CIS_NUM2] ,
                    T.[CIS_NUM3] = S.[CIS_NUM3] ,
                    T.[CIS_NUM4] = S.[CIS_NUM4] ,
                    T.[CIS_NUM5] = S.[CIS_NUM5] ,
                    T.[CIS_NUM6] = S.[CIS_NUM6] ,
                    T.[CIS_NUM7] = S.[CIS_NUM7] ,
                    T.[CIS_NUM8] = S.[CIS_NUM8] ,
                    T.[CIS_NUM9] = S.[CIS_NUM9] ,
                    T.[CIS_NUM10] = S.[CIS_NUM10] ,
                    T.[CIS_NUM11] = S.[CIS_NUM11] ,
                    T.[CIS_NUM12] = S.[CIS_NUM12] ,
                    T.[CIS_NUM13] = S.[CIS_NUM13] ,
                    T.[CIS_NUM14] = S.[CIS_NUM14] ,
                    T.[CIS_NUM15] = S.[CIS_NUM15] ,
                    T.[CIS_NUM16] = S.[CIS_NUM16] ,
                    T.[CIS_NUM17] = S.[CIS_NUM17] ,
                    T.[CIS_NUM18] = S.[CIS_NUM18] ,
                    T.[CIS_NUM19] = S.[CIS_NUM19] ,
                    T.[URI_DEN] = S.[URI_DEN] ,
                    T.[URI_NUM] = S.[URI_NUM] ,
                    T.[CWP_DEN] = S.[CWP_DEN] ,
                    T.[CWP_NUM] = S.[CWP_NUM] ,
                    T.[COL_DEN] = S.[COL_DEN] ,
                    T.[COL_NUM] = S.[COL_NUM] ,
                    T.[BCS_DEN] = S.[BCS_DEN] ,
                    T.[BCS_NUM] = S.[BCS_NUM] ,
                    T.[CCS_DEN] = S.[CCS_DEN] ,
                    T.[CCS_NUM] = S.[CCS_NUM] ,
                    T.[CHL_DEN1] = S.[CHL_DEN1] ,
                    T.[CHL_DEN2] = S.[CHL_DEN2] ,
                    T.[CHL_NUM1] = S.[CHL_NUM1] ,
                    T.[CHL_NUM2] = S.[CHL_NUM2] ,
                    T.[OMW_DEN] = S.[OMW_DEN] ,
                    T.[OMW_NUM] = S.[OMW_NUM] ,
                    T.[CBP_DEN] = S.[CBP_DEN] ,
                    T.[CBP_NUM] = S.[CBP_NUM] ,
                    T.[PBH_DEN] = S.[PBH_DEN] ,
                    T.[PBH_NUM] = S.[PBH_NUM] ,
                    T.[CMC_DEN] = S.[CMC_DEN] ,
                    T.[CDC_DEN3] = S.[CDC_DEN3] ,
                    T.[CMC_NUM1] = S.[CMC_NUM1] ,
                    T.[CMC_NUM2] = S.[CMC_NUM2] ,
                    T.[CMC_NUM3] = S.[CMC_NUM3] ,
                    T.[CDC_DEN] = S.[CDC_DEN] ,
                    T.[CDC_NUM1] = S.[CDC_NUM1] ,
                    T.[CDC_NUM2] = S.[CDC_NUM2] ,
                    T.[CDC_NUM3] = S.[CDC_NUM3] ,
                    T.[CDC_NUM4] = S.[CDC_NUM4] ,
                    T.[CDC_NUM5] = S.[CDC_NUM5] ,
                    T.[CDC_NUM6] = S.[CDC_NUM6] ,
                    T.[CDC_NUM7] = S.[CDC_NUM7] ,
                    T.[CDC_NUM8] = S.[CDC_NUM8] ,
                    T.[CDC_NUM9] = S.[CDC_NUM9] ,
                    T.[CDC_NUM10] = S.[CDC_NUM10] ,
                    T.[ASM_DEN1] = S.[ASM_DEN1] ,
                    T.[ASM_DEN2] = S.[ASM_DEN2] ,
                    T.[ASM_DEN3] = S.[ASM_DEN3] ,
                    T.[ASM_DEN4] = S.[ASM_DEN4] ,
                    T.[ASM_NUM1] = S.[ASM_NUM1] ,
                    T.[ASM_NUM2] = S.[ASM_NUM2] ,
                    T.[ASM_NUM3] = S.[ASM_NUM3] ,
                    T.[ASM_NUM4] = S.[ASM_NUM4] ,
                    T.[FUH_DEN] = S.[FUH_DEN] ,
                    T.[FUH_NUM1] = S.[FUH_NUM1] ,
                    T.[FUH_NUM2] = S.[FUH_NUM2] ,
                    T.[AMM_DEN] = S.[AMM_DEN] ,
                    T.[AMM_NUM1] = S.[AMM_NUM1] ,
                    T.[AMM_NUM2] = S.[AMM_NUM2] ,
                    T.[AMM_NUM3] = S.[AMM_NUM3] ,
                    T.[GSO_DEN] = S.[GSO_DEN] ,
                    T.[GSO_NUM] = S.[GSO_NUM] ,
                    T.[LBP_DEN] = S.[LBP_DEN] ,
                    T.[LBP_NUM] = S.[LBP_NUM] ,
                    T.[AAB_DEN] = S.[AAB_DEN] ,
                    T.[AAB_NUM] = S.[AAB_NUM] ,
                    T.[SPR_DEN] = S.[SPR_DEN] ,
                    T.[SPR_NUM] = S.[SPR_NUM] ,
                    T.[ADD_DEN1] = S.[ADD_DEN1] ,
                    T.[ADD_NUM1] = S.[ADD_NUM1] ,
                    T.[ADD_DEN2] = S.[ADD_DEN2] ,
                    T.[ADD_NUM2] = S.[ADD_NUM2] ,
                    T.[ART_DEN] = S.[ART_DEN] ,
                    T.[ART_NUM] = S.[ART_NUM] ,
                    T.[MPM_DEN1] = S.[MPM_DEN1] ,
                    T.[MPM_DEN2] = S.[MPM_DEN2] ,
                    T.[MPM_DEN3] = S.[MPM_DEN3] ,
                    T.[MPM_DEN4] = S.[MPM_DEN4] ,
                    T.[MPM_NE1] = S.[MPM_NE1] ,
                    T.[MPM_NE2] = S.[MPM_NE2] ,
                    T.[MPM_NE3] = S.[MPM_NE3] ,
                    T.[MPM_NE4] = S.[MPM_NE4] ,
                    T.[DAE_DEN] = S.[DAE_DEN] ,
                    T.[DAE_NUM1] = S.[DAE_NUM1] ,
                    T.[DAE_NUM2] = S.[DAE_NUM2] ,
                    T.[DDE_DEN1] = S.[DDE_DEN1] ,
                    T.[DDE_DEN2] = S.[DDE_DEN2] ,
                    T.[DDE_DEN3] = S.[DDE_DEN3] ,
                    T.[DDE_NUM1] = S.[DDE_NUM1] ,
                    T.[DDE_NUM2] = S.[DDE_NUM2] ,
                    T.[DDE_NUM3] = S.[DDE_NUM3] ,
                    T.[PCE_DEN] = S.[PCE_DEN] ,
                    T.[PCE_NUM1] = S.[PCE_NUM1] ,
                    T.[PCE_NUM2] = S.[PCE_NUM2] ,
                    T.[LSC_DEN] = S.[LSC_DEN] ,
                    T.[LSC_NUM] = S.[LSC_NUM] ,
                    T.[ABA_DEN] = S.[ABA_DEN] ,
                    T.[ABA_NUM] = S.[ABA_NUM] ,
                    T.[WCC_DEN1_1] = S.[WCC_DEN1_1] ,
                    T.[WCC_NUM1_1] = S.[WCC_NUM1_1] ,
                    T.[WCC_DEN1_2] = S.[WCC_DEN1_2] ,
                    T.[WCC_NUM1_2] = S.[WCC_NUM1_2] ,
                    T.[WCC_DEN2_1] = S.[WCC_DEN2_1] ,
                    T.[WCC_NUM2_1] = S.[WCC_NUM2_1] ,
                    T.[WCC_DEN2_2] = S.[WCC_DEN2_2] ,
                    T.[WCC_NUM2_2] = S.[WCC_NUM2_2] ,
                    T.[WCC_DEN3_1] = S.[WCC_DEN3_1] ,
                    T.[WCC_NUM3_1] = S.[WCC_NUM3_1] ,
                    T.[WCC_DEN3_2] = S.[WCC_DEN3_2] ,
                    T.[WCC_NUM3_2] = S.[WCC_NUM3_2] ,
                    T.[COA_DEN] = S.[COA_DEN] ,
                    T.[COA_NUM1] = S.[COA_NUM1] ,
                    T.[COA_NUM2] = S.[COA_NUM2] ,
                    T.[COA_NUM3] = S.[COA_NUM3] ,
                    T.[COA_NUM4] = S.[COA_NUM4] ,
                    T.[MRP_DEN] = S.[MRP_DEN] ,
                    T.[MRP_NUM] = S.[MRP_NUM] ,
                    T.[IMA_DEN] = S.[IMA_DEN] ,
                    T.[IMA_NUM1] = S.[IMA_NUM1] ,
                    T.[IMA_NUM2] = S.[IMA_NUM2] ,
                    T.[IMA_NUM3] = S.[IMA_NUM3] ,
                    T.[HPV_DEN] = S.[HPV_DEN] ,
                    T.[HPV_NUM] = S.[HPV_NUM] ,
                    T.[MMA_DEN1] = S.[MMA_DEN1] ,
                    T.[MMA_NUM1_1] = S.[MMA_NUM1_1] ,
                    T.[MMA_NUM1_2] = S.[MMA_NUM1_2] ,
                    T.[MMA_DEN2] = S.[MMA_DEN2] ,
                    T.[MMA_NUM2_1] = S.[MMA_NUM2_1] ,
                    T.[MMA_NUM2_2] = S.[MMA_NUM2_2] ,
                    T.[MMA_DEN3] = S.[MMA_DEN3] ,
                    T.[MMA_NUM3_1] = S.[MMA_NUM3_1] ,
                    T.[MMA_NUM3_2] = S.[MMA_NUM3_2] ,
                    T.[MMA_DEN4] = S.[MMA_DEN4] ,
                    T.[MMA_NUM4_1] = S.[MMA_NUM4_1] ,
                    T.[MMA_NUM4_2] = S.[MMA_NUM4_2] ,
                    T.[MMA_DEN5] = S.[MMA_DEN5] ,
                    T.[MMA_NUM5_1] = S.[MMA_NUM5_1] ,
                    T.[MMA_NUM5_2] = S.[MMA_NUM5_2] ,
                    T.[MMA_DEN6] = S.[MMA_DEN6] ,
                    T.[MMA_NUM6_1] = S.[MMA_NUM6_1] ,
                    T.[MMA_NUM6_2] = S.[MMA_NUM6_2] ,
                    T.[AMR_DEN1] = S.[AMR_DEN1] ,
                    T.[AMR_DEN2] = S.[AMR_DEN2] ,
                    T.[AMR_DEN3] = S.[AMR_DEN3] ,
                    T.[AMR_DEN4] = S.[AMR_DEN4] ,
                    T.[AMR_DEN5] = S.[AMR_DEN5] ,
                    T.[AMR_DEN6] = S.[AMR_DEN6] ,
                    T.[AMR_NUM1] = S.[AMR_NUM1] ,
                    T.[AMR_NUM2] = S.[AMR_NUM2] ,
                    T.[AMR_NUM3] = S.[AMR_NUM3] ,
                    T.[AMR_NUM4] = S.[AMR_NUM4] ,
                    T.[AMR_NUM5] = S.[AMR_NUM5] ,
                    T.[AMR_NUM6] = S.[AMR_NUM6] ,
                    T.[SMD_DEN] = S.[SMD_DEN] ,
                    T.[SMD_NUM] = S.[SMD_NUM] ,
                    T.[SAA_DEN] = S.[SAA_DEN] ,
                    T.[SAA_NUM] = S.[SAA_NUM] ,
                    T.[SSD_DEN] = S.[SSD_DEN] ,
                    T.[SSD_NUM] = S.[SSD_NUM] ,
                    T.[SMC_DEN] = S.[SMC_DEN] ,
                    T.[SMC_NUM] = S.[SMC_NUM] ,
                    T.[NCS_DEN] = S.[NCS_DEN] ,
                    T.[NCS_NUM] = S.[NCS_NUM] ,
                    T.[PSA_DEN] = S.[PSA_DEN] ,
                    T.[PSA_NUM] = S.[PSA_NUM] ,
                    T.[APC_DEN1] = S.[APC_DEN1] ,
                    T.[APC_DEN2] = S.[APC_DEN2] ,
                    T.[APC_DEN3] = S.[APC_DEN3] ,
                    T.[APC_NUM1] = S.[APC_NUM1] ,
                    T.[APC_NUM2] = S.[APC_NUM2] ,
                    T.[APC_NUM3] = S.[APC_NUM3] ,
                    T.[APM_DEN1] = S.[APM_DEN1] ,
                    T.[APM_DEN2] = S.[APM_DEN2] ,
                    T.[APM_DEN3] = S.[APM_DEN3] ,
                    T.[APM_NUM1] = S.[APM_NUM1] ,
                    T.[APM_NUM2] = S.[APM_NUM2] ,
                    T.[APM_NUM3] = S.[APM_NUM3] ,
                    T.[FPC_DEN] = S.[FPC_DEN] ,
                    T.[FPC_NUM1] = S.[FPC_NUM1] ,
                    T.[FPC_NUM2] = S.[FPC_NUM2] ,
                    T.[FPC_NUM3] = S.[FPC_NUM3] ,
                    T.[FPC_NUM4] = S.[FPC_NUM4] ,
                    T.[FPC_NUM5] = S.[FPC_NUM5] ,
                    T.[W15_DEN] = S.[W15_DEN] ,
                    T.[W15_NUM1] = S.[W15_NUM1] ,
                    T.[W15_NUM2] = S.[W15_NUM2] ,
                    T.[W15_NUM3] = S.[W15_NUM3] ,
                    T.[W15_NUM4] = S.[W15_NUM4] ,
                    T.[W15_NUM5] = S.[W15_NUM5] ,
                    T.[W15_NUM6] = S.[W15_NUM6] ,
                    T.[W15_NUM7] = S.[W15_NUM7] ,
                    T.[W34_DEN] = S.[W34_DEN] ,
                    T.[W34_NUM] = S.[W34_NUM] ,
                    T.[AWC_DEN] = S.[AWC_DEN] ,
                    T.[AWC_NUM] = S.[AWC_NUM] ,
                    T.[FSP_CABG] = S.[FSP_CABG] ,
                    T.[FSP_PTCA] = S.[FSP_PTCA] ,
                    T.[FSP_CC] = S.[FSP_CC] ,
                    T.[FSP_CE] = S.[FSP_CE] ,
                    T.[FSP_RDF] = S.[FSP_RDF] ,
                    T.[FSP_THR] = S.[FSP_THR] ,
                    T.[FSP_TKR] = S.[FSP_TKR] ,
                    T.[FSP_EXL] = S.[FSP_EXL] ,
                    T.[FSP_CHO] = S.[FSP_CHO] ,
                    T.[FSP_CHC] = S.[FSP_CHC] ,
                    T.[FSP_HYA] = S.[FSP_HYA] ,
                    T.[FSP_HYV] = S.[FSP_HYV] ,
                    T.[FSP_PROS] = S.[FSP_PROS] ,
                    T.[FSP_DC] = S.[FSP_DC] ,
                    T.[FSP_BACK] = S.[FSP_BACK] ,
                    T.[FSP_MYR] = S.[FSP_MYR] ,
                    T.[FSP_TON] = S.[FSP_TON] ,
                    T.[FSP_MAST] = S.[FSP_MAST] ,
                    T.[FSP_LUMP] = S.[FSP_LUMP] ,
                    T.[FSP_BARI] = S.[FSP_BARI] ,
                    T.[IPU_DISCH_TOT] = S.[IPU_DISCH_TOT] ,
                    T.[IPU_DAYS_TOT] = S.[IPU_DAYS_TOT] ,
                    T.[IPU_DISCH_MAT] = S.[IPU_DISCH_MAT] ,
                    T.[IPU_DAYS_MAT] = S.[IPU_DAYS_MAT] ,
                    T.[IPU_DISCH_SUR] = S.[IPU_DISCH_SUR] ,
                    T.[IPU_DAYS_SUR] = S.[IPU_DAYS_SUR] ,
                    T.[IPU_DISCH_MED] = S.[IPU_DISCH_MED] ,
                    T.[IPU_DAYS_MED] = S.[IPU_DAYS_MED] ,
                    T.[AMB_OV] = S.[AMB_OV] ,
                    T.[AMB_ED] = S.[AMB_ED] ,
                    T.[AMB_AS] = S.[AMB_AS] ,
                    T.[AMB_OR] = S.[AMB_OR] ,
                    T.[MPT_ANY] = S.[MPT_ANY] ,
                    T.[MPT_INP] = S.[MPT_INP] ,
                    T.[MPT_DN] = S.[MPT_DN] ,
                    T.[MPT_AMB] = S.[MPT_AMB] ,
                    T.[IAD_ANY] = S.[IAD_ANY] ,
                    T.[IAD_INP] = S.[IAD_INP] ,
                    T.[IAD_DN] = S.[IAD_DN] ,
                    T.[IAD_AMB] = S.[IAD_AMB] ,
                    T.[TOTAL_ABX_SCRIPTS] = S.[TOTAL_ABX_SCRIPTS] ,
                    T.[TOTAL_ABX_DAYS] = S.[TOTAL_ABX_DAYS] ,
                    T.[ABX_CONCERN_SCRIPTS] = S.[ABX_CONCERN_SCRIPTS] ,
                    T.[ABXQUIN_PMPY] = S.[ABXQUIN_PMPY] ,
                    T.[ABXZITH_PMPY] = S.[ABXZITH_PMPY] ,
                    T.[ABXCEPH2_PMPY] = S.[ABXCEPH2_PMPY] ,
                    T.[ABXCEPH3_PMPY] = S.[ABXCEPH3_PMPY] ,
                    T.[ABXAMOX_PMPY] = S.[ABXAMOX_PMPY] ,
                    T.[ABXKETO_PMPY] = S.[ABXKETO_PMPY] ,
                    T.[ABXCLIND_PMPY] = S.[ABXCLIND_PMPY] ,
                    T.[ABXMISC_PMPY] = S.[ABXMISC_PMPY] ,
                    T.[ABXABSORB_PMPY] = S.[ABXABSORB_PMPY] ,
                    T.[ABXAMINO_PMPY] = S.[ABXAMINO_PMPY] ,
                    T.[ABXCEPH1_PMPY] = S.[ABXCEPH1_PMPY] ,
                    T.[ABXLINCO_PMPY] = S.[ABXLINCO_PMPY] ,
                    T.[ABXMACRO_PMPY] = S.[ABXMACRO_PMPY] ,
                    T.[ABXPEN_PMPY] = S.[ABXPEN_PMPY] ,
                    T.[ABXTET_PMPY] = S.[ABXTET_PMPY] ,
                    T.[ABXMISO_PMPY] = S.[ABXMISO_PMPY] ,
                    T.[ABX_ALLOTHER_SCRIPTS] = S.[ABX_ALLOTHER_SCRIPTS] ,
                    T.[PCR_DEN] = S.[PCR_DEN] ,
                    T.[PCR_NUM] = S.[PCR_NUM] ,
                    T.[SUM_WEIGHTS] = S.[SUM_WEIGHTS] ,
                    T.[PRED_READM] = S.[PRED_READM] ,
                    T.[RDI_DEN] = S.[RDI_DEN] ,
                    T.[RDI_EXCL_REQ] = S.[RDI_EXCL_REQ] ,
                    T.[RAS_DEN] = S.[RAS_DEN] ,
                    T.[RAS_EXCL_REQ] = S.[RAS_EXCL_REQ] ,
                    T.[RCA_DEN] = S.[RCA_DEN] ,
                    T.[RCA_EXCL_REQ] = S.[RCA_EXCL_REQ] ,
                    T.[RCO_DEN] = S.[RCO_DEN] ,
                    T.[RCO_EXCL_REQ] = S.[RCO_EXCL_REQ] ,
                    T.[RHY_DEN] = S.[RHY_DEN] ,
                    T.[RHY_EXCL_REQ] = S.[RHY_EXCL_REQ] ,
                    T.[EM_COUNT] = S.[EM_COUNT] ,
                    T.[RRU_LOS] = S.[RRU_LOS] ,
                    T.[RX_COUNT] = S.[RX_COUNT] ,
                    T.[PROC_COUNT] = S.[PROC_COUNT] ,
                    T.[CAP_INPATIENT] = S.[CAP_INPATIENT] ,
                    T.[CAP_EM_INPATIENT] = S.[CAP_EM_INPATIENT] ,
                    T.[CAP_EM_OUTPATIENT] = S.[CAP_EM_OUTPATIENT] ,
                    T.[CAP_PROC_INPATIENT] = S.[CAP_PROC_INPATIENT] ,
                    T.[CAP_PROC_OUTPATIENT] = S.[CAP_PROC_OUTPATIENT] ,
                    T.[CAP_RX] = S.[CAP_RX] ,
                    T.[CAP_LAB] = S.[CAP_LAB] ,
                    T.[CAP_IMG] = S.[CAP_IMG] ,
                    T.[NCQA_PRICE_EM_INP] = S.[NCQA_PRICE_EM_INP] ,
                    T.[NCQA_PRICE_EM_OUT] = S.[NCQA_PRICE_EM_OUT] ,
                    T.[TOTAL_COST_EM] = S.[TOTAL_COST_EM] ,
                    T.[NCQA_PRICE_INP] = S.[NCQA_PRICE_INP] ,
                    T.[TOTAL_COST_INP] = S.[TOTAL_COST_INP] ,
                    T.[NCQA_PRICE_PROC_INP] = S.[NCQA_PRICE_PROC_INP] ,
                    T.[NCQA_PRICE_PROC_OUT] = S.[NCQA_PRICE_PROC_OUT] ,
                    T.[TOTAL_COST_PROC] = S.[TOTAL_COST_PROC] ,
                    T.[NCQA_PRICE_RX] = S.[NCQA_PRICE_RX] ,
                    T.[TOTAL_COST_RX] = S.[TOTAL_COST_RX] ,
                    T.[NCQA_PRICE_LAB] = S.[NCQA_PRICE_LAB] ,
                    T.[NCQA_PRICE_IMG] = S.[NCQA_PRICE_IMG] ,
                    T.[LAB_COUNT] = S.[LAB_COUNT] ,
                    T.[IMG_COUNT] = S.[IMG_COUNT] ,
                    T.[RRU_MMS_MED] = S.[RRU_MMS_MED] ,
                    T.[RRU_MMS_RX] = S.[RRU_MMS_RX] ,
                    T.[ED_COUNT] = S.[ED_COUNT] ,
                    T.[FREQ_CABG] = S.[FREQ_CABG] ,
                    T.[FREQ_CE] = S.[FREQ_CE] ,
                    T.[FREQ_PCI] = S.[FREQ_PCI] ,
                    T.[FREQ_CC] = S.[FREQ_CC] ,
                    T.[FREQ_CASDT] = S.[FREQ_CASDT] ,
                    T.[FREQ_CAD_EBCT] = S.[FREQ_CAD_EBCT] ,
                    T.[FREQ_CCT] = S.[FREQ_CCT] ,
                    T.[RRU_INP_DISCH] = S.[RRU_INP_DISCH] ,
                    T.[RRU_INP_DAYS] = S.[RRU_INP_DAYS] ,
                    T.[RRU_IPU_DISCH] = S.[RRU_IPU_DISCH] ,
                    T.[RRU_IPU_DAYS] = S.[RRU_IPU_DAYS] ,
                    T.[RRU_IPU_MED_DISCH] = S.[RRU_IPU_MED_DISCH] ,
                    T.[RRU_IPU_MED_DAYS] = S.[RRU_IPU_MED_DAYS] ,
                    T.[RRU_IPU_SURG_DISCH] = S.[RRU_IPU_SURG_DISCH] ,
                    T.[RRU_IPU_SURG_DAYS] = S.[RRU_IPU_SURG_DAYS] ,
                    T.[RRU_NON_DISCH] = S.[RRU_NON_DISCH] ,
                    T.[RRU_NON_DAYS] = S.[RRU_NON_DAYS] ,
                    T.[RX_N1] = S.[RX_N1] ,
                    T.[RX_N2] = S.[RX_N2] ,
                    T.[RX_G1] = S.[RX_G1] ,
                    T.[RX_G2] = S.[RX_G2] ,
                    T.[RRUAG_WEIGHT] = S.[RRUAG_WEIGHT] ,
                    T.[RASAG_WEIGHT] = S.[RASAG_WEIGHT] ,
                    T.[COMORB_WEIGHT] = S.[COMORB_WEIGHT] ,
                    T.[RRU_RISK_GROUP] = S.[RRU_RISK_GROUP] ,
                    T.[RAS_RISK_GROUP] = S.[RAS_RISK_GROUP] ,
                    T.[SPC_DEN1_1] = S.[SPC_DEN1_1] ,
                    T.[SPC_DEN2_1] = S.[SPC_DEN2_1] ,
                    T.[SPC_NUM1_1] = S.[SPC_NUM1_1] ,
                    T.[SPC_NUM2_1] = S.[SPC_NUM2_1] ,
                    T.[SPC_DEN1_2] = S.[SPC_DEN1_2] ,
                    T.[SPC_DEN2_2] = S.[SPC_DEN2_2] ,
                    T.[SPC_NUM1_2] = S.[SPC_NUM1_2] ,
                    T.[SPC_NUM2_2] = S.[SPC_NUM2_2] ,
                    T.[SPD_DEN1] = S.[SPD_DEN1] ,
                    T.[SPD_DEN2] = S.[SPD_DEN2] ,
                    T.[SPD_NUM1] = S.[SPD_NUM1] ,
                    T.[SPD_NUM2] = S.[SPD_NUM2] ,
                    T.[PDC_DEN1] = S.[PDC_DEN1] ,
                    T.[PDC_NUM1] = S.[PDC_NUM1] ,
                    T.[PDC_DEN2] = S.[PDC_DEN2] ,
                    T.[PDC_NUM2] = S.[PDC_NUM2] ,
                    T.[PDC_DEN3] = S.[PDC_DEN3] ,
                    T.[PDC_NUM3] = S.[PDC_NUM3] ,
                    T.[IHU_DEN] = S.[IHU_DEN] ,
                    T.[INP_SUR_CNT] = S.[INP_SUR_CNT] ,
                    T.[INP_MED_CNT] = S.[INP_MED_CNT] ,
                    T.[INP_TOT_CNT] = S.[INP_TOT_CNT] ,
                    T.[EDU_DEN] = S.[EDU_DEN] ,
                    T.[ER_CNT] = S.[ER_CNT] ,
                    T.[EXP_ER_CNT] = S.[EXP_ER_CNT] ,
                    T.[HPC_DEN] = S.[HPC_DEN] ,
                    T.[CHRONIC_ACSC_CNT] = S.[CHRONIC_ACSC_CNT] ,
                    T.[ACUTE_ACSC_CNT] = S.[ACUTE_ACSC_CNT] ,
                    T.[HPC_INP_TOT_CNT] = S.[HPC_INP_TOT_CNT] ,
                    T.[EXP_INP_HPCA] = S.[EXP_INP_HPCA] ,
                    T.[EXP_INP_HPCCH] = S.[EXP_INP_HPCCH] ,
                    T.[EXP_INP_HPTOT] = S.[EXP_INP_HPTOT] ,
                    T.[HPCA_PPD_COMORB_WT] = S.[HPCA_PPD_COMORB_WT] ,
                    T.[HPCCH_PPD_COMORB_WT] = S.[HPCCH_PPD_COMORB_WT] ,
                    T.[HPCT_PPD_COMORB_WT] = S.[HPCT_PPD_COMORB_WT] ,
                    T.[HPCA_PPD_AGE_WT] = S.[HPCA_PPD_AGE_WT] ,
                    T.[HPCCH_PPD_AGE_WT] = S.[HPCCH_PPD_AGE_WT] ,
                    T.[HPCT_PPD_AGE_WT] = S.[HPCT_PPD_AGE_WT] ,
                    T.[HPCA_PPD_BASE_WT] = S.[HPCA_PPD_BASE_WT] ,
                    T.[HPCCH_PPD_BASE_WT] = S.[HPCCH_PPD_BASE_WT] ,
                    T.[HPCT_PPD_BASE_WT] = S.[HPCT_PPD_BASE_WT] ,
                    T.[HPCA_PUCD_COMORB_WT] = S.[HPCA_PUCD_COMORB_WT] ,
                    T.[HPCCH_PUCD_COMORB_WT] = S.[HPCCH_PUCD_COMORB_WT] ,
                    T.[HPCT_PUCD_COMORB_WT] = S.[HPCT_PUCD_COMORB_WT] ,
                    T.[HPCA_PUCD_AGE_WT] = S.[HPCA_PUCD_AGE_WT] ,
                    T.[HPCCH_PUCD_AGE_WT] = S.[HPCCH_PUCD_AGE_WT] ,
                    T.[HPCT_PUCD_AGE_WT] = S.[HPCT_PUCD_AGE_WT] ,
                    T.[HPCA_PUCD_BASE_WT] = S.[HPCA_PUCD_BASE_WT] ,
                    T.[HPCCH_PUCD_BASE_WT] = S.[HPCCH_PUCD_BASE_WT] ,
                    T.[HPCT_PUCD_BASE_WT] = S.[HPCT_PUCD_BASE_WT] ,
                    T.[SUR_PPD_COMORB_WT] = S.[SUR_PPD_COMORB_WT] ,
                    T.[MED_PPD_COMORB_WT] = S.[MED_PPD_COMORB_WT] ,
                    T.[TOT_PPD_COMORB_WT] = S.[TOT_PPD_COMORB_WT] ,
                    T.[SUR_PPD_AGE_WT] = S.[SUR_PPD_AGE_WT] ,
                    T.[MED_PPD_AGE_WT] = S.[MED_PPD_AGE_WT] ,
                    T.[TOT_PPD_AGE_WT] = S.[TOT_PPD_AGE_WT] ,
                    T.[SUR_PPD_BASE_WT] = S.[SUR_PPD_BASE_WT] ,
                    T.[MED_PPD_BASE_WT] = S.[MED_PPD_BASE_WT] ,
                    T.[TOT_PPD_BASE_WT] = S.[TOT_PPD_BASE_WT] ,
                    T.[SUR_PUCD_COMORB_WT] = S.[SUR_PUCD_COMORB_WT] ,
                    T.[MED_PUCD_COMORB_WT] = S.[MED_PUCD_COMORB_WT] ,
                    T.[TOT_PUCD_COMORB_WT] = S.[TOT_PUCD_COMORB_WT] ,
                    T.[SUR_PUCD_AGE_WT] = S.[SUR_PUCD_AGE_WT] ,
                    T.[MED_PUCD_AGE_WT] = S.[MED_PUCD_AGE_WT] ,
                    T.[TOT_PUCD_AGE_WT] = S.[TOT_PUCD_AGE_WT] ,
                    T.[SUR_PUCD_BASE_WT] = S.[SUR_PUCD_BASE_WT] ,
                    T.[MED_PUCD_BASE_WT] = S.[MED_PUCD_BASE_WT] ,
                    T.[TOT_PUCD_BASE_WT] = S.[TOT_PUCD_BASE_WT] ,
                    T.[PPV_COMORB_WT] = S.[PPV_COMORB_WT] ,
                    T.[PPV_AGE_WT] = S.[PPV_AGE_WT] ,
                    T.[PPV_BASE_WT] = S.[PPV_BASE_WT] ,
                    T.[PUCV_COMORB_WT] = S.[PUCV_COMORB_WT] ,
                    T.[PUCV_AGE_WT] = S.[PUCV_AGE_WT] ,
                    T.[PUCV_BASE_WT] = S.[PUCV_BASE_WT] ,
                    T.[Case Manager] = S.[Case Manager] ,
                    T.[PHO ID] = S.[PHO ID] ,
                    T.[PHO Name] = S.[PHO Name] ,
                    T.[PCP Name] = S.[PCP Name] ,
                    T.[PCP ID] = S.[PCP ID] ,
                    T.LoadDate = S.LoadDate ,
				T.ClientID = S.ClientID ,
				T.ProviderID = S.ProviderID ,
				T.MemberID = S.MemberID
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CLIENT] ,
                     [CLIENT_MEMBER_STATUS] ,
                     [PRODUCT_ROLLUP_ID] ,
                     [MEM_NBR] ,
                     [MMS_MED] ,
                     [MMS_RX] ,
                     [MMS_MH_INP] ,
                     [MMS_MH_INT] ,
                     [MMS_MH_AMB] ,
                     [MMS_CD_INP] ,
                     [MMS_CD_INT] ,
                     [MMS_CD_AMB] ,
                     [MMS_DENT] ,
                     [AAP_DEN1] ,
                     [AAP_DEN2] ,
                     [AAP_DEN3] ,
                     [AAP_NUM1] ,
                     [AAP_NUM2] ,
                     [AAP_NUM3] ,
                     [CAP_DEN1] ,
                     [CAP_DEN2] ,
                     [CAP_DEN3] ,
                     [CAP_DEN4] ,
                     [CAP_NUM1] ,
                     [CAP_NUM2] ,
                     [CAP_NUM3] ,
                     [CAP_NUM4] ,
                     [PPC_DEN] ,
                     [PPC_NUM1] ,
                     [PPC_NUM2] ,
                     [ADV_DEN1] ,
                     [ADV_DEN2] ,
                     [ADV_DEN3] ,
                     [ADV_DEN4] ,
                     [ADV_DEN5] ,
                     [ADV_DEN6] ,
                     [ADV_NUM1] ,
                     [ADV_NUM2] ,
                     [ADV_NUM3] ,
                     [ADV_NUM4] ,
                     [ADV_NUM5] ,
                     [ADV_NUM6] ,
                     [IET_DEN1] ,
                     [IET_DEN2] ,
                     [IET_NUM1_1] ,
                     [IET_NUM1_2] ,
                     [IET_NUM2_1] ,
                     [IET_NUM2_2] ,
                     [APP_DEN1] ,
                     [APP_DEN2] ,
                     [APP_DEN3] ,
                     [APP_NUM1] ,
                     [APP_NUM2] ,
                     [APP_NUM3] ,
                     [CIS_DEN] ,
                     [CIS_NUM1] ,
                     [CIS_NUM2] ,
                     [CIS_NUM3] ,
                     [CIS_NUM4] ,
                     [CIS_NUM5] ,
                     [CIS_NUM6] ,
                     [CIS_NUM7] ,
                     [CIS_NUM8] ,
                     [CIS_NUM9] ,
                     [CIS_NUM10] ,
                     [CIS_NUM11] ,
                     [CIS_NUM12] ,
                     [CIS_NUM13] ,
                     [CIS_NUM14] ,
                     [CIS_NUM15] ,
                     [CIS_NUM16] ,
                     [CIS_NUM17] ,
                     [CIS_NUM18] ,
                     [CIS_NUM19] ,
                     [URI_DEN] ,
                     [URI_NUM] ,
                     [CWP_DEN] ,
                     [CWP_NUM] ,
                     [COL_DEN] ,
                     [COL_NUM] ,
                     [BCS_DEN] ,
                     [BCS_NUM] ,
                     [CCS_DEN] ,
                     [CCS_NUM] ,
                     [CHL_DEN1] ,
                     [CHL_DEN2] ,
                     [CHL_NUM1] ,
                     [CHL_NUM2] ,
                     [OMW_DEN] ,
                     [OMW_NUM] ,
                     [CBP_DEN] ,
                     [CBP_NUM] ,
                     [PBH_DEN] ,
                     [PBH_NUM] ,
                     [CMC_DEN] ,
                     [CDC_DEN3] ,
                     [CMC_NUM1] ,
                     [CMC_NUM2] ,
                     [CMC_NUM3] ,
                     [CDC_DEN] ,
                     [CDC_NUM1] ,
                     [CDC_NUM2] ,
                     [CDC_NUM3] ,
                     [CDC_NUM4] ,
                     [CDC_NUM5] ,
                     [CDC_NUM6] ,
                     [CDC_NUM7] ,
                     [CDC_NUM8] ,
                     [CDC_NUM9] ,
                     [CDC_NUM10] ,
                     [ASM_DEN1] ,
                     [ASM_DEN2] ,
                     [ASM_DEN3] ,
                     [ASM_DEN4] ,
                     [ASM_NUM1] ,
                     [ASM_NUM2] ,
                     [ASM_NUM3] ,
                     [ASM_NUM4] ,
                     [FUH_DEN] ,
                     [FUH_NUM1] ,
                     [FUH_NUM2] ,
                     [AMM_DEN] ,
                     [AMM_NUM1] ,
                     [AMM_NUM2] ,
                     [AMM_NUM3] ,
                     [GSO_DEN] ,
                     [GSO_NUM] ,
                     [LBP_DEN] ,
                     [LBP_NUM] ,
                     [AAB_DEN] ,
                     [AAB_NUM] ,
                     [SPR_DEN] ,
                     [SPR_NUM] ,
                     [ADD_DEN1] ,
                     [ADD_NUM1] ,
                     [ADD_DEN2] ,
                     [ADD_NUM2] ,
                     [ART_DEN] ,
                     [ART_NUM] ,
                     [MPM_DEN1] ,
                     [MPM_DEN2] ,
                     [MPM_DEN3] ,
                     [MPM_DEN4] ,
                     [MPM_NE1] ,
                     [MPM_NE2] ,
                     [MPM_NE3] ,
                     [MPM_NE4] ,
                     [DAE_DEN] ,
                     [DAE_NUM1] ,
                     [DAE_NUM2] ,
                     [DDE_DEN1] ,
                     [DDE_DEN2] ,
                     [DDE_DEN3] ,
                     [DDE_NUM1] ,
                     [DDE_NUM2] ,
                     [DDE_NUM3] ,
                     [PCE_DEN] ,
                     [PCE_NUM1] ,
                     [PCE_NUM2] ,
                     [LSC_DEN] ,
                     [LSC_NUM] ,
                     [ABA_DEN] ,
                     [ABA_NUM] ,
                     [WCC_DEN1_1] ,
                     [WCC_NUM1_1] ,
                     [WCC_DEN1_2] ,
                     [WCC_NUM1_2] ,
                     [WCC_DEN2_1] ,
                     [WCC_NUM2_1] ,
                     [WCC_DEN2_2] ,
                     [WCC_NUM2_2] ,
                     [WCC_DEN3_1] ,
                     [WCC_NUM3_1] ,
                     [WCC_DEN3_2] ,
                     [WCC_NUM3_2] ,
                     [COA_DEN] ,
                     [COA_NUM1] ,
                     [COA_NUM2] ,
                     [COA_NUM3] ,
                     [COA_NUM4] ,
                     [MRP_DEN] ,
                     [MRP_NUM] ,
                     [IMA_DEN] ,
                     [IMA_NUM1] ,
                     [IMA_NUM2] ,
                     [IMA_NUM3] ,
                     [HPV_DEN] ,
                     [HPV_NUM] ,
                     [MMA_DEN1] ,
                     [MMA_NUM1_1] ,
                     [MMA_NUM1_2] ,
                     [MMA_DEN2] ,
                     [MMA_NUM2_1] ,
                     [MMA_NUM2_2] ,
                     [MMA_DEN3] ,
                     [MMA_NUM3_1] ,
                     [MMA_NUM3_2] ,
                     [MMA_DEN4] ,
                     [MMA_NUM4_1] ,
                     [MMA_NUM4_2] ,
                     [MMA_DEN5] ,
                     [MMA_NUM5_1] ,
                     [MMA_NUM5_2] ,
                     [MMA_DEN6] ,
                     [MMA_NUM6_1] ,
                     [MMA_NUM6_2] ,
                     [AMR_DEN1] ,
                     [AMR_DEN2] ,
                     [AMR_DEN3] ,
                     [AMR_DEN4] ,
                     [AMR_DEN5] ,
                     [AMR_DEN6] ,
                     [AMR_NUM1] ,
                     [AMR_NUM2] ,
                     [AMR_NUM3] ,
                     [AMR_NUM4] ,
                     [AMR_NUM5] ,
                     [AMR_NUM6] ,
                     [SMD_DEN] ,
                     [SMD_NUM] ,
                     [SAA_DEN] ,
                     [SAA_NUM] ,
                     [SSD_DEN] ,
                     [SSD_NUM] ,
                     [SMC_DEN] ,
                     [SMC_NUM] ,
                     [NCS_DEN] ,
                     [NCS_NUM] ,
                     [PSA_DEN] ,
                     [PSA_NUM] ,
                     [APC_DEN1] ,
                     [APC_DEN2] ,
                     [APC_DEN3] ,
                     [APC_NUM1] ,
                     [APC_NUM2] ,
                     [APC_NUM3] ,
                     [APM_DEN1] ,
                     [APM_DEN2] ,
                     [APM_DEN3] ,
                     [APM_NUM1] ,
                     [APM_NUM2] ,
                     [APM_NUM3] ,
                     [FPC_DEN] ,
                     [FPC_NUM1] ,
                     [FPC_NUM2] ,
                     [FPC_NUM3] ,
                     [FPC_NUM4] ,
                     [FPC_NUM5] ,
                     [W15_DEN] ,
                     [W15_NUM1] ,
                     [W15_NUM2] ,
                     [W15_NUM3] ,
                     [W15_NUM4] ,
                     [W15_NUM5] ,
                     [W15_NUM6] ,
                     [W15_NUM7] ,
                     [W34_DEN] ,
                     [W34_NUM] ,
                     [AWC_DEN] ,
                     [AWC_NUM] ,
                     [FSP_CABG] ,
                     [FSP_PTCA] ,
                     [FSP_CC] ,
                     [FSP_CE] ,
                     [FSP_RDF] ,
                     [FSP_THR] ,
                     [FSP_TKR] ,
                     [FSP_EXL] ,
                     [FSP_CHO] ,
                     [FSP_CHC] ,
                     [FSP_HYA] ,
                     [FSP_HYV] ,
                     [FSP_PROS] ,
                     [FSP_DC] ,
                     [FSP_BACK] ,
                     [FSP_MYR] ,
                     [FSP_TON] ,
                     [FSP_MAST] ,
                     [FSP_LUMP] ,
                     [FSP_BARI] ,
                     [IPU_DISCH_TOT] ,
                     [IPU_DAYS_TOT] ,
                     [IPU_DISCH_MAT] ,
                     [IPU_DAYS_MAT] ,
                     [IPU_DISCH_SUR] ,
                     [IPU_DAYS_SUR] ,
                     [IPU_DISCH_MED] ,
                     [IPU_DAYS_MED] ,
                     [AMB_OV] ,
                     [AMB_ED] ,
                     [AMB_AS] ,
                     [AMB_OR] ,
                     [MPT_ANY] ,
                     [MPT_INP] ,
                     [MPT_DN] ,
                     [MPT_AMB] ,
                     [IAD_ANY] ,
                     [IAD_INP] ,
                     [IAD_DN] ,
                     [IAD_AMB] ,
                     [TOTAL_ABX_SCRIPTS] ,
                     [TOTAL_ABX_DAYS] ,
                     [ABX_CONCERN_SCRIPTS] ,
                     [ABXQUIN_PMPY] ,
                     [ABXZITH_PMPY] ,
                     [ABXCEPH2_PMPY] ,
                     [ABXCEPH3_PMPY] ,
                     [ABXAMOX_PMPY] ,
                     [ABXKETO_PMPY] ,
                     [ABXCLIND_PMPY] ,
                     [ABXMISC_PMPY] ,
                     [ABXABSORB_PMPY] ,
                     [ABXAMINO_PMPY] ,
                     [ABXCEPH1_PMPY] ,
                     [ABXLINCO_PMPY] ,
                     [ABXMACRO_PMPY] ,
                     [ABXPEN_PMPY] ,
                     [ABXTET_PMPY] ,
                     [ABXMISO_PMPY] ,
                     [ABX_ALLOTHER_SCRIPTS] ,
                     [PCR_DEN] ,
                     [PCR_NUM] ,
                     [SUM_WEIGHTS] ,
                     [PRED_READM] ,
                     [RDI_DEN] ,
                     [RDI_EXCL_REQ] ,
                     [RAS_DEN] ,
                     [RAS_EXCL_REQ] ,
                     [RCA_DEN] ,
                     [RCA_EXCL_REQ] ,
                     [RCO_DEN] ,
                     [RCO_EXCL_REQ] ,
                     [RHY_DEN] ,
                     [RHY_EXCL_REQ] ,
                     [EM_COUNT] ,
                     [RRU_LOS] ,
                     [RX_COUNT] ,
                     [PROC_COUNT] ,
                     [CAP_INPATIENT] ,
                     [CAP_EM_INPATIENT] ,
                     [CAP_EM_OUTPATIENT] ,
                     [CAP_PROC_INPATIENT] ,
                     [CAP_PROC_OUTPATIENT] ,
                     [CAP_RX] ,
                     [CAP_LAB] ,
                     [CAP_IMG] ,
                     [NCQA_PRICE_EM_INP] ,
                     [NCQA_PRICE_EM_OUT] ,
                     [TOTAL_COST_EM] ,
                     [NCQA_PRICE_INP] ,
                     [TOTAL_COST_INP] ,
                     [NCQA_PRICE_PROC_INP] ,
                     [NCQA_PRICE_PROC_OUT] ,
                     [TOTAL_COST_PROC] ,
                     [NCQA_PRICE_RX] ,
                     [TOTAL_COST_RX] ,
                     [NCQA_PRICE_LAB] ,
                     [NCQA_PRICE_IMG] ,
                     [LAB_COUNT] ,
                     [IMG_COUNT] ,
                     [RRU_MMS_MED] ,
                     [RRU_MMS_RX] ,
                     [ED_COUNT] ,
                     [FREQ_CABG] ,
                     [FREQ_CE] ,
                     [FREQ_PCI] ,
                     [FREQ_CC] ,
                     [FREQ_CASDT] ,
                     [FREQ_CAD_EBCT] ,
                     [FREQ_CCT] ,
                     [RRU_INP_DISCH] ,
                     [RRU_INP_DAYS] ,
                     [RRU_IPU_DISCH] ,
                     [RRU_IPU_DAYS] ,
                     [RRU_IPU_MED_DISCH] ,
                     [RRU_IPU_MED_DAYS] ,
                     [RRU_IPU_SURG_DISCH] ,
                     [RRU_IPU_SURG_DAYS] ,
                     [RRU_NON_DISCH] ,
                     [RRU_NON_DAYS] ,
                     [RX_N1] ,
                     [RX_N2] ,
                     [RX_G1] ,
                     [RX_G2] ,
                     [RRUAG_WEIGHT] ,
                     [RASAG_WEIGHT] ,
                     [COMORB_WEIGHT] ,
                     [RRU_RISK_GROUP] ,
                     [RAS_RISK_GROUP] ,
                     [SPC_DEN1_1] ,
                     [SPC_DEN2_1] ,
                     [SPC_NUM1_1] ,
                     [SPC_NUM2_1] ,
                     [SPC_DEN1_2] ,
                     [SPC_DEN2_2] ,
                     [SPC_NUM1_2] ,
                     [SPC_NUM2_2] ,
                     [SPD_DEN1] ,
                     [SPD_DEN2] ,
                     [SPD_NUM1] ,
                     [SPD_NUM2] ,
                     [PDC_DEN1] ,
                     [PDC_NUM1] ,
                     [PDC_DEN2] ,
                     [PDC_NUM2] ,
                     [PDC_DEN3] ,
                     [PDC_NUM3] ,
                     [IHU_DEN] ,
                     [INP_SUR_CNT] ,
                     [INP_MED_CNT] ,
                     [INP_TOT_CNT] ,
                     [EDU_DEN] ,
                     [ER_CNT] ,
                     [EXP_ER_CNT] ,
                     [HPC_DEN] ,
                     [CHRONIC_ACSC_CNT] ,
                     [ACUTE_ACSC_CNT] ,
                     [HPC_INP_TOT_CNT] ,
                     [EXP_INP_HPCA] ,
                     [EXP_INP_HPCCH] ,
                     [EXP_INP_HPTOT] ,
                     [HPCA_PPD_COMORB_WT] ,
                     [HPCCH_PPD_COMORB_WT] ,
                     [HPCT_PPD_COMORB_WT] ,
                     [HPCA_PPD_AGE_WT] ,
                     [HPCCH_PPD_AGE_WT] ,
                     [HPCT_PPD_AGE_WT] ,
                     [HPCA_PPD_BASE_WT] ,
                     [HPCCH_PPD_BASE_WT] ,
                     [HPCT_PPD_BASE_WT] ,
                     [HPCA_PUCD_COMORB_WT] ,
                     [HPCCH_PUCD_COMORB_WT] ,
                     [HPCT_PUCD_COMORB_WT] ,
                     [HPCA_PUCD_AGE_WT] ,
                     [HPCCH_PUCD_AGE_WT] ,
                     [HPCT_PUCD_AGE_WT] ,
                     [HPCA_PUCD_BASE_WT] ,
                     [HPCCH_PUCD_BASE_WT] ,
                     [HPCT_PUCD_BASE_WT] ,
                     [SUR_PPD_COMORB_WT] ,
                     [MED_PPD_COMORB_WT] ,
                     [TOT_PPD_COMORB_WT] ,
                     [SUR_PPD_AGE_WT] ,
                     [MED_PPD_AGE_WT] ,
                     [TOT_PPD_AGE_WT] ,
                     [SUR_PPD_BASE_WT] ,
                     [MED_PPD_BASE_WT] ,
                     [TOT_PPD_BASE_WT] ,
                     [SUR_PUCD_COMORB_WT] ,
                     [MED_PUCD_COMORB_WT] ,
                     [TOT_PUCD_COMORB_WT] ,
                     [SUR_PUCD_AGE_WT] ,
                     [MED_PUCD_AGE_WT] ,
                     [TOT_PUCD_AGE_WT] ,
                     [SUR_PUCD_BASE_WT] ,
                     [MED_PUCD_BASE_WT] ,
                     [TOT_PUCD_BASE_WT] ,
                     [PPV_COMORB_WT] ,
                     [PPV_AGE_WT] ,
                     [PPV_BASE_WT] ,
                     [PUCV_COMORB_WT] ,
                     [PUCV_AGE_WT] ,
                     [PUCV_BASE_WT] ,
                     [Case Manager] ,
                     [PHO ID] ,
                     [PHO Name] ,
                     [PCP Name] ,
                     [PCP ID] ,
                     [RecordSource] ,
                     [LoadDate] ,
				 ClientID ,
				 ProviderID ,
				 MemberID
                   )
            VALUES ( S.[CLIENT] ,
                     S.[CLIENT_MEMBER_STATUS] ,
                     S.[PRODUCT_ROLLUP_ID] ,
                     S.[MEM_NBR] ,
                     S.[MMS_MED] ,
                     S.[MMS_RX] ,
                     S.[MMS_MH_INP] ,
                     S.[MMS_MH_INT] ,
                     S.[MMS_MH_AMB] ,
                     S.[MMS_CD_INP] ,
                     S.[MMS_CD_INT] ,
                     S.[MMS_CD_AMB] ,
                     S.[MMS_DENT] ,
                     S.[AAP_DEN1] ,
                     S.[AAP_DEN2] ,
                     S.[AAP_DEN3] ,
                     S.[AAP_NUM1] ,
                     S.[AAP_NUM2] ,
                     S.[AAP_NUM3] ,
                     S.[CAP_DEN1] ,
                     S.[CAP_DEN2] ,
                     S.[CAP_DEN3] ,
                     S.[CAP_DEN4] ,
                     S.[CAP_NUM1] ,
                     S.[CAP_NUM2] ,
                     S.[CAP_NUM3] ,
                     S.[CAP_NUM4] ,
                     S.[PPC_DEN] ,
                     S.[PPC_NUM1] ,
                     S.[PPC_NUM2] ,
                     S.[ADV_DEN1] ,
                     S.[ADV_DEN2] ,
                     S.[ADV_DEN3] ,
                     S.[ADV_DEN4] ,
                     S.[ADV_DEN5] ,
                     S.[ADV_DEN6] ,
                     S.[ADV_NUM1] ,
                     S.[ADV_NUM2] ,
                     S.[ADV_NUM3] ,
                     S.[ADV_NUM4] ,
                     S.[ADV_NUM5] ,
                     S.[ADV_NUM6] ,
                     S.[IET_DEN1] ,
                     S.[IET_DEN2] ,
                     S.[IET_NUM1_1] ,
                     S.[IET_NUM1_2] ,
                     S.[IET_NUM2_1] ,
                     S.[IET_NUM2_2] ,
                     S.[APP_DEN1] ,
                     S.[APP_DEN2] ,
                     S.[APP_DEN3] ,
                     S.[APP_NUM1] ,
                     S.[APP_NUM2] ,
                     S.[APP_NUM3] ,
                     S.[CIS_DEN] ,
                     S.[CIS_NUM1] ,
                     S.[CIS_NUM2] ,
                     S.[CIS_NUM3] ,
                     S.[CIS_NUM4] ,
                     S.[CIS_NUM5] ,
                     S.[CIS_NUM6] ,
                     S.[CIS_NUM7] ,
                     S.[CIS_NUM8] ,
                     S.[CIS_NUM9] ,
                     S.[CIS_NUM10] ,
                     S.[CIS_NUM11] ,
                     S.[CIS_NUM12] ,
                     S.[CIS_NUM13] ,
                     S.[CIS_NUM14] ,
                     S.[CIS_NUM15] ,
                     S.[CIS_NUM16] ,
                     S.[CIS_NUM17] ,
                     S.[CIS_NUM18] ,
                     S.[CIS_NUM19] ,
                     S.[URI_DEN] ,
                     S.[URI_NUM] ,
                     S.[CWP_DEN] ,
                     S.[CWP_NUM] ,
                     S.[COL_DEN] ,
                     S.[COL_NUM] ,
                     S.[BCS_DEN] ,
                     S.[BCS_NUM] ,
                     S.[CCS_DEN] ,
                     S.[CCS_NUM] ,
                     S.[CHL_DEN1] ,
                     S.[CHL_DEN2] ,
                     S.[CHL_NUM1] ,
                     S.[CHL_NUM2] ,
                     S.[OMW_DEN] ,
                     S.[OMW_NUM] ,
                     S.[CBP_DEN] ,
                     S.[CBP_NUM] ,
                     S.[PBH_DEN] ,
                     S.[PBH_NUM] ,
                     S.[CMC_DEN] ,
                     S.[CDC_DEN3] ,
                     S.[CMC_NUM1] ,
                     S.[CMC_NUM2] ,
                     S.[CMC_NUM3] ,
                     S.[CDC_DEN] ,
                     S.[CDC_NUM1] ,
                     S.[CDC_NUM2] ,
                     S.[CDC_NUM3] ,
                     S.[CDC_NUM4] ,
                     S.[CDC_NUM5] ,
                     S.[CDC_NUM6] ,
                     S.[CDC_NUM7] ,
                     S.[CDC_NUM8] ,
                     S.[CDC_NUM9] ,
                     S.[CDC_NUM10] ,
                     S.[ASM_DEN1] ,
                     S.[ASM_DEN2] ,
                     S.[ASM_DEN3] ,
                     S.[ASM_DEN4] ,
                     S.[ASM_NUM1] ,
                     S.[ASM_NUM2] ,
                     S.[ASM_NUM3] ,
                     S.[ASM_NUM4] ,
                     S.[FUH_DEN] ,
                     S.[FUH_NUM1] ,
                     S.[FUH_NUM2] ,
                     S.[AMM_DEN] ,
                     S.[AMM_NUM1] ,
                     S.[AMM_NUM2] ,
                     S.[AMM_NUM3] ,
                     S.[GSO_DEN] ,
                     S.[GSO_NUM] ,
                     S.[LBP_DEN] ,
                     S.[LBP_NUM] ,
                     S.[AAB_DEN] ,
                     S.[AAB_NUM] ,
                     S.[SPR_DEN] ,
                     S.[SPR_NUM] ,
                     S.[ADD_DEN1] ,
                     S.[ADD_NUM1] ,
                     S.[ADD_DEN2] ,
                     S.[ADD_NUM2] ,
                     S.[ART_DEN] ,
                     S.[ART_NUM] ,
                     S.[MPM_DEN1] ,
                     S.[MPM_DEN2] ,
                     S.[MPM_DEN3] ,
                     S.[MPM_DEN4] ,
                     S.[MPM_NE1] ,
                     S.[MPM_NE2] ,
                     S.[MPM_NE3] ,
                     S.[MPM_NE4] ,
                     S.[DAE_DEN] ,
                     S.[DAE_NUM1] ,
                     S.[DAE_NUM2] ,
                     S.[DDE_DEN1] ,
                     S.[DDE_DEN2] ,
                     S.[DDE_DEN3] ,
                     S.[DDE_NUM1] ,
                     S.[DDE_NUM2] ,
                     S.[DDE_NUM3] ,
                     S.[PCE_DEN] ,
                     S.[PCE_NUM1] ,
                     S.[PCE_NUM2] ,
                     S.[LSC_DEN] ,
                     S.[LSC_NUM] ,
                     S.[ABA_DEN] ,
                     S.[ABA_NUM] ,
                     S.[WCC_DEN1_1] ,
                     S.[WCC_NUM1_1] ,
                     S.[WCC_DEN1_2] ,
                     S.[WCC_NUM1_2] ,
                     S.[WCC_DEN2_1] ,
                     S.[WCC_NUM2_1] ,
                     S.[WCC_DEN2_2] ,
                     S.[WCC_NUM2_2] ,
                     S.[WCC_DEN3_1] ,
                     S.[WCC_NUM3_1] ,
                     S.[WCC_DEN3_2] ,
                     S.[WCC_NUM3_2] ,
                     S.[COA_DEN] ,
                     S.[COA_NUM1] ,
                     S.[COA_NUM2] ,
                     S.[COA_NUM3] ,
                     S.[COA_NUM4] ,
                     S.[MRP_DEN] ,
                     S.[MRP_NUM] ,
                     S.[IMA_DEN] ,
                     S.[IMA_NUM1] ,
                     S.[IMA_NUM2] ,
                     S.[IMA_NUM3] ,
                     S.[HPV_DEN] ,
                     S.[HPV_NUM] ,
                     S.[MMA_DEN1] ,
                     S.[MMA_NUM1_1] ,
                     S.[MMA_NUM1_2] ,
                     S.[MMA_DEN2] ,
                     S.[MMA_NUM2_1] ,
                     S.[MMA_NUM2_2] ,
                     S.[MMA_DEN3] ,
                     S.[MMA_NUM3_1] ,
                     S.[MMA_NUM3_2] ,
                     S.[MMA_DEN4] ,
                     S.[MMA_NUM4_1] ,
                     S.[MMA_NUM4_2] ,
                     S.[MMA_DEN5] ,
                     S.[MMA_NUM5_1] ,
                     S.[MMA_NUM5_2] ,
                     S.[MMA_DEN6] ,
                     S.[MMA_NUM6_1] ,
                     S.[MMA_NUM6_2] ,
                     S.[AMR_DEN1] ,
                     S.[AMR_DEN2] ,
                     S.[AMR_DEN3] ,
                     S.[AMR_DEN4] ,
                     S.[AMR_DEN5] ,
                     S.[AMR_DEN6] ,
                     S.[AMR_NUM1] ,
                     S.[AMR_NUM2] ,
                     S.[AMR_NUM3] ,
                     S.[AMR_NUM4] ,
                     S.[AMR_NUM5] ,
                     S.[AMR_NUM6] ,
                     S.[SMD_DEN] ,
                     S.[SMD_NUM] ,
                     S.[SAA_DEN] ,
                     S.[SAA_NUM] ,
                     S.[SSD_DEN] ,
                     S.[SSD_NUM] ,
                     S.[SMC_DEN] ,
                     S.[SMC_NUM] ,
                     S.[NCS_DEN] ,
                     S.[NCS_NUM] ,
                     S.[PSA_DEN] ,
                     S.[PSA_NUM] ,
                     S.[APC_DEN1] ,
                     S.[APC_DEN2] ,
                     S.[APC_DEN3] ,
                     S.[APC_NUM1] ,
                     S.[APC_NUM2] ,
                     S.[APC_NUM3] ,
                     S.[APM_DEN1] ,
                     S.[APM_DEN2] ,
                     S.[APM_DEN3] ,
                     S.[APM_NUM1] ,
                     S.[APM_NUM2] ,
                     S.[APM_NUM3] ,
                     S.[FPC_DEN] ,
                     S.[FPC_NUM1] ,
                     S.[FPC_NUM2] ,
                     S.[FPC_NUM3] ,
                     S.[FPC_NUM4] ,
                     S.[FPC_NUM5] ,
                     S.[W15_DEN] ,
                     S.[W15_NUM1] ,
                     S.[W15_NUM2] ,
                     S.[W15_NUM3] ,
                     S.[W15_NUM4] ,
                     S.[W15_NUM5] ,
                     S.[W15_NUM6] ,
                     S.[W15_NUM7] ,
                     S.[W34_DEN] ,
                     S.[W34_NUM] ,
                     S.[AWC_DEN] ,
                     S.[AWC_NUM] ,
                     S.[FSP_CABG] ,
                     S.[FSP_PTCA] ,
                     S.[FSP_CC] ,
                     S.[FSP_CE] ,
                     S.[FSP_RDF] ,
                     S.[FSP_THR] ,
                     S.[FSP_TKR] ,
                     S.[FSP_EXL] ,
                     S.[FSP_CHO] ,
                     S.[FSP_CHC] ,
                     S.[FSP_HYA] ,
                     S.[FSP_HYV] ,
                     S.[FSP_PROS] ,
                     S.[FSP_DC] ,
                     S.[FSP_BACK] ,
                     S.[FSP_MYR] ,
                     S.[FSP_TON] ,
                     S.[FSP_MAST] ,
                     S.[FSP_LUMP] ,
                     S.[FSP_BARI] ,
                     S.[IPU_DISCH_TOT] ,
                     S.[IPU_DAYS_TOT] ,
                     S.[IPU_DISCH_MAT] ,
                     S.[IPU_DAYS_MAT] ,
                     S.[IPU_DISCH_SUR] ,
                     S.[IPU_DAYS_SUR] ,
                     S.[IPU_DISCH_MED] ,
                     S.[IPU_DAYS_MED] ,
                     S.[AMB_OV] ,
                     S.[AMB_ED] ,
                     S.[AMB_AS] ,
                     S.[AMB_OR] ,
                     S.[MPT_ANY] ,
                     S.[MPT_INP] ,
                     S.[MPT_DN] ,
                     S.[MPT_AMB] ,
                     S.[IAD_ANY] ,
                     S.[IAD_INP] ,
                     S.[IAD_DN] ,
                     S.[IAD_AMB] ,
                     S.[TOTAL_ABX_SCRIPTS] ,
                     S.[TOTAL_ABX_DAYS] ,
                     S.[ABX_CONCERN_SCRIPTS] ,
                     S.[ABXQUIN_PMPY] ,
                     S.[ABXZITH_PMPY] ,
                     S.[ABXCEPH2_PMPY] ,
                     S.[ABXCEPH3_PMPY] ,
                     S.[ABXAMOX_PMPY] ,
                     S.[ABXKETO_PMPY] ,
                     S.[ABXCLIND_PMPY] ,
                     S.[ABXMISC_PMPY] ,
                     S.[ABXABSORB_PMPY] ,
                     S.[ABXAMINO_PMPY] ,
                     S.[ABXCEPH1_PMPY] ,
                     S.[ABXLINCO_PMPY] ,
                     S.[ABXMACRO_PMPY] ,
                     S.[ABXPEN_PMPY] ,
                     S.[ABXTET_PMPY] ,
                     S.[ABXMISO_PMPY] ,
                     S.[ABX_ALLOTHER_SCRIPTS] ,
                     S.[PCR_DEN] ,
                     S.[PCR_NUM] ,
                     S.[SUM_WEIGHTS] ,
                     S.[PRED_READM] ,
                     S.[RDI_DEN] ,
                     S.[RDI_EXCL_REQ] ,
                     S.[RAS_DEN] ,
                     S.[RAS_EXCL_REQ] ,
                     S.[RCA_DEN] ,
                     S.[RCA_EXCL_REQ] ,
                     S.[RCO_DEN] ,
                     S.[RCO_EXCL_REQ] ,
                     S.[RHY_DEN] ,
                     S.[RHY_EXCL_REQ] ,
                     S.[EM_COUNT] ,
                     S.[RRU_LOS] ,
                     S.[RX_COUNT] ,
                     S.[PROC_COUNT] ,
                     S.[CAP_INPATIENT] ,
                     S.[CAP_EM_INPATIENT] ,
                     S.[CAP_EM_OUTPATIENT] ,
                     S.[CAP_PROC_INPATIENT] ,
                     S.[CAP_PROC_OUTPATIENT] ,
                     S.[CAP_RX] ,
                     S.[CAP_LAB] ,
                     S.[CAP_IMG] ,
                     S.[NCQA_PRICE_EM_INP] ,
                     S.[NCQA_PRICE_EM_OUT] ,
                     S.[TOTAL_COST_EM] ,
                     S.[NCQA_PRICE_INP] ,
                     S.[TOTAL_COST_INP] ,
                     S.[NCQA_PRICE_PROC_INP] ,
                     S.[NCQA_PRICE_PROC_OUT] ,
                     S.[TOTAL_COST_PROC] ,
                     S.[NCQA_PRICE_RX] ,
                     S.[TOTAL_COST_RX] ,
                     S.[NCQA_PRICE_LAB] ,
                     S.[NCQA_PRICE_IMG] ,
                     S.[LAB_COUNT] ,
                     S.[IMG_COUNT] ,
                     S.[RRU_MMS_MED] ,
                     S.[RRU_MMS_RX] ,
                     S.[ED_COUNT] ,
                     S.[FREQ_CABG] ,
                     S.[FREQ_CE] ,
                     S.[FREQ_PCI] ,
                     S.[FREQ_CC] ,
                     S.[FREQ_CASDT] ,
                     S.[FREQ_CAD_EBCT] ,
                     S.[FREQ_CCT] ,
                     S.[RRU_INP_DISCH] ,
                     S.[RRU_INP_DAYS] ,
                     S.[RRU_IPU_DISCH] ,
                     S.[RRU_IPU_DAYS] ,
                     S.[RRU_IPU_MED_DISCH] ,
                     S.[RRU_IPU_MED_DAYS] ,
                     S.[RRU_IPU_SURG_DISCH] ,
                     S.[RRU_IPU_SURG_DAYS] ,
                     S.[RRU_NON_DISCH] ,
                     S.[RRU_NON_DAYS] ,
                     S.[RX_N1] ,
                     S.[RX_N2] ,
                     S.[RX_G1] ,
                     S.[RX_G2] ,
                     S.[RRUAG_WEIGHT] ,
                     S.[RASAG_WEIGHT] ,
                     S.[COMORB_WEIGHT] ,
                     S.[RRU_RISK_GROUP] ,
                     S.[RAS_RISK_GROUP] ,
                     S.[SPC_DEN1_1] ,
                     S.[SPC_DEN2_1] ,
                     S.[SPC_NUM1_1] ,
                     S.[SPC_NUM2_1] ,
                     S.[SPC_DEN1_2] ,
                     S.[SPC_DEN2_2] ,
                     S.[SPC_NUM1_2] ,
                     S.[SPC_NUM2_2] ,
                     S.[SPD_DEN1] ,
                     S.[SPD_DEN2] ,
                     S.[SPD_NUM1] ,
                     S.[SPD_NUM2] ,
                     S.[PDC_DEN1] ,
                     S.[PDC_NUM1] ,
                     S.[PDC_DEN2] ,
                     S.[PDC_NUM2] ,
                     S.[PDC_DEN3] ,
                     S.[PDC_NUM3] ,
                     S.[IHU_DEN] ,
                     S.[INP_SUR_CNT] ,
                     S.[INP_MED_CNT] ,
                     S.[INP_TOT_CNT] ,
                     S.[EDU_DEN] ,
                     S.[ER_CNT] ,
                     S.[EXP_ER_CNT] ,
                     S.[HPC_DEN] ,
                     S.[CHRONIC_ACSC_CNT] ,
                     S.[ACUTE_ACSC_CNT] ,
                     S.[HPC_INP_TOT_CNT] ,
                     S.[EXP_INP_HPCA] ,
                     S.[EXP_INP_HPCCH] ,
                     S.[EXP_INP_HPTOT] ,
                     S.[HPCA_PPD_COMORB_WT] ,
                     S.[HPCCH_PPD_COMORB_WT] ,
                     S.[HPCT_PPD_COMORB_WT] ,
                     S.[HPCA_PPD_AGE_WT] ,
                     S.[HPCCH_PPD_AGE_WT] ,
                     S.[HPCT_PPD_AGE_WT] ,
                     S.[HPCA_PPD_BASE_WT] ,
                     S.[HPCCH_PPD_BASE_WT] ,
                     S.[HPCT_PPD_BASE_WT] ,
                     S.[HPCA_PUCD_COMORB_WT] ,
                     S.[HPCCH_PUCD_COMORB_WT] ,
                     S.[HPCT_PUCD_COMORB_WT] ,
                     S.[HPCA_PUCD_AGE_WT] ,
                     S.[HPCCH_PUCD_AGE_WT] ,
                     S.[HPCT_PUCD_AGE_WT] ,
                     S.[HPCA_PUCD_BASE_WT] ,
                     S.[HPCCH_PUCD_BASE_WT] ,
                     S.[HPCT_PUCD_BASE_WT] ,
                     S.[SUR_PPD_COMORB_WT] ,
                     S.[MED_PPD_COMORB_WT] ,
                     S.[TOT_PPD_COMORB_WT] ,
                     S.[SUR_PPD_AGE_WT] ,
                     S.[MED_PPD_AGE_WT] ,
                     S.[TOT_PPD_AGE_WT] ,
                     S.[SUR_PPD_BASE_WT] ,
                     S.[MED_PPD_BASE_WT] ,
                     S.[TOT_PPD_BASE_WT] ,
                     S.[SUR_PUCD_COMORB_WT] ,
                     S.[MED_PUCD_COMORB_WT] ,
                     S.[TOT_PUCD_COMORB_WT] ,
                     S.[SUR_PUCD_AGE_WT] ,
                     S.[MED_PUCD_AGE_WT] ,
                     S.[TOT_PUCD_AGE_WT] ,
                     S.[SUR_PUCD_BASE_WT] ,
                     S.[MED_PUCD_BASE_WT] ,
                     S.[TOT_PUCD_BASE_WT] ,
                     S.[PPV_COMORB_WT] ,
                     S.[PPV_AGE_WT] ,
                     S.[PPV_BASE_WT] ,
                     S.[PUCV_COMORB_WT] ,
                     S.[PUCV_AGE_WT] ,
                     S.[PUCV_BASE_WT] ,
                     S.[Case Manager] ,
                     S.[PHO ID] ,
                     S.[PHO Name] ,
                     S.[PCP Name] ,
                     S.[PCP ID] ,
                     S.[RecordSource] ,
                     S.[LoadDate] ,
				 S.ClientID ,
				 S.ProviderID ,
				 S.MemberID
                   );


    END;     
GO
