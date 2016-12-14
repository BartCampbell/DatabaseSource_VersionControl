SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dv].[HEDIS_Import]
AS
     
SELECT 

	   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.Client_BK,''))),':',RTRIM(LTRIM(COALESCE(i.[PRODUCT_ROLLUP_ID],''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,'')))))),2)) AS [H_HEDIS_RK],
	   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',1),''))),':',RTRIM(LTRIM(COALESCE(i.[PRODUCT_ROLLUP_ID],''))),':',RTRIM(LTRIM(COALESCE(i.[MEM_NBR],'')))))),2)) AS [HEDIS_BK],
	   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(
	   RTRIM(LTRIM(COALESCE(i.RecordSource,''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.LoadDate,''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PRODUCT_ROLLUP_ID],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MEM_NBR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_INT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_INT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_DENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM8],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM9],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM10],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM11],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM12],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM13],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM14],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM15],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM16],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM17],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM18],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM19],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[URI_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[URI_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CWP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CWP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COL_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COL_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[BCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[BCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[OMW_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[OMW_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CBP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CBP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PBH_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PBH_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM8],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM9],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM10],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[GSO_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[GSO_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LBP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LBP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAB_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAB_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SPR_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SPR_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ART_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ART_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LSC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LSC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MRP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MRP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[HPV_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[HPV_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM4_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM4_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMD_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMD_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SAA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SAA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SSD_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SSD_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PSA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PSA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W34_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W34_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AWC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AWC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CABG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_PTCA],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CE],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_RDF],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_THR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_TKR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_EXL],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CHO],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CHC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_HYA],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_HYV],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_PROS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_DC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_BACK],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_MYR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_TON],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_MAST],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_LUMP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_BARI],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_TOT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_TOT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_MAT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_MAT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_SUR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_SUR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_OV],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_ED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_AS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_OR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_ANY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_DN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_ANY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_DN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_ABX_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_ABX_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABX_CONCERN_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXQUIN_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXZITH_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH2_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH3_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXAMOX_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXKETO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCLIND_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMISC_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXABSORB_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXAMINO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH1_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXLINCO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMACRO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXPEN_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXTET_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMISO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABX_ALLOTHER_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCR_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCR_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SUM_WEIGHTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PRED_READM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RDI_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RDI_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCA_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCO_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCO_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RHY_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RHY_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[EM_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_LOS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PROC_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_EM_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_EM_OUTPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_PROC_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_PROC_OUTPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_LAB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_IMG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_EM_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_EM_OUT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_EM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_PROC_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_PROC_OUT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_PROC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_LAB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_IMG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LAB_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMG_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_MMS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_MMS_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ED_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CABG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CE],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_PCI],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CASDT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CAD_EBCT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CCT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_INP_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_INP_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_MED_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_MED_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_SURG_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_SURG_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_NON_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_NON_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_N1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_N2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_G1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_G2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRUAG_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RASAG_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COMORB_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_RISK_GROUP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_RISK_GROUP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[Case Manager],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PHO ID],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PHO Name],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCP Name],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCP ID],'')))
	   )),2)) AS S_HEDISDetail_RK,
	   dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',1) AS CLIENT,
	   dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',2) AS CLIENT_MEMBER_STATUS,
	   i.[PRODUCT_ROLLUP_ID],
	   i.[MEM_NBR],
	   i.[RecordSource],
	   i.[LoadDate],
	   i.[MMS_MED],
	   i.[MMS_RX],
	   i.[MMS_MH_INP],
	   i.[MMS_MH_INT],
	   i.[MMS_MH_AMB],
	   i.[MMS_CD_INP],
	   i.[MMS_CD_INT],
	   i.[MMS_CD_AMB],
	   i.[MMS_DENT],
	   i.[AAP_DEN1],
	   i.[AAP_DEN2],
	   i.[AAP_DEN3],
	   i.[AAP_NUM1],
	   i.[AAP_NUM2],
	   i.[AAP_NUM3],
	   i.[CAP_DEN1],
	   i.[CAP_DEN2],
	   i.[CAP_DEN3],
	   i.[CAP_DEN4],
	   i.[CAP_NUM1],
	   i.[CAP_NUM2],
	   i.[CAP_NUM3],
	   i.[CAP_NUM4],
	   i.[PPC_DEN],
	   i.[PPC_NUM1],
	   i.[PPC_NUM2],
	   i.[ADV_DEN1],
	   i.[ADV_DEN2],
	   i.[ADV_DEN3],
	   i.[ADV_DEN4],
	   i.[ADV_DEN5],
	   i.[ADV_DEN6],
	   i.[ADV_NUM1],
	   i.[ADV_NUM2],
	   i.[ADV_NUM3],
	   i.[ADV_NUM4],
	   i.[ADV_NUM5],
	   i.[ADV_NUM6],
	   i.[IET_DEN1],
	   i.[IET_DEN2],
	   i.[IET_NUM1_1],
	   i.[IET_NUM1_2],
	   i.[IET_NUM2_1],
	   i.[IET_NUM2_2],
	   i.[APP_DEN1],
	   i.[APP_DEN2],
	   i.[APP_DEN3],
	   i.[APP_NUM1],
	   i.[APP_NUM2],
	   i.[APP_NUM3],
	   i.[CIS_DEN],
	   i.[CIS_NUM1],
	   i.[CIS_NUM2],
	   i.[CIS_NUM3],
	   i.[CIS_NUM4],
	   i.[CIS_NUM5],
	   i.[CIS_NUM6],
	   i.[CIS_NUM7],
	   i.[CIS_NUM8],
	   i.[CIS_NUM9],
	   i.[CIS_NUM10],
	   i.[CIS_NUM11],
	   i.[CIS_NUM12],
	   i.[CIS_NUM13],
	   i.[CIS_NUM14],
	   i.[CIS_NUM15],
	   i.[CIS_NUM16],
	   i.[CIS_NUM17],
	   i.[CIS_NUM18],
	   i.[CIS_NUM19],
	   i.[URI_DEN],
	   i.[URI_NUM],
	   i.[CWP_DEN],
	   i.[CWP_NUM],
	   i.[COL_DEN],
	   i.[COL_NUM],
	   i.[BCS_DEN],
	   i.[BCS_NUM],
	   i.[CCS_DEN],
	   i.[CCS_NUM],
	   i.[CHL_DEN1],
	   i.[CHL_DEN2],
	   i.[CHL_NUM1],
	   i.[CHL_NUM2],
	   i.[OMW_DEN],
	   i.[OMW_NUM],
	   i.[CBP_DEN],
	   i.[CBP_NUM],
	   i.[PBH_DEN],
	   i.[PBH_NUM],
	   i.[CMC_DEN],
	   i.[CMC_NUM1],
	   i.[CMC_NUM2],
	   i.[CMC_NUM3],
	   i.[CDC_DEN],
	   i.[CDC_NUM1],
	   i.[CDC_NUM2],
	   i.[CDC_NUM3],
	   i.[CDC_NUM4],
	   i.[CDC_NUM5],
	   i.[CDC_NUM6],
	   i.[CDC_NUM7],
	   i.[CDC_NUM8],
	   i.[CDC_NUM9],
	   i.[CDC_NUM10],
	   i.[ASM_DEN1],
	   i.[ASM_DEN2],
	   i.[ASM_DEN3],
	   i.[ASM_DEN4],
	   i.[ASM_NUM1],
	   i.[ASM_NUM2],
	   i.[ASM_NUM3],
	   i.[ASM_NUM4],
	   i.[FUH_DEN],
	   i.[FUH_NUM1],
	   i.[FUH_NUM2],
	   i.[AMM_DEN],
	   i.[AMM_NUM1],
	   i.[AMM_NUM2],
	   i.[AMM_NUM3],
	   i.[GSO_DEN],
	   i.[GSO_NUM],
	   i.[LBP_DEN],
	   i.[LBP_NUM],
	   i.[AAB_DEN],
	   i.[AAB_NUM],
	   i.[SPR_DEN],
	   i.[SPR_NUM],
	   i.[ADD_DEN1],
	   i.[ADD_NUM1],
	   i.[ADD_DEN2],
	   i.[ADD_NUM2],
	   i.[ART_DEN],
	   i.[ART_NUM],
	   i.[MPM_DEN1],
	   i.[MPM_DEN2],
	   i.[MPM_DEN3],
	   i.[MPM_DEN4],
	   i.[MPM_NE1],
	   i.[MPM_NE2],
	   i.[MPM_NE3],
	   i.[MPM_NE4],
	   i.[DAE_DEN],
	   i.[DAE_NUM1],
	   i.[DAE_NUM2],
	   i.[DDE_DEN1],
	   i.[DDE_DEN2],
	   i.[DDE_DEN3],
	   i.[DDE_NUM1],
	   i.[DDE_NUM2],
	   i.[DDE_NUM3],
	   i.[PCE_DEN],
	   i.[PCE_NUM1],
	   i.[PCE_NUM2],
	   i.[LSC_DEN],
	   i.[LSC_NUM],
	   i.[ABA_DEN],
	   i.[ABA_NUM],
	   i.[WCC_DEN1_1],
	   i.[WCC_NUM1_1],
	   i.[WCC_DEN1_2],
	   i.[WCC_NUM1_2],
	   i.[WCC_DEN2_1],
	   i.[WCC_NUM2_1],
	   i.[WCC_DEN2_2],
	   i.[WCC_NUM2_2],
	   i.[WCC_DEN3_1],
	   i.[WCC_NUM3_1],
	   i.[WCC_DEN3_2],
	   i.[WCC_NUM3_2],
	   i.[COA_DEN],
	   i.[COA_NUM1],
	   i.[COA_NUM2],
	   i.[COA_NUM3],
	   i.[COA_NUM4],
	   i.[MRP_DEN],
	   i.[MRP_NUM],
	   i.[IMA_DEN],
	   i.[IMA_NUM1],
	   i.[IMA_NUM2],
	   i.[IMA_NUM3],
	   i.[HPV_DEN],
	   i.[HPV_NUM],
	   i.[MMA_DEN1],
	   i.[MMA_NUM1_1],
	   i.[MMA_NUM1_2],
	   i.[MMA_DEN2],
	   i.[MMA_NUM2_1],
	   i.[MMA_NUM2_2],
	   i.[MMA_DEN3],
	   i.[MMA_NUM3_1],
	   i.[MMA_NUM3_2],
	   i.[MMA_DEN4],
	   i.[MMA_NUM4_1],
	   i.[MMA_NUM4_2],
	   i.[AMR_DEN1],
	   i.[AMR_DEN2],
	   i.[AMR_DEN3],
	   i.[AMR_DEN4],
	   i.[AMR_NUM1],
	   i.[AMR_NUM2],
	   i.[AMR_NUM3],
	   i.[AMR_NUM4],
	   i.[SMD_DEN],
	   i.[SMD_NUM],
	   i.[SAA_DEN],
	   i.[SAA_NUM],
	   i.[SSD_DEN],
	   i.[SSD_NUM],
	   i.[SMC_DEN],
	   i.[SMC_NUM],
	   i.[NCS_DEN],
	   i.[NCS_NUM],
	   i.[PSA_DEN],
	   i.[PSA_NUM],
	   i.[APC_DEN1],
	   i.[APC_DEN2],
	   i.[APC_DEN3],
	   i.[APC_NUM1],
	   i.[APC_NUM2],
	   i.[APC_NUM3],
	   i.[APM_DEN1],
	   i.[APM_DEN2],
	   i.[APM_DEN3],
	   i.[APM_NUM1],
	   i.[APM_NUM2],
	   i.[APM_NUM3],
	   i.[FPC_DEN],
	   i.[FPC_NUM1],
	   i.[FPC_NUM2],
	   i.[FPC_NUM3],
	   i.[FPC_NUM4],
	   i.[FPC_NUM5],
	   i.[W15_DEN],
	   i.[W15_NUM1],
	   i.[W15_NUM2],
	   i.[W15_NUM3],
	   i.[W15_NUM4],
	   i.[W15_NUM5],
	   i.[W15_NUM6],
	   i.[W15_NUM7],
	   i.[W34_DEN],
	   i.[W34_NUM],
	   i.[AWC_DEN],
	   i.[AWC_NUM],
	   i.[FSP_CABG],
	   i.[FSP_PTCA],
	   i.[FSP_CC],
	   i.[FSP_CE],
	   i.[FSP_RDF],
	   i.[FSP_THR],
	   i.[FSP_TKR],
	   i.[FSP_EXL],
	   i.[FSP_CHO],
	   i.[FSP_CHC],
	   i.[FSP_HYA],
	   i.[FSP_HYV],
	   i.[FSP_PROS],
	   i.[FSP_DC],
	   i.[FSP_BACK],
	   i.[FSP_MYR],
	   i.[FSP_TON],
	   i.[FSP_MAST],
	   i.[FSP_LUMP],
	   i.[FSP_BARI],
	   i.[IPU_DISCH_TOT],
	   i.[IPU_DAYS_TOT],
	   i.[IPU_DISCH_MAT],
	   i.[IPU_DAYS_MAT],
	   i.[IPU_DISCH_SUR],
	   i.[IPU_DAYS_SUR],
	   i.[IPU_DISCH_MED],
	   i.[IPU_DAYS_MED],
	   i.[AMB_OV],
	   i.[AMB_ED],
	   i.[AMB_AS],
	   i.[AMB_OR],
	   i.[MPT_ANY],
	   i.[MPT_INP],
	   i.[MPT_DN],
	   i.[MPT_AMB],
	   i.[IAD_ANY],
	   i.[IAD_INP],
	   i.[IAD_DN],
	   i.[IAD_AMB],
	   i.[TOTAL_ABX_SCRIPTS],
	   i.[TOTAL_ABX_DAYS],
	   i.[ABX_CONCERN_SCRIPTS],
	   i.[ABXQUIN_PMPY],
	   i.[ABXZITH_PMPY],
	   i.[ABXCEPH2_PMPY],
	   i.[ABXCEPH3_PMPY],
	   i.[ABXAMOX_PMPY],
	   i.[ABXKETO_PMPY],
	   i.[ABXCLIND_PMPY],
	   i.[ABXMISC_PMPY],
	   i.[ABXABSORB_PMPY],
	   i.[ABXAMINO_PMPY],
	   i.[ABXCEPH1_PMPY],
	   i.[ABXLINCO_PMPY],
	   i.[ABXMACRO_PMPY],
	   i.[ABXPEN_PMPY],
	   i.[ABXTET_PMPY],
	   i.[ABXMISO_PMPY],
	   i.[ABX_ALLOTHER_SCRIPTS],
	   i.[PCR_DEN],
	   i.[PCR_NUM],
	   i.[SUM_WEIGHTS],
	   i.[PRED_READM],
	   i.[RDI_DEN],
	   i.[RDI_EXCL_REQ],
	   i.[RAS_DEN],
	   i.[RAS_EXCL_REQ],
	   i.[RCA_DEN],
	   i.[RCA_EXCL_REQ],
	   i.[RCO_DEN],
	   i.[RCO_EXCL_REQ],
	   i.[RHY_DEN],
	   i.[RHY_EXCL_REQ],
	   i.[EM_COUNT],
	   i.[RRU_LOS],
	   i.[RX_COUNT],
	   i.[PROC_COUNT],
	   i.[CAP_INPATIENT],
	   i.[CAP_EM_INPATIENT],
	   i.[CAP_EM_OUTPATIENT],
	   i.[CAP_PROC_INPATIENT],
	   i.[CAP_PROC_OUTPATIENT],
	   i.[CAP_RX],
	   i.[CAP_LAB],
	   i.[CAP_IMG],
	   i.[NCQA_PRICE_EM_INP],
	   i.[NCQA_PRICE_EM_OUT],
	   i.[TOTAL_COST_EM],
	   i.[NCQA_PRICE_INP],
	   i.[TOTAL_COST_INP],
	   i.[NCQA_PRICE_PROC_INP],
	   i.[NCQA_PRICE_PROC_OUT],
	   i.[TOTAL_COST_PROC],
	   i.[NCQA_PRICE_RX],
	   i.[TOTAL_COST_RX],
	   i.[NCQA_PRICE_LAB],
	   i.[NCQA_PRICE_IMG],
	   i.[LAB_COUNT],
	   i.[IMG_COUNT],
	   i.[RRU_MMS_MED],
	   i.[RRU_MMS_RX],
	   i.[ED_COUNT],
	   i.[FREQ_CABG],
	   i.[FREQ_CE],
	   i.[FREQ_PCI],
	   i.[FREQ_CC],
	   i.[FREQ_CASDT],
	   i.[FREQ_CAD_EBCT],
	   i.[FREQ_CCT],
	   i.[RRU_INP_DISCH],
	   i.[RRU_INP_DAYS],
	   i.[RRU_IPU_DISCH],
	   i.[RRU_IPU_DAYS],
	   i.[RRU_IPU_MED_DISCH],
	   i.[RRU_IPU_MED_DAYS],
	   i.[RRU_IPU_SURG_DISCH],
	   i.[RRU_IPU_SURG_DAYS],
	   i.[RRU_NON_DISCH],
	   i.[RRU_NON_DAYS],
	   i.[RX_N1],
	   i.[RX_N2],
	   i.[RX_G1],
	   i.[RX_G2],
	   i.[RRUAG_WEIGHT],
	   i.[RASAG_WEIGHT],
	   i.[COMORB_WEIGHT],
	   i.[RRU_RISK_GROUP],
	   i.[RAS_RISK_GROUP],
	   i.[Case Manager],
	   i.[PHO ID],
	   i.[PHO Name],
	   i.[PCP Name],
	   i.[PCP ID],
	   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(
	   RTRIM(LTRIM(COALESCE(i.[PRODUCT_ROLLUP_ID],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MEM_NBR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',1),''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',2),''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_INT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_MH_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_INT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_CD_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMS_DENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PPC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_DEN6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADV_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IET_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APP_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM8],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM9],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM10],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM11],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM12],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM13],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM14],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM15],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM16],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM17],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM18],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CIS_NUM19],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[URI_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[URI_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CWP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CWP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COL_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COL_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[BCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[BCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CHL_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[OMW_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[OMW_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CBP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CBP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PBH_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PBH_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CMC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM8],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM9],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CDC_NUM10],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ASM_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FUH_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[GSO_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[GSO_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LBP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LBP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAB_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AAB_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SPR_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SPR_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ADD_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ART_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ART_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPM_NE4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DAE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[DDE_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCE_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LSC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LSC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_DEN3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[WCC_NUM3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COA_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MRP_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MRP_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMA_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[HPV_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[HPV_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM1_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM1_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM2_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM2_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM3_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM3_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM4_1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MMA_NUM4_2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_DEN4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMR_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMD_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMD_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SAA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SAA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SSD_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SSD_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SMC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCS_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PSA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PSA_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_DEN3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[APM_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FPC_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM3],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM4],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM5],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM6],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W15_NUM7],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W34_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[W34_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AWC_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AWC_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CABG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_PTCA],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CE],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_RDF],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_THR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_TKR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_EXL],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CHO],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_CHC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_HYA],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_HYV],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_PROS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_DC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_BACK],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_MYR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_TON],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_MAST],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_LUMP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FSP_BARI],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_TOT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_TOT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_MAT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_MAT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_SUR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_SUR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DISCH_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IPU_DAYS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_OV],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_ED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_AS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[AMB_OR],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_ANY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_DN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[MPT_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_ANY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_DN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IAD_AMB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_ABX_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_ABX_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABX_CONCERN_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXQUIN_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXZITH_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH2_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH3_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXAMOX_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXKETO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCLIND_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMISC_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXABSORB_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXAMINO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXCEPH1_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXLINCO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMACRO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXPEN_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXTET_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABXMISO_PMPY],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ABX_ALLOTHER_SCRIPTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCR_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCR_NUM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[SUM_WEIGHTS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PRED_READM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RDI_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RDI_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCA_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCA_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCO_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RCO_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RHY_DEN],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RHY_EXCL_REQ],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[EM_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_LOS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PROC_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_EM_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_EM_OUTPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_PROC_INPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_PROC_OUTPATIENT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_LAB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[CAP_IMG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_EM_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_EM_OUT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_EM],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_PROC_INP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_PROC_OUT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_PROC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[TOTAL_COST_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_LAB],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[NCQA_PRICE_IMG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[LAB_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[IMG_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_MMS_MED],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_MMS_RX],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[ED_COUNT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CABG],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CE],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_PCI],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CC],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CASDT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CAD_EBCT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[FREQ_CCT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_INP_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_INP_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_MED_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_MED_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_SURG_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_IPU_SURG_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_NON_DISCH],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_NON_DAYS],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_N1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_N2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_G1],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RX_G2],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRUAG_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RASAG_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[COMORB_WEIGHT],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RRU_RISK_GROUP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[RAS_RISK_GROUP],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[Case Manager],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PHO ID],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PHO Name],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCP Name],''))) + ':' + 
	   RTRIM(LTRIM(COALESCE(i.[PCP ID],'')))
	   )),2)) AS HashDiff

	   FROM stage.HEDIS_Import i
	   LEFT JOIN CHSDV.dbo.H_Client c ON dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',1) = c.ClientName
	   LEFT JOIN CHSDV.dbo.R_Member AS m ON c.Client_BK = m.ClientID
												AND i.MEM_NBR = m.ClientMemberID
		LEFT JOIN CHSDV.dbo.R_Provider AS p ON c.Client_BK = p.ClientID
                                                      AND i.[PCP ID] = p.ClientProviderID;
GO
