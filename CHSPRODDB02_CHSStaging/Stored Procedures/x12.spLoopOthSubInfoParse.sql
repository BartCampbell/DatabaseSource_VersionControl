SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2300 Claim loops and their repeated segments.
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000003') -- 000000001 000000003 000002175
		AND LoopID = '2300'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopOthSubInfo
		TRUNCATE TABLE x12.SegCAS
		TRUNCATE TABLE x12.SegAMT

	EXEC x12.spLoopOthSubInfoParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('3775') AND LoopID = '2320'
	SELECT * FROM x12.LoopOthSubInfo WHERE OthSubInfo_TransactionControlNumber IN ('3775') ORDER BY OthSubInfo_LoopID
		SELECT * FROM x12.SegCAS WHERE CAS_TransactionControlNumber IN ('3775') ORDER BY CAS_LoopID
		SELECT * FROM x12.SegAMT WHERE AMT_TransactionControlNumber IN ('3775') ORDER BY AMT_LoopID


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopOthSubInfoParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO x12.LoopOthSubInfo (
		OthSubInfo_RowID
		,OthSubInfo_RowIDParent
		,OthSubInfo_CentauriClientID
		,OthSubInfo_FileLogID
		,OthSubInfo_TransactionImplementationConventionReference
		,OthSubInfo_TransactionControlNumber
		,OthSubInfo_LoopID

		,OthSubInfo_PayerResponsibilitySequenceNumberCode_SBR01
		,OthSubInfo_IndividualRelationshipCode_SBR02
		,OthSubInfo_ReferenceIdentification_SBR03
		,OthSubInfo_Name_SBR04
		,OthSubInfo_InsuranceTypeCode_SBR05
		,OthSubInfo_CoordinationOfBenefitsCode_SBR06
		,OthSubInfo_YesNoConditionOrResponseCode_SBR07
		,OthSubInfo_EmploymentStatusCode_SBR08
		,OthSubInfo_ClaimFilingIndicatorCode_SBR09

		,OthSubInfo_ClaimFilingIndicatorCode_OI01
		,OthSubInfo_ClaimSubmissionReasonCode_OI02
		,OthSubInfo_YesNoConditionOrResponseCode_OI03
		,OthSubInfo_PatientSignatureSourceCode_OI04
		,OthSubInfo_ProviderAgreementCode_OI05
		,OthSubInfo_ReleaseofInformationCode_OI06

		,OthSubInfo_Quantity_MIA01
		,OthSubInfo_MonetaryAmount_MIA02
		,OthSubInfo_Quantity_MIA03
		,OthSubInfo_MonetaryAmount_MIA04
		,OthSubInfo_ReferenceIdentification_MIA05
		,OthSubInfo_MonetaryAmount_MIA06
		,OthSubInfo_MonetaryAmount_MIA07
		,OthSubInfo_MonetaryAmount_MIA08
		,OthSubInfo_MonetaryAmount_MIA09
		,OthSubInfo_MonetaryAmount_MIA10
		,OthSubInfo_MonetaryAmount_MIA11
		,OthSubInfo_MonetaryAmount_MIA12
		,OthSubInfo_MonetaryAmount_MIA13
		,OthSubInfo_MonetaryAmount_MIA14
		,OthSubInfo_Quantity_MIA15
		,OthSubInfo_MonetaryAmount_MIA16
		,OthSubInfo_MonetaryAmount_MIA17
		,OthSubInfo_MonetaryAmount_MIA18
		,OthSubInfo_MonetaryAmount_MIA19
		,OthSubInfo_ReferenceIdentification_MIA20
		,OthSubInfo_ReferenceIdentification_MIA21
		,OthSubInfo_ReferenceIdentification_MIA22
		,OthSubInfo_ReferenceIdentification_MIA23
		,OthSubInfo_MonetaryAmount_MIA24

		,OthSubInfo_PercentageAsDecimal_MOA01
		,OthSubInfo_MonetaryAmount_MOA02
		,OthSubInfo_ReferenceIdentification_MOA03
		,OthSubInfo_ReferenceIdentification_MOA04
		,OthSubInfo_ReferenceIdentification_MOA05
		,OthSubInfo_ReferenceIdentification_MOA06
		,OthSubInfo_ReferenceIdentification_MOA07
		,OthSubInfo_MonetaryAmount_MOA08
		,OthSubInfo_MonetaryAmount_MOA09
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- 2320 - OTHER SUBSCIBER INFORMATION
		-- 2320 - SBR
		,h.b.value('(SBR/SBR01/text())[1]', 'varchar(1)') AS 'OthSubInfo_PayerResponsibilitySequenceNumberCode_SBR01'
		,h.b.value('(SBR/SBR02/text())[1]', 'varchar(2)') AS 'OthSubInfo_IndividualRelationshipCode_SBR02'
		,h.b.value('(SBR/SBR03/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_SBR03'
		,h.b.value('(SBR/SBR04/text())[1]', 'varchar(60)') AS 'OthSubInfo_Name_SBR04'
		,h.b.value('(SBR/SBR05/text())[1]', 'varchar(3)') AS 'OthSubInfo_InsuranceTypeCode_SBR05'
		,h.b.value('(SBR/SBR06/text())[1]', 'varchar(1)') AS 'OthSubInfo_CoordinationOfBenefitsCode_SBR06'
		,h.b.value('(SBR/SBR07/text())[1]', 'varchar(1)') AS 'OthSubInfo_YesNoConditionOrResponseCode_SBR07'
		,h.b.value('(SBR/SBR08/text())[1]', 'varchar(2)') AS 'OthSubInfo_EmploymentStatusCode_SBR08'
		,h.b.value('(SBR/SBR09/text())[1]', 'varchar(2)') AS 'OthSubInfo_ClaimFilingIndicatorCode_SBR09'
		-- OthSubInfo - CAS - !!! Collected Separately !!!
		-- OthSubInfo - AMT - !!! Collected Separately !!!
		-- OthSubInfo - DMG - !!!Not Found!!!
		-- OthSubInfo - OI Other Insurance Coverage Information
		,h.b.value('(OI/OI01/text())[1]', 'varchar(2)') AS 'OthSubInfo_ClaimFilingIndicatorCode_OI01'
		,h.b.value('(OI/OI02/text())[1]', 'varchar(2)') AS 'OthSubInfo_ClaimSubmissionReasonCode_OI02'
		,h.b.value('(OI/OI03/text())[1]', 'varchar(1)') AS 'OthSubInfo_YesNoConditionOrResponseCode_OI03'
		,h.b.value('(OI/OI04/text())[1]', 'varchar(1)') AS 'OthSubInfo_PatientSignatureSourceCode_OI04'
		,h.b.value('(OI/OI05/text())[1]', 'varchar(1)') AS 'OthSubInfo_ProviderAgreementCode_OI05'
		,h.b.value('(OI/OI06/text())[1]', 'varchar(1)') AS 'OthSubInfo_ReleaseofInformationCode_OI06'
		-- 2320 - MIA
		,h.b.value('(MIA/MIA01/text())[1]', 'varchar(15)') AS 'OthSubInfo_Quantity_MIA01'
		,h.b.value('(MIA/MIA02/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA02'
		,h.b.value('(MIA/MIA03/text())[1]', 'varchar(15)') AS 'OthSubInfo_Quantity_MIA03'
		,h.b.value('(MIA/MIA04/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA04'
		,h.b.value('(MIA/MIA05/text())[1]', 'varchar(18)') AS 'OthSubInfo_ReferenceIdentification_MIA05'
		,h.b.value('(MIA/MIA06/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA06'
		,h.b.value('(MIA/MIA07/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA07'
		,h.b.value('(MIA/MIA08/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA08'
		,h.b.value('(MIA/MIA09/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA09'
		,h.b.value('(MIA/MIA10/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA10'
		,h.b.value('(MIA/MIA11/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA11'
		,h.b.value('(MIA/MIA12/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA12'
		,h.b.value('(MIA/MIA13/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA13'
		,h.b.value('(MIA/MIA14/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA14'
		,h.b.value('(MIA/MIA15/text())[1]', 'varchar(15)') AS 'OthSubInfo_Quantity_MIA15'
		,h.b.value('(MIA/MIA16/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA16'
		,h.b.value('(MIA/MIA17/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA17'
		,h.b.value('(MIA/MIA18/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA18'
		,h.b.value('(MIA/MIA19/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA19'
		,h.b.value('(MIA/MIA20/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MIA20'
		,h.b.value('(MIA/MIA21/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MIA21'
		,h.b.value('(MIA/MIA22/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MIA22'
		,h.b.value('(MIA/MIA23/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MIA23'
		,h.b.value('(MIA/MIA24/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MIA24'
		-- OthSubInfo - MOA
		,h.b.value('(MOA/MOA01/text())[1]', 'varchar(10)') AS 'OthSubInfo_PercentageAsDecimal_MOA01'
		,h.b.value('(MOA/MOA02/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MOA02'
		,h.b.value('(MOA/MOA03/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MOA03'
		,h.b.value('(MOA/MOA04/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MOA04'
		,h.b.value('(MOA/MOA05/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MOA05'
		,h.b.value('(MOA/MOA06/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MOA06'
		,h.b.value('(MOA/MOA07/text())[1]', 'varchar(50)') AS 'OthSubInfo_ReferenceIdentification_MOA07'
		,h.b.value('(MOA/MOA08/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MOA08'
		,h.b.value('(MOA/MOA09/text())[1]', 'varchar(18)') AS 'OthSubInfo_MonetaryAmount_MOA09'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2320'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- CAS

	INSERT INTO x12.SegCAS (
		CAS_RowID
		,CAS_RowIDParent
		,CAS_CentauriClientID
		,CAS_FileLogID
		,CAS_TransactionImplementationConventionReference
		,CAS_TransactionControlNumber
		,CAS_LoopID

		,CAS_ClaimAdjustmentGroupCode_CAS01
		,CAS_ClaimAdjustmentReasonCode_CAS02
		,CAS_MonetaryAmount_CAS03
		,CAS_Quantity_CAS04
		,CAS_ClaimAdjustmentReasonCode_CAS05
		,CAS_MonetaryAmount_CAS06
		,CAS_Quantity_CAS07
		,CAS_ClaimAdjustmentReasonCode_CAS08
		,CAS_MonetaryAmount_CAS09
		,CAS_Quantity_CAS10
		,CAS_ClaimAdjustmentReasonCode_CAS11
		,CAS_MonetaryAmount_CAS12
		,CAS_Quantity_CAS13
		,CAS_ClaimAdjustmentReasonCode_CAS14
		,CAS_MonetaryAmount_CAS15
		,CAS_Quantity_CAS16
		,CAS_ClaimAdjustmentReasonCode_CAS17
		,CAS_MonetaryAmount_CAS18
		,CAS_Quantity_CAS19
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(CAS01/text())[1]', 'varchar(2)') AS 'CAS_ClaimAdjustmentGroupCode_CAS01'
		,h.b.value('(CAS02/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS02'
		,h.b.value('(CAS03/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS03'
		,h.b.value('(CAS04/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS04'
		,h.b.value('(CAS05/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS05'
		,h.b.value('(CAS06/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS06'
		,h.b.value('(CAS07/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS07'
		,h.b.value('(CAS08/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS08'
		,h.b.value('(CAS09/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS09'
		,h.b.value('(CAS10/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS10'
		,h.b.value('(CAS11/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS11'
		,h.b.value('(CAS12/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS12'
		,h.b.value('(CAS13/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS13'
		,h.b.value('(CAS14/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS14'
		,h.b.value('(CAS15/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS15'
		,h.b.value('(CAS16/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS16'
		,h.b.value('(CAS17/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS17'
		,h.b.value('(CAS18/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS18'
		,h.b.value('(CAS19/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS19'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/CAS') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2320'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- AMT - CLAIM SUPPLEMENTAL INFORMATION 

	INSERT INTO x12.SegAMT (
		AMT_RowID
		,AMT_RowIDParent
		,AMT_CentauriClientID
		,AMT_FileLogID
		,AMT_TransactionImplementationConventionReference
		,AMT_TransactionControlNumber
		,AMT_LoopID

		,AMT_AmountQualifierCode_AMT01
		,AMT_MonetaryAmount_AMT02
		,AMT_CreditDebitFlagCode_AMT03
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(AMT01/text())[1]', 'varchar(3)') AS 'AMT_AmountQualifierCode_AMT01'
		,h.b.value('(AMT02/text())[1]', 'varchar(18)') AS 'AMT_MonetaryAmount_AMT02'
		,h.b.value('(AMT03/text())[1]', 'varchar(1)') AS 'AMT_CreditDebitFlagCode_AMT03'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/AMT') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2320'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
