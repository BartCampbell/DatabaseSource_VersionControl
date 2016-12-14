SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 03/24/2016
-- Description:	Get Medical Condition By NDC Code
-- Example: exec prGetMedCondbyNDC '00777310502' --Prozac NDC
-- =============================================
CREATE PROCEDURE [dbo].[prGetMedCondbyNDC]
	-- Add the parameters for the stored procedure here
	@NDC varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT DISTINCT mf2ndc.ndc_upc_hri AS NDC, mcn.MedicalConditionCode, mcn.NameTypeCode,
	CASE mcn.NameTypeCode
	WHEN '01' THEN 'Primary Professional'
	WHEN '02' THEN 'Professional Synonym'
	WHEN '03' THEN 'Primary Patient'
	WHEN '04' THEN 'Patient Synonmym'
	END AS 'NameTypeDesc'
	,  mcn.MedicalConditionName, 
	icd10.ICD10_FormattedCode AS ICD10Code, icd10.[ICD10_Description]
	FROM dbo.MediSpan_MF2NDC_Stage mf2ndc
	INNER JOIN MediSpan_MF2GPPC_Stage gppc ON gppc.generic_product_pack_code = mf2ndc.generic_product_pack_code
	INNER JOIN MediSpan_INDGIND_Stage IND ON ind.GPI = gppc.generic_product_identifier
	INNER JOIN MediSpan_MCMNAME_Stage mcn ON mcn.MedicalConditionCode = ind.IndicatedMedConCode
	LEFT JOIN dbo.MediSpan_MIXMMAP_Stage mxm ON mxm.MedicalConditionCode = mcn.MedicalConditionCode
	LEFT JOIN dbo.MediSpan_MIXI10_Stage icd10 ON icd10.ICD10_UnformattedCode = mxm.ICD10_UnformattedCode
	WHERE ndc_upc_hri= @NDC 
	--AND mxm.MedConToICD10='Y'
	

END
GO
