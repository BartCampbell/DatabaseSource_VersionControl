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

	TRUNCATE TABLE x12.LoopClaim
		TRUNCATE TABLE x12.SegDTP
		TRUNCATE TABLE x12.SegPWK
		TRUNCATE TABLE x12.SegREF
		TRUNCATE TABLE x12.SegK3
		TRUNCATE TABLE x12.SegCRC
		TRUNCATE TABLE x12.SegHI

	EXEC x12.spLoopClaimParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000002175') AND LoopID = '2300'
	SELECT * FROM x12.LoopClaim WHERE Claim_TransactionControlNumber IN ('000002175') ORDER BY Claim_LoopID
		SELECT * FROM x12.SegDTP WHERE DTP_TransactionControlNumber IN ('000002175') ORDER BY DTP_LoopID
		SELECT * FROM x12.SegPWK WHERE PWK_TransactionControlNumber IN ('000002175') ORDER BY PWK_LoopID
		SELECT * FROM x12.SegREF WHERE REF_TransactionControlNumber IN ('000002175') ORDER BY REF_LoopID
		SELECT * FROM x12.SegK3 WHERE K3_TransactionControlNumber IN ('000002175') ORDER BY K3_LoopID
		SELECT * FROM x12.SegCRC WHERE CRC_TransactionControlNumber IN ('000002175') ORDER BY CRC_LoopID
		SELECT * FROM x12.SegHI WHERE HI_TransactionControlNumber IN ('000002175') ORDER BY HI_LoopID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopClaimParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO x12.LoopClaim (
		Claim_RowID
		,Claim_RowIDParent
		,Claim_CentauriClientID
		,Claim_FileLogID
		,Claim_TransactionImplementationConventionReference
		,Claim_TransactionControlNumber
		,Claim_LoopID

		,Claim_ClaimSubmittersIdentifier_CLM01
		,Claim_MonetaryAmount_CLM02
		,Claim_ClaimFilingIndicatorCode_CLM03
		,Claim_NonInstitutionalClaimTypeCode_CLM04
		,Claim_FacilityCodeValue_CLM0501
		,Claim_FacilityCodeQualifier_CLM0502
		,Claim_ClaimFrequencyTypeCode_CLM0503
		,Claim_YesNoConditionorResponseCode_CLM06
		,Claim_ProviderAcceptAssignmentCode_CLM07
		,Claim_YesNoConditionorResponseCode_CLM08
		,Claim_ReleaseOfInformationCode_CLM09
		,Claim_PatientSignatureSourceCode_CLM10
		,Claim_RelatedCausesCode_CLM1101
		,Claim_RelatedCausesCode_CLM1102
		,Claim_RelatedCausesCode_CLM1103
		,Claim_StateOrProvinceCode_CLM1104
		,Claim_CountryCode_CLM1105
		,Claim_SpecialProgramCode_CLM12
		,Claim_YesNoConditionOrResponseCode_CLM13
		,Claim_LevelOfServiceCode_CLM14
		,Claim_YesNoConditionOrResponseCode_CLM15
		,Claim_ProviderAgreementCode_CLM16
		,Claim_ClaimStatusCode_CLM17
		,Claim_YesNoConditionOrResponseCode_CLM18
		,Claim_ClaimSubmissionReasonCode_CLM19
		,Claim_DelayReasonCode_CLM20
		,Claim_ContractTypeCode_CN101
		,Claim_MonetaryAmount_CN102
		,Claim_PercentDecimalFormat_CN103
		,Claim_ReferenceIdentification_CN104
		,Claim_TermsDiscountPercentage_CN105
		,Claim_VersionIdentifier_CN106
		,Claim_AmountQualifierCode_AMT01
		,Claim_MonetaryAmount_AMT02
		,Claim_CreditDebitFlagCode_AMT03
		,Claim_NoteReferenceCode_NTE01
		,Claim_ClaimNoteText_NTE02
		,Claim_UnitOrBasisForMeasurementCode_CR101
		,Claim_Weight_CR102
		,Claim_AmbulanceTransportCode_CR103
		,Claim_AmbulanceTransportReasonCode_CR104
		,Claim_UnitOrBasisForMeasurementCode_CR105
		,Claim_Quantity_CR106
		,Claim_AddressInformation_CR107
		,Claim_AddressInformation_CR108
		,Claim_Description_CR109
		,Claim_Description_CR110
		,Claim_Count_CR201
		,Claim_Quantity_CR202
		,Claim_SubluxationLevelCode_CR203
		,Claim_SubluxationLevelCode_CR204
		,Claim_UnitOrBasisForMeasurementCode_CR205
		,Claim_Quantity_CR206
		,Claim_Quantity_CR207
		,Claim_NatureOfConditionCode_CR208
		,Claim_YesNoConditionOrResponseCode_CR209
		,Claim_Description_CR210
		,Claim_Description_CR211
		,Claim_YesNoConditionOrResponseCode_CR212
		,Claim_PricingMethodology_HCP01
		,Claim_MonetaryAmount_HCP02
		,Claim_MonetaryAmount_HCP03
		,Claim_ReferenceIdentification_HCP04
		,Claim_Rate_HCP05
		,Claim_ReferenceIdentification_HCP06
		,Claim_MonetaryAmount_HCP07
		,Claim_ProductServiceID_HCP08
		,Claim_ProductServiceIDQualifier_HCP09
		,Claim_ProductServiceID_HCP10
		,Claim_UnitOrBasisForMeasurementCode_HCP11
		,Claim_Quantity_HCP12
		,Claim_RejectReasonCode_HCP13
		,Claim_PolicyComplianceCode_HCP14
		,Claim_ExceptionCode_HCP15
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- CLM - Claim Information
		,h.b.value('(CLM/CLM01/text())[1]', 'varchar(50)') AS Claim_ClaimSubmittersIdentifier_CLM01
		,h.b.value('(CLM/CLM02/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_CLM02
		,h.b.value('(CLM/CLM03/text())[1]', 'varchar(50)') AS Claim_ClaimFilingIndicatorCode_CLM03
		,h.b.value('(CLM/CLM04/text())[1]', 'varchar(50)') AS Claim_NonInstitutionalClaimTypeCode_CLM04
		-- CLM - HEALTH CARE SERVICE LOCATION INFORMATION
		,h.b.value('(CLM/CLM05/CLM0501/text())[1]', 'varchar(50)') AS Claim_FacilityCodeValue_CLM0501
		,h.b.value('(CLM/CLM05/CLM0502/text())[1]', 'varchar(50)') AS Claim_FacilityCodeQualifier_CLM0502
		,h.b.value('(CLM/CLM05/CLM0503/text())[1]', 'varchar(50)') AS Claim_ClaimFrequencyTypeCode_CLM0503
		,h.b.value('(CLM/CLM06/text())[1]', 'varchar(50)') AS Claim_YesNoConditionorResponseCode_CLM06
		,h.b.value('(CLM/CLM07/text())[1]', 'varchar(50)') AS Claim_ProviderAcceptAssignmentCode_CLM07
		,h.b.value('(CLM/CLM08/text())[1]', 'varchar(50)') AS Claim_YesNoConditionorResponseCode_CLM08
		,h.b.value('(CLM/CLM09/text())[1]', 'varchar(50)') AS Claim_ReleaseOfInformationCode_CLM09
		,h.b.value('(CLM/CLM10/text())[1]', 'varchar(50)') AS Claim_PatientSignatureSourceCode_CLM10
		-- CLM - RELATED CAUSES INFORMATION
		,h.b.value('(CLM/CLM11/CLM1101/text())[1]', 'varchar(50)') AS Claim_RelatedCausesCode_CLM1101
		,h.b.value('(CLM/CLM11/CLM1102/text())[1]', 'varchar(50)') AS Claim_RelatedCausesCode_CLM1102
		,h.b.value('(CLM/CLM11/CLM1103/text())[1]', 'varchar(50)') AS Claim_RelatedCausesCode_CLM1103
		,h.b.value('(CLM/CLM11/CLM1104/text())[1]', 'varchar(50)') AS Claim_StateOrProvinceCode_CLM1104
		,h.b.value('(CLM/CLM11/CLM1105/text())[1]', 'varchar(50)') AS Claim_CountryCode_CLM1105
		,h.b.value('(CLM/CLM12/text())[1]', 'varchar(50)') AS Claim_SpecialProgramCode_CLM12
		,h.b.value('(CLM/CLM13/text())[1]', 'varchar(50)') AS Claim_YesNoConditionOrResponseCode_CLM13
		,h.b.value('(CLM/CLM14/text())[1]', 'varchar(50)') AS Claim_LevelOfServiceCode_CLM14
		,h.b.value('(CLM/CLM15/text())[1]', 'varchar(50)') AS Claim_YesNoConditionOrResponseCode_CLM15
		,h.b.value('(CLM/CLM16/text())[1]', 'varchar(50)') AS Claim_ProviderAgreementCode_CLM16
		,h.b.value('(CLM/CLM17/text())[1]', 'varchar(50)') AS Claim_ClaimStatusCode_CLM17
		,h.b.value('(CLM/CLM18/text())[1]', 'varchar(50)') AS Claim_YesNoConditionOrResponseCode_CLM18
		,h.b.value('(CLM/CLM19/text())[1]', 'varchar(50)') AS Claim_ClaimSubmissionReasonCode_CLM19
		,h.b.value('(CLM/CLM20/text())[1]', 'varchar(50)') AS Claim_DelayReasonCode_CLM20
		-- DTP - !!! Collected Separately !!!
		-- PWK - CLAIM SUPPLEMENTAL INFORMATION  - !!! Collected Separately !!!
		-- CN1 - CONTRACT INFORMATION
		,h.b.value('(CN1/CN101/text())[1]', 'varchar(50)') AS Claim_ContractTypeCode_CN101
		,h.b.value('(CN1/CN102/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_CN102
		,h.b.value('(CN1/CN103/text())[1]', 'varchar(50)') AS Claim_PercentDecimalFormat_CN103
		,h.b.value('(CN1/CN104/text())[1]', 'varchar(50)') AS Claim_ReferenceIdentification_CN104
		,h.b.value('(CN1/CN105/text())[1]', 'varchar(50)') AS Claim_TermsDiscountPercentage_CN105
		,h.b.value('(CN1/CN106/text())[1]', 'varchar(50)') AS Claim_VersionIdentifier_CN106
		-- AMT - PATIENT AMOUNT PAID
		,h.b.value('(AMT/AMT01/text())[1]', 'varchar(50)') AS Claim_AmountQualifierCode_AMT01
		,h.b.value('(AMT/AMT02/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_AMT02
		,h.b.value('(AMT/AMT03/text())[1]', 'varchar(50)') AS Claim_CreditDebitFlagCode_AMT03
		-- REF - !!! Collected Separately !!!
		-- K3 - FILE INFORMATION - !!! Collected Separately !!!
		-- NTE - LINE NOTE
		,h.b.value('(NTE/NTE01/text())[1]', 'varchar(50)') AS Claim_NoteReferenceCode_NTE01
		,h.b.value('(NTE/NTE02/text())[1]', 'varchar(50)') AS Claim_ClaimNoteText_NTE02
		-- CR1 - AMBULANCE TRANSPORT INFORMATION
		,h.b.value('(CR1/CR101/text())[1]', 'varchar(50)') AS Claim_UnitOrBasisForMeasurementCode_CR101
		,h.b.value('(CR1/CR102/text())[1]', 'varchar(50)') AS Claim_Weight_CR102
		,h.b.value('(CR1/CR103/text())[1]', 'varchar(50)') AS Claim_AmbulanceTransportCode_CR103
		,h.b.value('(CR1/CR104/text())[1]', 'varchar(50)') AS Claim_AmbulanceTransportReasonCode_CR104
		,h.b.value('(CR1/CR105/text())[1]', 'varchar(50)') AS Claim_UnitOrBasisForMeasurementCode_CR105
		,h.b.value('(CR1/CR106/text())[1]', 'varchar(50)') AS Claim_Quantity_CR106
		,h.b.value('(CR1/CR107/text())[1]', 'varchar(50)') AS Claim_AddressInformation_CR107
		,h.b.value('(CR1/CR108/text())[1]', 'varchar(50)') AS Claim_AddressInformation_CR108
		,h.b.value('(CR1/CR109/text())[1]', 'varchar(50)') AS Claim_Description_CR109
		,h.b.value('(CR1/CR110/text())[1]', 'varchar(50)') AS Claim_Description_CR110
		-- CR2 - SPINAL MANIPULATION SERVICE INFORMATION
		,h.b.value('(CR2/CR201/text())[1]', 'varchar(50)') AS Claim_Count_CR201
		,h.b.value('(CR2/CR202/text())[1]', 'varchar(50)') AS Claim_Quantity_CR202
		,h.b.value('(CR2/CR203/text())[1]', 'varchar(50)') AS Claim_SubluxationLevelCode_CR203
		,h.b.value('(CR2/CR204/text())[1]', 'varchar(50)') AS Claim_SubluxationLevelCode_CR204
		,h.b.value('(CR2/CR205/text())[1]', 'varchar(50)') AS Claim_UnitOrBasisForMeasurementCode_CR205
		,h.b.value('(CR2/CR206/text())[1]', 'varchar(50)') AS Claim_Quantity_CR206
		,h.b.value('(CR2/CR207/text())[1]', 'varchar(50)') AS Claim_Quantity_CR207
		,h.b.value('(CR2/CR208/text())[1]', 'varchar(50)') AS Claim_NatureOfConditionCode_CR208
		,h.b.value('(CR2/CR209/text())[1]', 'varchar(50)') AS Claim_YesNoConditionOrResponseCode_CR209
		,h.b.value('(CR2/CR210/text())[1]', 'varchar(50)') AS Claim_Description_CR210
		,h.b.value('(CR2/CR211/text())[1]', 'varchar(50)') AS Claim_Description_CR211
		,h.b.value('(CR2/CR212/text())[1]', 'varchar(50)') AS Claim_YesNoConditionOrResponseCode_CR212
		-- CRC - !!! Collected Separately !!!
		-- HI - HEALTH CARE DIAGNOSIS CODE  - !!! Collected Separately !!!
		-- HCP - Claim Pricing/Repricing Information
		,h.b.value('(HCP/HCP01/text())[1]', 'varchar(50)') AS Claim_PricingMethodology_HCP01
		,h.b.value('(HCP/HCP02/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_HCP02
		,h.b.value('(HCP/HCP03/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_HCP03
		,h.b.value('(HCP/HCP04/text())[1]', 'varchar(50)') AS Claim_ReferenceIdentification_HCP04
		,h.b.value('(HCP/HCP05/text())[1]', 'varchar(50)') AS Claim_Rate_HCP05
		,h.b.value('(HCP/HCP06/text())[1]', 'varchar(50)') AS Claim_ReferenceIdentification_HCP06
		,h.b.value('(HCP/HCP07/text())[1]', 'varchar(50)') AS Claim_MonetaryAmount_HCP07
		,h.b.value('(HCP/HCP08/text())[1]', 'varchar(50)') AS Claim_ProductServiceID_HCP08
		,h.b.value('(HCP/HCP09/text())[1]', 'varchar(50)') AS Claim_ProductServiceIDQualifier_HCP09
		,h.b.value('(HCP/HCP10/text())[1]', 'varchar(50)') AS Claim_ProductServiceID_HCP10
		,h.b.value('(HCP/HCP11/text())[1]', 'varchar(50)') AS Claim_UnitOrBasisForMeasurementCode_HCP11
		,h.b.value('(HCP/HCP12/text())[1]', 'varchar(50)') AS Claim_Quantity_HCP12
		,h.b.value('(HCP/HCP13/text())[1]', 'varchar(50)') AS Claim_RejectReasonCode_HCP13
		,h.b.value('(HCP/HCP14/text())[1]', 'varchar(50)') AS Claim_PolicyComplianceCode_HCP14
		,h.b.value('(HCP/HCP15/text())[1]', 'varchar(50)') AS Claim_ExceptionCode_HCP15
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- DTP

	INSERT INTO x12.SegDTP (
		DTP_RowID
		,DTP_RowIDParent
		,DTP_CentauriClientID
		,DTP_FileLogID
		,DTP_TransactionImplementationConventionReference
		,DTP_TransactionControlNumber
		,DTP_LoopID

		,DTP_DateTimeQualifier_DTP01
		,DTP_DateTimePeriodFormatQualifier_DTP02
		,DTP_DateTimePeriod_DTP03
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(DTP01/text())[1]', 'varchar(50)') AS DTP_DateTimeQualifier_DTP01
		,h.b.value('(DTP02/text())[1]', 'varchar(50)') AS DTP_DateTimePeriodFormatQualifier_DTP02
		,h.b.value('(DTP03/text())[1]', 'varchar(50)') AS DTP_DateTimePeriod_DTP03
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/DTP') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- PWK - CLAIM SUPPLEMENTAL INFORMATION 

	INSERT INTO x12.SegPWK (
		PWK_RowID
		,PWK_RowIDParent
		,PWK_CentauriClientID
		,PWK_FileLogID
		,PWK_TransactionImplementationConventionReference
		,PWK_TransactionControlNumber
		,PWK_LoopID

		,PWK_ReportTypeCode_PWK01
		,PWK_ReportTransmissionCode_PWK02
		,PWK_ReportCopiesNeeded_PWK03
		,PWK_EntityIdentifierCode_PWK04
		,PWK_IdentificationCodeQualifier_PWK05
		,PWK_IdentificationCode_PWK06
		,PWK_Description_PWK07
		,PWK_ActionsIndicated_PWK08
		,PWK_RequestCategoryCode_PWK09
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(PWK01/text())[1]', 'varchar(50)') AS PWK_ReportTypeCode_PWK01
		,h.b.value('(PWK02/text())[1]', 'varchar(50)') AS PWK_ReportTransmissionCode_PWK02
		,h.b.value('(PWK03/text())[1]', 'varchar(50)') AS PWK_ReportCopiesNeeded_PWK03
		,h.b.value('(PWK04/text())[1]', 'varchar(50)') AS PWK_EntityIdentifierCode_PWK04
		,h.b.value('(PWK05/text())[1]', 'varchar(50)') AS PWK_IdentificationCodeQualifier_PWK05
		,h.b.value('(PWK06/text())[1]', 'varchar(50)') AS PWK_IdentificationCode_PWK06
		,h.b.value('(PWK07/text())[1]', 'varchar(50)') AS PWK_Description_PWK07
		,h.b.value('(PWK08/text())[1]', 'varchar(50)') AS PWK_ActionsIndicated_PWK08
		,h.b.value('(PWK09/text())[1]', 'varchar(50)') AS PWK_RequestCategoryCode_PWK09
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/PWK') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- Ref

	INSERT INTO x12.SegREF (
		REF_RowID
		,REF_RowIDParent
		,REF_CentauriClientID
		,REF_FileLogID
		,REF_TransactionImplementationConventionReference
		,REF_TransactionControlNumber
		,REF_LoopID

		,REF_ReferenceIdentificationQualifier_REF01
		,REF_ReferenceIdentification_REF02
		,REF_Description_REF03
		,REF_ReferenceIdentifier_REF04
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(REF01/text())[1]', 'varchar(3)') AS 'REF_ReferenceIdentificationQualifier_REF01'
		,h.b.value('(REF02/text())[1]', 'varchar(50)') AS 'REF_ReferenceIdentification_REF02'
		,h.b.value('(REF03/text())[1]', 'varchar(80)') AS 'REF_Description_REF03'
		,h.b.value('(REF04/text())[1]', 'varchar(1)') AS 'REF_ReferenceIdentifier_REF04'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/REF') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber


	-- K3 - FILE INFORMATION

	INSERT INTO x12.SegK3 (
		K3_RowID
		,K3_RowIDParent
		,K3_CentauriClientID
		,K3_FileLogID
		,K3_TransactionImplementationConventionReference
		,K3_TransactionControlNumber
		,K3_LoopID

		,K3_FixedFormatInformation_K301
		,K3_RecordFormatCode_K302
		,K3_CompositeUnitOfMeasure_K303
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(K301/text())[1]', 'varchar(50)') AS K3_FixedFormatInformation_K301
		,h.b.value('(K302/text())[1]', 'varchar(50)') AS K3_RecordFormatCode_K302
		,h.b.value('(K303/text())[1]', 'varchar(50)') AS K3_CompositeUnitOfMeasure_K303
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/K3') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- CRC

	INSERT INTO x12.SegCRC (
		CRC_RowID
		,CRC_RowIDParent
		,CRC_CentauriClientID
		,CRC_FileLogID
		,CRC_TransactionImplementationConventionReference
		,CRC_TransactionControlNumber
		,CRC_LoopID

		,CRC_CodeCategory_CRC01
		,CRC_YesNoConditionOrResponseCode_CRC02
		,CRC_ConditionIndicator_CRC03
		,CRC_ConditionIndicator_CRC04
		,CRC_ConditionIndicator_CRC05
		,CRC_ConditionIndicator_CRC06
		,CRC_ConditionIndicator_CRC07
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(CRC01/text())[1]', 'varchar(50)') AS CRC_CodeCategory_CRC01
		,h.b.value('(CRC02/text())[1]', 'varchar(50)') AS CRC_YesNoConditionOrResponseCode_CRC02
		,h.b.value('(CRC03/text())[1]', 'varchar(50)') AS CRC_ConditionIndicator_CRC03
		,h.b.value('(CRC04/text())[1]', 'varchar(50)') AS CRC_ConditionIndicator_CRC04
		,h.b.value('(CRC05/text())[1]', 'varchar(50)') AS CRC_ConditionIndicator_CRC05
		,h.b.value('(CRC06/text())[1]', 'varchar(50)') AS CRC_ConditionIndicator_CRC06
		,h.b.value('(CRC07/text())[1]', 'varchar(50)') AS CRC_ConditionIndicator_CRC07
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/CRC') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber	

	-- HI

	INSERT INTO x12.SegHI (
		HI_RowID
		,HI_RowIDParent
		,HI_CentauriClientID
		,HI_FileLogID
		,HI_TransactionImplementationConventionReference
		,HI_TransactionControlNumber
		,HI_LoopID

		,HI_CodeListQualifierCode_HI0101
		,HI_IndustryCode_HI0102
		,HI_DateTimePeriodFormatQualifier_HI0103
		,HI_DateTimePeriod_HI0104
		,HI_MonetaryAmount_HI0105
		,HI_Quantity_HI0106
		,HI_VersionIdentifier_HI0107
		,HI_IndustryCode_HI0108
		,HI_YesNoConditionOrResponseCode_HI0109
		,HI_CodeListQualifierCode_HI0201
		,HI_IndustryCode_HI0202
		,HI_DateTimePeriodFormatQualifier_HI0203
		,HI_DateTimePeriod_HI0204
		,HI_MonetaryAmount_HI0205
		,HI_Quantity_HI0206
		,HI_VersionIdentifier_HI0207
		,HI_IndustryCode_HI0208
		,HI_YesNoConditionOrResponseCode_HI0209
		,HI_CodeListQualifierCode_HI0301
		,HI_IndustryCode_HI0302
		,HI_DateTimePeriodFormatQualifier_HI0303
		,HI_DateTimePeriod_HI0304
		,HI_MonetaryAmount_HI0305
		,HI_Quantity_HI0306
		,HI_VersionIdentifier_HI0307
		,HI_IndustryCode_HI0308
		,HI_YesNoConditionOrResponseCode_HI0309
		,HI_CodeListQualifierCode_HI0401
		,HI_IndustryCode_HI0402
		,HI_DateTimePeriodFormatQualifier_HI0403
		,HI_DateTimePeriod_HI0404
		,HI_MonetaryAmount_HI0405
		,HI_Quantity_HI0406
		,HI_VersionIdentifier_HI0407
		,HI_IndustryCode_HI0408
		,HI_YesNoConditionOrResponseCode_HI0409
		,HI_CodeListQualifierCode_HI0501
		,HI_IndustryCode_HI0502
		,HI_DateTimePeriodFormatQualifier_HI0503
		,HI_DateTimePeriod_HI0504
		,HI_MonetaryAmount_HI0505
		,HI_Quantity_HI0506
		,HI_VersionIdentifier_HI0507
		,HI_IndustryCode_HI0508
		,HI_YesNoConditionOrResponseCode_HI0509
		,HI_CodeListQualifierCode_HI0601
		,HI_IndustryCode_HI0602
		,HI_DateTimePeriodFormatQualifier_HI0603
		,HI_DateTimePeriod_HI0604
		,HI_MonetaryAmount_HI0605
		,HI_Quantity_HI0606
		,HI_VersionIdentifier_HI0607
		,HI_IndustryCode_HI0608
		,HI_YesNoConditionOrResponseCode_HI0609
		,HI_CodeListQualifierCode_HI0701
		,HI_IndustryCode_HI0702
		,HI_DateTimePeriodFormatQualifier_HI0703
		,HI_DateTimePeriod_HI0704
		,HI_MonetaryAmount_HI0705
		,HI_Quantity_HI0706
		,HI_VersionIdentifier_HI0707
		,HI_IndustryCode_HI0708
		,HI_YesNoConditionOrResponseCode_HI0709
		,HI_CodeListQualifierCode_HI0801
		,HI_IndustryCode_HI0802
		,HI_DateTimePeriodFormatQualifier_HI0803
		,HI_DateTimePeriod_HI0804
		,HI_MonetaryAmount_HI0805
		,HI_Quantity_HI0806
		,HI_VersionIdentifier_HI0807
		,HI_IndustryCode_HI0808
		,HI_YesNoConditionOrResponseCode_HI0809
		,HI_CodeListQualifierCode_HI0901
		,HI_IndustryCode_HI0902
		,HI_DateTimePeriodFormatQualifier_HI0903
		,HI_DateTimePeriod_HI0904
		,HI_MonetaryAmount_HI0905
		,HI_Quantity_HI0906
		,HI_VersionIdentifier_HI0907
		,HI_IndustryCode_HI0908
		,HI_YesNoConditionOrResponseCode_HI0909
		,HI_CodeListQualifierCode_HI1001
		,HI_IndustryCode_HI1002
		,HI_DateTimePeriodFormatQualifier_HI1003
		,HI_DateTimePeriod_HI1004
		,HI_MonetaryAmount_HI1005
		,HI_Quantity_HI1006
		,HI_VersionIdentifier_HI1007
		,HI_IndustryCode_HI1008
		,HI_YesNoConditionOrResponseCode_HI1009
		,HI_CodeListQualifierCode_HI1101
		,HI_IndustryCode_HI1102
		,HI_DateTimePeriodFormatQualifier_HI1103
		,HI_DateTimePeriod_HI1104
		,HI_MonetaryAmount_HI1105
		,HI_Quantity_HI1106
		,HI_VersionIdentifier_HI1107
		,HI_IndustryCode_HI1108
		,HI_YesNoConditionOrResponseCode_HI1109
		,HI_CodeListQualifierCode_HI1201
		,HI_IndustryCode_HI1202
		,HI_DateTimePeriodFormatQualifier_HI1203
		,HI_DateTimePeriod_HI1204
		,HI_MonetaryAmount_HI1205
		,HI_Quantity_HI1206
		,HI_VersionIdentifier_HI1207
		,HI_IndustryCode_HI1208
		,HI_YesNoConditionOrResponseCode_HI1209
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(HI01/HI0101/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0101'
		,h.b.value('(HI01/HI0102/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0102'
		,h.b.value('(HI01/HI0103/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0103'
		,h.b.value('(HI01/HI0104/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0104'
		,h.b.value('(HI01/HI0105/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0105'
		,h.b.value('(HI01/HI0106/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0106'
		,h.b.value('(HI01/HI0107/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0107'
		,h.b.value('(HI01/HI0108/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0108'
		,h.b.value('(HI01/HI0109/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0109'
		,h.b.value('(HI02/HI0201/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0201'
		,h.b.value('(HI02/HI0202/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0202'
		,h.b.value('(HI02/HI0203/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0203'
		,h.b.value('(HI02/HI0204/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0204'
		,h.b.value('(HI02/HI0205/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0205'
		,h.b.value('(HI02/HI0206/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0206'
		,h.b.value('(HI02/HI0207/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0207'
		,h.b.value('(HI02/HI0208/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0208'
		,h.b.value('(HI02/HI0209/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0209'
		,h.b.value('(HI03/HI0301/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0301'
		,h.b.value('(HI03/HI0302/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0302'
		,h.b.value('(HI03/HI0303/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0303'
		,h.b.value('(HI03/HI0304/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0304'
		,h.b.value('(HI03/HI0305/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0305'
		,h.b.value('(HI03/HI0306/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0306'
		,h.b.value('(HI03/HI0307/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0307'
		,h.b.value('(HI03/HI0308/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0308'
		,h.b.value('(HI03/HI0309/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0309'
		,h.b.value('(HI04/HI0401/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0401'
		,h.b.value('(HI04/HI0402/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0402'
		,h.b.value('(HI04/HI0403/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0403'
		,h.b.value('(HI04/HI0404/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0404'
		,h.b.value('(HI04/HI0405/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0405'
		,h.b.value('(HI04/HI0406/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0406'
		,h.b.value('(HI04/HI0407/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0407'
		,h.b.value('(HI04/HI0408/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0408'
		,h.b.value('(HI04/HI0409/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0409'
		,h.b.value('(HI05/HI0501/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0501'
		,h.b.value('(HI05/HI0502/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0502'
		,h.b.value('(HI05/HI0503/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0503'
		,h.b.value('(HI05/HI0504/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0504'
		,h.b.value('(HI05/HI0505/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0505'
		,h.b.value('(HI05/HI0506/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0506'
		,h.b.value('(HI05/HI0507/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0507'
		,h.b.value('(HI05/HI0508/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0508'
		,h.b.value('(HI05/HI0509/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0509'
		,h.b.value('(HI06/HI0601/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0601'
		,h.b.value('(HI06/HI0602/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0602'
		,h.b.value('(HI06/HI0603/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0603'
		,h.b.value('(HI06/HI0604/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0604'
		,h.b.value('(HI06/HI0605/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0605'
		,h.b.value('(HI06/HI0606/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0606'
		,h.b.value('(HI06/HI0607/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0607'
		,h.b.value('(HI06/HI0608/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0608'
		,h.b.value('(HI06/HI0609/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0609'
		,h.b.value('(HI07/HI0701/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0701'
		,h.b.value('(HI07/HI0702/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0702'
		,h.b.value('(HI07/HI0703/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0703'
		,h.b.value('(HI07/HI0704/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0704'
		,h.b.value('(HI07/HI0705/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0705'
		,h.b.value('(HI07/HI0706/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0706'
		,h.b.value('(HI07/HI0707/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0707'
		,h.b.value('(HI07/HI0708/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0708'
		,h.b.value('(HI07/HI0709/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0709'
		,h.b.value('(HI08/HI0801/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0801'
		,h.b.value('(HI08/HI0802/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0802'
		,h.b.value('(HI08/HI0803/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0803'
		,h.b.value('(HI08/HI0804/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0804'
		,h.b.value('(HI08/HI0805/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0805'
		,h.b.value('(HI08/HI0806/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0806'
		,h.b.value('(HI08/HI0807/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0807'
		,h.b.value('(HI08/HI0808/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0808'
		,h.b.value('(HI08/HI0809/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0809'
		,h.b.value('(HI09/HI0901/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI0901'
		,h.b.value('(HI09/HI0902/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0902'
		,h.b.value('(HI09/HI0903/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI0903'
		,h.b.value('(HI09/HI0904/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI0904'
		,h.b.value('(HI09/HI0905/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI0905'
		,h.b.value('(HI09/HI0906/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI0906'
		,h.b.value('(HI09/HI0907/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI0907'
		,h.b.value('(HI09/HI0908/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI0908'
		,h.b.value('(HI09/HI0909/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI0909'
		,h.b.value('(HI10/HI1001/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI1001'
		,h.b.value('(HI10/HI1002/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1002'
		,h.b.value('(HI10/HI1003/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI1003'
		,h.b.value('(HI10/HI1004/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI1004'
		,h.b.value('(HI10/HI1005/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI1005'
		,h.b.value('(HI10/HI1006/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI1006'
		,h.b.value('(HI10/HI1007/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI1007'
		,h.b.value('(HI10/HI1008/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1008'
		,h.b.value('(HI10/HI1009/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI1009'
		,h.b.value('(HI11/HI1101/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI1101'
		,h.b.value('(HI11/HI1102/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1102'
		,h.b.value('(HI11/HI1103/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI1103'
		,h.b.value('(HI11/HI1104/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI1104'
		,h.b.value('(HI11/HI1105/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI1105'
		,h.b.value('(HI11/HI1106/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI1106'
		,h.b.value('(HI11/HI1107/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI1107'
		,h.b.value('(HI11/HI1108/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1108'
		,h.b.value('(HI11/HI1109/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI1109'
		,h.b.value('(HI12/HI1201/text())[1]', 'varchar(50)') AS 'HI_CodeListQualifierCode_HI1201'
		,h.b.value('(HI12/HI1202/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1202'
		,h.b.value('(HI12/HI1203/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriodFormatQualifier_HI1203'
		,h.b.value('(HI12/HI1204/text())[1]', 'varchar(50)') AS 'HI_DateTimePeriod_HI1204'
		,h.b.value('(HI12/HI1205/text())[1]', 'varchar(50)') AS 'HI_MonetaryAmount_HI1205'
		,h.b.value('(HI12/HI1206/text())[1]', 'varchar(50)') AS 'HI_Quantity_HI1206'
		,h.b.value('(HI12/HI1207/text())[1]', 'varchar(50)') AS 'HI_VersionIdentifier_HI1207'
		,h.b.value('(HI12/HI1208/text())[1]', 'varchar(50)') AS 'HI_IndustryCode_HI1208'
		,h.b.value('(HI12/HI1209/text())[1]', 'varchar(50)') AS 'HI_YesNoConditionOrResponseCode_HI1209'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/HI') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2300'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber	

END -- Procedure
GO
