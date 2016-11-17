SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2400 Service Line Number loops and their repeated segments.
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000003') -- 000000001 000000003 000002175
		AND LoopID = '2400'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopSvcLn
		TRUNCATE TABLE x12.SegTOO
		TRUNCATE TABLE x12.SegPWK
		TRUNCATE TABLE x12.SegCRC
		TRUNCATE TABLE x12.SegDTP
		TRUNCATE TABLE x12.SegQTY
		TRUNCATE TABLE x12.SegMEA
		TRUNCATE TABLE x12.SegREF
		TRUNCATE TABLE x12.SegAMT
		TRUNCATE TABLE x12.SegK3
		TRUNCATE TABLE x12.SegNTE		

	EXEC x12.spLoopSvcLnParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000002175') AND LoopID = '2400'
	SELECT * FROM x12.LoopSvcLn WHERE SvcLn_TransactionControlNumber IN ('000002175') ORDER BY SvcLn_LoopID
		SELECT * FROM x12.SegTOO WHERE TOO_TransactionControlNumber IN ('000002175') ORDER BY TOO_LoopID
		SELECT * FROM x12.SegPWK WHERE PWK_TransactionControlNumber IN ('000002175') ORDER BY PWK_LoopID
		SELECT * FROM x12.SegCRC WHERE CRC_TransactionControlNumber IN ('000002175') ORDER BY CRC_LoopID
		SELECT * FROM x12.SegDTP WHERE DTP_TransactionControlNumber IN ('000002175') ORDER BY DTP_LoopID
		SELECT * FROM x12.SegQTY WHERE QTY_TransactionControlNumber IN ('000002175') ORDER BY QTY_LoopID
		SELECT * FROM x12.SegMEA WHERE MEA_TransactionControlNumber IN ('000002175') ORDER BY MEA_LoopID
		SELECT * FROM x12.SegREF WHERE REF_TransactionControlNumber IN ('000002175') ORDER BY REF_LoopID
		SELECT * FROM x12.SegAMT WHERE AMT_TransactionControlNumber IN ('000002175') ORDER BY AMT_LoopID
		SELECT * FROM x12.SegK3 WHERE K3_TransactionControlNumber IN ('000002175') ORDER BY K3_LoopID
		SELECT * FROM x12.SegNTE WHERE NTE_TransactionControlNumber IN ('000002175') ORDER BY NTE_LoopID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopSvcLnParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO x12.LoopSvcLn (
		SvcLn_RowID
		,SvcLn_RowIDParent
		,SvcLn_CentauriClientID
		,SvcLn_FileLogID
		,SvcLn_TransactionImplementationConventionReference
		,SvcLn_TransactionControlNumber
		,SvcLn_LoopID

		,SvcLn_AssignedNumber_LX01

		,SvcLn_ProductServiceIDQualifier_SV10101
		,SvcLn_ProductServiceID_SV10102
		,SvcLn_ProcedureModifier_SV10103
		,SvcLn_ProcedureModifier_SV10104
		,SvcLn_ProcedureModifier_SV10105
		,SvcLn_ProcedureModifier_SV10106
		,SvcLn_Description_SV10107
		,SvcLn_ProductServiceID_SV10108
		,SvcLn_MonetaryAmount_SV102
		,SvcLn_UnitOrBasisForMeasurementCode_SV103
		,SvcLn_Quantity_SV104
		,SvcLn_FacilityCodeValue_SV105
		,SvcLn_ServiceTypeCode_SV106
		,SvcLn_DiagnosisCodePointer_SV10701
		,SvcLn_DiagnosisCodePointer_SV10702
		,SvcLn_DiagnosisCodePointer_SV10703
		,SvcLn_DiagnosisCodePointer_SV10704
		,SvcLn_MonetaryAmount_SV108
		,SvcLn_YesNoConditionOrResponseCode_SV109
		,SvcLn_MultipleProcedureCode_SV110
		,SvcLn_YesNoConditionOrResponseCode_SV111
		,SvcLn_YesNoConditionOrResponseCode_SV112
		,SvcLn_ReviewCode_SV113
		,SvcLn_NationalOrLocalAssignedReviewValue_SV114
		,SvcLn_CopayStatusCode_SV115
		,SvcLn_HealthCareProfessionalShortageAreaCode_SV116
		,SvcLn_ReferenceIdentification_SV117
		,SvcLn_PostalCode_SV118
		,SvcLn_MonetaryAmount_SV119
		,SvcLn_LevelofCareCode_SV120
		,SvcLn_ProviderAgreementCode_SV121

		,SvcLn_ProductServiceID_SV201
		,SvcLn_ProductServiceIDQualifier_SV20201
		,SvcLn_ProductServiceID_SV20202
		,SvcLn_ProcedureModifier_SV20203
		,SvcLn_ProcedureModifier_SV20204
		,SvcLn_ProcedureModifier_SV20205
		,SvcLn_ProcedureModifier_SV20206
		,SvcLn_Description_SV20207
		,SvcLn_ProductServiceID_SV20208
		,SvcLn_MonetaryAmount_SV203
		,SvcLn_UnitorBasisforMeasurementCode_SV204
		,SvcLn_Quantity_SV205
		,SvcLn_UnitRate_SV206
		,SvcLn_MonetaryAmount_SV207
		,SvcLn_YesNoConditionOrResponseCode_SV208
		,SvcLn_NursingHomeResidentialStatusCode_SV209
		,SvcLn_LevelOfCareCode_SV210

		,SvcLn_ProductServiceIDQualifier_SV30101
		,SvcLn_ProductServiceID_SV30102
		,SvcLn_ProcedureModifier_SV30103
		,SvcLn_ProcedureModifier_SV30104
		,SvcLn_ProcedureModifier_SV30105
		,SvcLn_ProcedureModifier_SV30106
		,SvcLn_Description_SV30107
		,SvcLn_ProductServiceID_SV30108
		,SvcLn_MonetaryAmount_SV302
		,SvcLn_FacilityCodeValue_SV303
		,SvcLn_OralCavityDesignationCode_SV30401
		,SvcLn_OralCavityDesignationCode_SV30402
		,SvcLn_OralCavityDesignationCode_SV30403
		,SvcLn_OralCavityDesignationCode_SV30404
		,SvcLn_OralCavityDesignationCode_SV30405
		,SvcLn_ProsthesisCrownOrInlayCode_SV305
		,SvcLn_Quantity_SV306
		,SvcLn_Description_SV307
		,SvcLn_CopayStatusCode_SV308
		,SvcLn_ProviderAgreementCode_SV309
		,SvcLn_YesNoConditionOrResponseCode_SV310
		,SvcLn_DiagnosisCodePointer_SV31101
		,SvcLn_DiagnosisCodePointer_SV31102
		,SvcLn_DiagnosisCodePointer_SV31103
		,SvcLn_DiagnosisCodePointer_SV31104

		,SvcLn_ProductServiceIDQualifier_SV50101
		,SvcLn_ProductServiceID_SV50102
		,SvcLn_ProcedureModifier_SV50103
		,SvcLn_ProcedureModifier_SV50104
		,SvcLn_ProcedureModifier_SV50105
		,SvcLn_ProcedureModifier_SV50106
		,SvcLn_Description_SV50107
		,SvcLn_ProductServiceID_SV50108
		,SvcLn_UnitOrBasisForMeasurementCode_SV502
		,SvcLn_Quantity_SV503
		,SvcLn_MonetaryAmount_SV504
		,SvcLn_MonetaryAmount_SV505
		,SvcLn_FrequencyCode_SV506
		,SvcLn_PrognosisCode_SV507

		,SvcLn_UnitOrBasisForMeasurementCode_CR101
		,SvcLn_Weight_CR102
		,SvcLn_AmbulanceTransportCode_CR103
		,SvcLn_AmbulanceTransportReasonCode_CR104
		,SvcLn_UnitOrBasisForMeasurementCode_CR105
		,SvcLn_Quantity_CR106
		,SvcLn_AddressInformation_CR107
		,SvcLn_AddressInformation_CR108
		,SvcLn_Description_CR109
		,SvcLn_Description_CR110

		,SvcLn_CertificationTypeCode_CR301
		,SvcLn_UnitOrBasisForMeasurementCode_CR302
		,SvcLn_Quantity_CR303
		,SvcLn_InsulinDependentCode_CR304
		,SvcLn_Description_CR305

		,SvcLn_ContractTypeCode_CN101
		,SvcLn_MonetaryAmount_CN102
		,SvcLn_PercentDecimalFormat_CN103
		,SvcLn_ReferenceIdentification_CN104
		,SvcLn_TermsDiscountPercent_CN105
		,SvcLn_VersionIdentifier_CN106

		,SvcLn_ReferenceIdentification_PS101
		,SvcLn_MonetaryAmount_PS102
		,SvcLn_StateOrProvinceCode_PS103

		,SvcLn_PricingMethodology_HCP01
		,SvcLn_MonetaryAmount_HCP02
		,SvcLn_MonetaryAmount_HCP03
		,SvcLn_ReferenceIdentification_HCP04
		,SvcLn_Rate_HCP05
		,SvcLn_ReferenceIdentification_HCP06
		,SvcLn_MonetaryAmount_HCP07
		,SvcLn_ProductServiceID_HCP08
		,SvcLn_ProductServiceIDQualifier_HCP09
		,SvcLn_ProductServiceID_HCP10
		,SvcLn_UnitOrBasisForMeasurementCode_HCP11
		,SvcLn_Quantity_HCP12
		,SvcLn_RejectReasonCode_HCP13
		,SvcLn_PolicyComplianceCode_HCP14
		,SvcLn_ExceptionCode_HCP15
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- SvcLn - 2400 - SERVICE LINE NUMBER
		-- SvcLn - 2400 - LX
		,h.b.value('(LX/LX01/text())[1]', 'varchar(50)') AS 'SvcLn_AssignedNumber_LX01'
		-- SvcLn - 2400 - SV1/SV101 - COMPOSITE MEDICAL PROCEDURE IDENTIFIER
		,h.b.value('(SV1/SV101/SV10101/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceIDQualifier_SV10101'
		,h.b.value('(SV1/SV101/SV10102/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV10102'
		,h.b.value('(SV1/SV101/SV10103/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV10103'
		,h.b.value('(SV1/SV101/SV10104/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV10104'
		,h.b.value('(SV1/SV101/SV10105/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV10105'
		,h.b.value('(SV1/SV101/SV10106/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV10106'
		,h.b.value('(SV1/SV101/SV10107/text())[1]', 'varchar(50)') AS 'SvcLn_Description_SV10107'
		,h.b.value('(SV1/SV101/SV10108/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV10108'
		,h.b.value('(SV1/SV102/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV102'
		,h.b.value('(SV1/SV103/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_SV103'
		,h.b.value('(SV1/SV104/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_SV104'
		,h.b.value('(SV1/SV105/text())[1]', 'varchar(50)') AS 'SvcLn_FacilityCodeValue_SV105'
		,h.b.value('(SV1/SV106/text())[1]', 'varchar(50)') AS 'SvcLn_ServiceTypeCode_SV106'
		-- SvcLn - 2400 - SV1/SV107 - COMPOSITE DIAGNOSIS CODE POINTER
		,h.b.value('(SV1/SV107/SV10701/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV10701'
		,h.b.value('(SV1/SV107/SV10702/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV10702'
		,h.b.value('(SV1/SV107/SV10703/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV10703'
		,h.b.value('(SV1/SV107/SV10704/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV10704'
		,h.b.value('(SV1/SV108/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV108'
		,h.b.value('(SV1/SV109/text())[1]', 'varchar(50)') AS 'SvcLn_YesNoConditionOrResponseCode_SV109'
		,h.b.value('(SV1/SV110/text())[1]', 'varchar(50)') AS 'SvcLn_MultipleProcedureCode_SV110'
		,h.b.value('(SV1/SV111/text())[1]', 'varchar(50)') AS 'SvcLn_YesNoConditionOrResponseCode_SV111'
		,h.b.value('(SV1/SV112/text())[1]', 'varchar(50)') AS 'SvcLn_YesNoConditionOrResponseCode_SV112'
		,h.b.value('(SV1/SV113/text())[1]', 'varchar(50)') AS 'SvcLn_ReviewCode_SV113'
		,h.b.value('(SV1/SV114/text())[1]', 'varchar(50)') AS 'SvcLn_NationalOrLocalAssignedReviewValue_SV114'
		,h.b.value('(SV1/SV115/text())[1]', 'varchar(50)') AS 'SvcLn_CopayStatusCode_SV115'
		,h.b.value('(SV1/SV116/text())[1]', 'varchar(50)') AS 'SvcLn_HealthCareProfessionalShortageAreaCode_SV116'
		,h.b.value('(SV1/SV117/text())[1]', 'varchar(50)') AS 'SvcLn_ReferenceIdentification_SV117'
		,h.b.value('(SV1/SV118/text())[1]', 'varchar(50)') AS 'SvcLn_PostalCode_SV118'
		,h.b.value('(SV1/SV119/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV119'
		,h.b.value('(SV1/SV120/text())[1]', 'varchar(50)') AS 'SvcLn_LevelofCareCode_SV120'
		,h.b.value('(SV1/SV121/text())[1]', 'varchar(50)') AS 'SvcLn_ProviderAgreementCode_SV121'
		-- SvcLn - 2400 - SV2 - INSTITUTIONAL SERVICE LINE
		,h.b.value('(SV2/SV201/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV201'
		-- SvcLn - 2400 - SV2/SV202 - COMPOSITE MEDICAL PROCEDURE IDENTIFIER
		,h.b.value('(SV2/SV202/SV20201/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceIDQualifier_SV20201'
		,h.b.value('(SV2/SV202/SV20202/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV20202'
		,h.b.value('(SV2/SV202/SV20203/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV20203'
		,h.b.value('(SV2/SV202/SV20204/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV20204'
		,h.b.value('(SV2/SV202/SV20205/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV20205'
		,h.b.value('(SV2/SV202/SV20206/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV20206'
		,h.b.value('(SV2/SV202/SV20207/text())[1]', 'varchar(50)') AS 'SvcLn_Description_SV20207'
		,h.b.value('(SV2/SV202/SV20208/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV20208'
		,h.b.value('(SV2/SV203/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV203'
		,h.b.value('(SV2/SV204/text())[1]', 'varchar(50)') AS 'SvcLn_UnitorBasisforMeasurementCode_SV204'
		,h.b.value('(SV2/SV205/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_SV205'
		,h.b.value('(SV2/SV206/text())[1]', 'varchar(50)') AS 'SvcLn_UnitRate_SV206'
		,h.b.value('(SV2/SV207/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV207'
		,h.b.value('(SV2/SV208/text())[1]', 'varchar(50)') AS 'SvcLn_YesNoConditionOrResponseCode_SV208'
		,h.b.value('(SV2/SV209/text())[1]', 'varchar(50)') AS 'SvcLn_NursingHomeResidentialStatusCode_SV209'
		,h.b.value('(SV2/SV210/text())[1]', 'varchar(50)') AS 'SvcLn_LevelOfCareCode_SV210'
		-- SvcLn - 2400 - SV3 - DENTAL SERVICE
		-- SvcLn - 2400 - SV3/SV301 - COMPOSITE MEDICAL PROCEDURE IDENTIFIER
		,h.b.value('(SV3/SV301/SV30101/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceIDQualifier_SV30101'
		,h.b.value('(SV3/SV301/SV30102/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV30102'
		,h.b.value('(SV3/SV301/SV30103/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV30103'
		,h.b.value('(SV3/SV301/SV30104/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV30104'
		,h.b.value('(SV3/SV301/SV30105/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV30105'
		,h.b.value('(SV3/SV301/SV30106/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV30106'
		,h.b.value('(SV3/SV301/SV30107/text())[1]', 'varchar(50)') AS 'SvcLn_Description_SV30107'
		,h.b.value('(SV3/SV301/SV30108/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV30108'
		,h.b.value('(SV3/SV302/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV302'
		,h.b.value('(SV3/SV303/text())[1]', 'varchar(50)') AS 'SvcLn_FacilityCodeValue_SV303'
		-- SvcLn - 2400 - SV3/SV304 - ORAL CAVITY DESIGNATION
		,h.b.value('(SV3/SV304/SV30401/text())[1]', 'varchar(50)') AS 'SvcLn_OralCavityDesignationCode_SV30401'
		,h.b.value('(SV3/SV304/SV30402/text())[1]', 'varchar(50)') AS 'SvcLn_OralCavityDesignationCode_SV30402'
		,h.b.value('(SV3/SV304/SV30403/text())[1]', 'varchar(50)') AS 'SvcLn_OralCavityDesignationCode_SV30403'
		,h.b.value('(SV3/SV304/SV30404/text())[1]', 'varchar(50)') AS 'SvcLn_OralCavityDesignationCode_SV30404'
		,h.b.value('(SV3/SV304/SV30405/text())[1]', 'varchar(50)') AS 'SvcLn_OralCavityDesignationCode_SV30405'
		,h.b.value('(SV3/SV305/text())[1]', 'varchar(50)') AS 'SvcLn_ProsthesisCrownOrInlayCode_SV305'
		,h.b.value('(SV3/SV306/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_SV306'
		,h.b.value('(SV3/SV307/text())[1]', 'varchar(50)') AS 'SvcLn_Description_SV307'
		,h.b.value('(SV3/SV308/text())[1]', 'varchar(50)') AS 'SvcLn_CopayStatusCode_SV308'
		,h.b.value('(SV3/SV309/text())[1]', 'varchar(50)') AS 'SvcLn_ProviderAgreementCode_SV309'
		,h.b.value('(SV3/SV310/text())[1]', 'varchar(50)') AS 'SvcLn_YesNoConditionOrResponseCode_SV310'
		-- SvcLn - 2400 - SV3/SV311 - COMPOSITE DIAGNOSIS CODE POINTER
		,h.b.value('(SV311/SV31101/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV31101'
		,h.b.value('(SV311/SV31102/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV31102'
		,h.b.value('(SV311/SV31103/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV31103'
		,h.b.value('(SV311/SV31104/text())[1]', 'varchar(50)') AS 'SvcLn_DiagnosisCodePointer_SV31104'
		-- SvcLn - 2400 - SV5 Durable Medical Equipment Service
		-- SvcLn - 2400 - SV5/SV501
		,h.b.value('(SV5/SV501/SV50101/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceIDQualifier_SV50101'
		,h.b.value('(SV5/SV501/SV50102/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV50102'
		,h.b.value('(SV5/SV501/SV50103/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV50103'
		,h.b.value('(SV5/SV501/SV50104/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV50104'
		,h.b.value('(SV5/SV501/SV50105/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV50105'
		,h.b.value('(SV5/SV501/SV50106/text())[1]', 'varchar(50)') AS 'SvcLn_ProcedureModifier_SV50106'
		,h.b.value('(SV5/SV501/SV50107/text())[1]', 'varchar(50)') AS 'SvcLn_Description_SV50107'
		,h.b.value('(SV5/SV501/SV50108/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_SV50108'
		,h.b.value('(SV5/SV502/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_SV502'
		,h.b.value('(SV5/SV503/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_SV503'
		,h.b.value('(SV5/SV504/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV504'
		,h.b.value('(SV5/SV505/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_SV505'
		,h.b.value('(SV5/SV506/text())[1]', 'varchar(50)') AS 'SvcLn_FrequencyCode_SV506'
		,h.b.value('(SV5/SV507/text())[1]', 'varchar(50)') AS 'SvcLn_PrognosisCode_SV507'
		-- PWK - 2400 - PWK - !!! Collected Separately !!!
		-- SvcLn - 2400 - CR1
		,h.b.value('(CR1/CR101/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_CR101'
		,h.b.value('(CR1/CR102/text())[1]', 'varchar(50)') AS 'SvcLn_Weight_CR102'
		,h.b.value('(CR1/CR103/text())[1]', 'varchar(50)') AS 'SvcLn_AmbulanceTransportCode_CR103'
		,h.b.value('(CR1/CR104/text())[1]', 'varchar(50)') AS 'SvcLn_AmbulanceTransportReasonCode_CR104'
		,h.b.value('(CR1/CR105/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_CR105'
		,h.b.value('(CR1/CR106/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_CR106'
		,h.b.value('(CR1/CR107/text())[1]', 'varchar(50)') AS 'SvcLn_AddressInformation_CR107'
		,h.b.value('(CR1/CR108/text())[1]', 'varchar(50)') AS 'SvcLn_AddressInformation_CR108'
		,h.b.value('(CR1/CR109/text())[1]', 'varchar(50)') AS 'SvcLn_Description_CR109'
		,h.b.value('(CR1/CR110/text())[1]', 'varchar(50)') AS 'SvcLn_Description_CR110'
		-- SvcLn - 2400 - CR3
		,h.b.value('(CR3/CR301/text())[1]', 'varchar(50)') AS 'SvcLn_CertificationTypeCode_CR301'
		,h.b.value('(CR3/CR302/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_CR302'
		,h.b.value('(CR3/CR303/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_CR303'
		,h.b.value('(CR3/CR304/text())[1]', 'varchar(50)') AS 'SvcLn_InsulinDependentCode_CR304'
		,h.b.value('(CR3/CR305/text())[1]', 'varchar(50)') AS 'SvcLn_Description_CR305'
		-- CRC - 2400 - CRC - !!! Collected Separately !!!
		-- DTP - 2400 - DTP - !!! Collected Separately !!!
		-- QTY - 2400 - QTY  - !!! Collected Separately !!!
		-- MEA - 2400 - MEA - !!! Collected Separately !!!
		-- SvcLn - 2400 - CN1 - Contact Information
		,h.b.value('(CN1/CN101/text())[1]', 'varchar(50)') AS 'SvcLn_ContractTypeCode_CN101'
		,h.b.value('(CN1/CN102/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_CN102'
		,h.b.value('(CN1/CN103/text())[1]', 'varchar(50)') AS 'SvcLn_PercentDecimalFormat_CN103'
		,h.b.value('(CN1/CN104/text())[1]', 'varchar(50)') AS 'SvcLn_ReferenceIdentification_CN104'
		,h.b.value('(CN1/CN105/text())[1]', 'varchar(50)') AS 'SvcLn_TermsDiscountPercent_CN105'
		,h.b.value('(CN1/CN106/text())[1]', 'varchar(50)') AS 'SvcLn_VersionIdentifier_CN106'
		-- REF - !!! Collected Separately !!!
		-- AMT - !!! Collected Separately !!!
		-- K3 - !!! Collected Separately !!!
		-- NTE - !!! Collected Separately !!!
		-- SvcLn - 2400 - PS1
		,h.b.value('(PS1/PS101/text())[1]', 'varchar(50)') AS 'SvcLn_ReferenceIdentification_PS101'
		,h.b.value('(PS1/PS102/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_PS102'
		,h.b.value('(PS1/PS103/text())[1]', 'varchar(50)') AS 'SvcLn_StateOrProvinceCode_PS103'
		-- SvcLn - 2400 - HCP
		,h.b.value('(HCP/HCP01/text())[1]', 'varchar(50)') AS 'SvcLn_PricingMethodology_HCP01'
		,h.b.value('(HCP/HCP02/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_HCP02'
		,h.b.value('(HCP/HCP03/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_HCP03'
		,h.b.value('(HCP/HCP04/text())[1]', 'varchar(50)') AS 'SvcLn_ReferenceIdentification_HCP04'
		,h.b.value('(HCP/HCP05/text())[1]', 'varchar(50)') AS 'SvcLn_Rate_HCP05'
		,h.b.value('(HCP/HCP06/text())[1]', 'varchar(50)') AS 'SvcLn_ReferenceIdentification_HCP06'
		,h.b.value('(HCP/HCP07/text())[1]', 'varchar(50)') AS 'SvcLn_MonetaryAmount_HCP07'
		,h.b.value('(HCP/HCP08/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_HCP08'
		,h.b.value('(HCP/HCP09/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceIDQualifier_HCP09'
		,h.b.value('(HCP/HCP10/text())[1]', 'varchar(50)') AS 'SvcLn_ProductServiceID_HCP10'
		,h.b.value('(HCP/HCP11/text())[1]', 'varchar(50)') AS 'SvcLn_UnitOrBasisForMeasurementCode_HCP11'
		,h.b.value('(HCP/HCP12/text())[1]', 'varchar(50)') AS 'SvcLn_Quantity_HCP12'
		,h.b.value('(HCP/HCP13/text())[1]', 'varchar(50)') AS 'SvcLn_RejectReasonCode_HCP13'
		,h.b.value('(HCP/HCP14/text())[1]', 'varchar(50)') AS 'SvcLn_PolicyComplianceCode_HCP14'
		,h.b.value('(HCP/HCP15/text())[1]', 'varchar(50)') AS 'SvcLn_ExceptionCode_HCP15'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- TOO - CLAIM SUPPLEMENTAL INFORMATION 

	INSERT INTO x12.SegTOO (
		TOO_RowID
		,TOO_RowIDParent
		,TOO_CentauriClientID
		,TOO_FileLogID
		,TOO_TransactionImplementationConventionReference
		,TOO_TransactionControlNumber
		,TOO_LoopID

		,TOO_CodeListQualifierCode_TOO01
		,TOO_IndustryCode_TOO02
		,TOO_ToothSurfaceCode_TOO0301
		,TOO_ToothSurfaceCode_TOO0302
		,TOO_ToothSurfaceCode_TOO0303
		,TOO_ToothSurfaceCode_TOO0304
		,TOO_ToothSurfaceCode_TOO0305
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(TOO01/text())[1]', 'varchar(50)') AS 'TOO_CodeListQualifierCode_TOO01'
		,h.b.value('(TOO02/text())[1]', 'varchar(50)') AS 'TOO_IndustryCode_TOO02'
		-- TOO - 2400 - TOO/TOO03
		,h.b.value('(TOO03/TOO0301/text())[1]', 'varchar(50)') AS 'TOO_ToothSurfaceCode_TOO0301'
		,h.b.value('(TOO03/TOO0302/text())[1]', 'varchar(50)') AS 'TOO_ToothSurfaceCode_TOO0302'
		,h.b.value('(TOO03/TOO0303/text())[1]', 'varchar(50)') AS 'TOO_ToothSurfaceCode_TOO0303'
		,h.b.value('(TOO03/TOO0304/text())[1]', 'varchar(50)') AS 'TOO_ToothSurfaceCode_TOO0304'
		,h.b.value('(TOO03/TOO0305/text())[1]', 'varchar(50)') AS 'TOO_ToothSurfaceCode_TOO0305'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/TOO') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
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
		AND x.LoopID = '2400'
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
		AND x.LoopID = '2400'
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
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- QTY

	INSERT INTO x12.SegQTY (
		QTY_RowID
		,QTY_RowIDParent
		,QTY_CentauriClientID
		,QTY_FileLogID
		,QTY_TransactionImplementationConventionReference
		,QTY_TransactionControlNumber
		,QTY_LoopID

		,QTY_QuantityQualifier_QTY01
		,QTY_Quantity_QTY02
		,QTY_CompositeUnitofMeasure_QTY03
		,QTY_FreeForminformation_QTY04
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(QTY01/text())[1]', 'varchar(50)') AS 'QTY_QuantityQualifier_QTY01'
		,h.b.value('(QTY02/text())[1]', 'varchar(50)') AS 'QTY_Quantity_QTY02'
		,h.b.value('(QTY03/text())[1]', 'varchar(50)') AS 'QTY_CompositeUnitofMeasure_QTY03'
		,h.b.value('(QTY04/text())[1]', 'varchar(50)') AS 'QTY_FreeForminformation_QTY04'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/QTY') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- MEA 

	INSERT INTO x12.SegMEA (
		MEA_RowID
		,MEA_RowIDParent
		,MEA_CentauriClientID
		,MEA_FileLogID
		,MEA_TransactionImplementationConventionReference
		,MEA_TransactionControlNumber
		,MEA_LoopID

		,MEA_MeasurementReferenceIDCode_MEA01
		,MEA_MeasurementQualifer_MEA02
		,MEA_MeasurementValue_MEA03
		,MEA_CompositeUnitOfMeasure_MEA04
		,MEA_RangeMinimum_MEA05
		,MEA_RangeMaximum_MEA06
		,MEA_MeasurementSignificanceCode_MEA07
		,MEA_MeasurementAttributeCode_MEA08
		,MEA_SurfaceLayerPositioinCode_MEA09
		,MEA_MeasurementMethodOrDevice_MEA10
		,MEA_CodeListQualifierCode_MEA11
		,MEA_IndustryCode_MEA12
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(MEA01/text())[1]', 'varchar(50)') AS 'MEA_MeasurementReferenceIDCode_MEA01'
		,h.b.value('(MEA02/text())[1]', 'varchar(50)') AS 'MEA_MeasurementQualifer_MEA02'
		,h.b.value('(MEA03/text())[1]', 'varchar(50)') AS 'MEA_MeasurementValue_MEA03'
		,h.b.value('(MEA04/text())[1]', 'varchar(50)') AS 'MEA_CompositeUnitOfMeasure_MEA04'
		,h.b.value('(MEA05/text())[1]', 'varchar(50)') AS 'MEA_RangeMinimum_MEA05'
		,h.b.value('(MEA06/text())[1]', 'varchar(50)') AS 'MEA_RangeMaximum_MEA06'
		,h.b.value('(MEA07/text())[1]', 'varchar(50)') AS 'MEA_MeasurementSignificanceCode_MEA07'
		,h.b.value('(MEA08/text())[1]', 'varchar(50)') AS 'MEA_MeasurementAttributeCode_MEA08'
		,h.b.value('(MEA09/text())[1]', 'varchar(50)') AS 'MEA_SurfaceLayerPositioinCode_MEA09'
		,h.b.value('(MEA10/text())[1]', 'varchar(50)') AS 'MEA_MeasurementMethodOrDevice_MEA10'
		,h.b.value('(MEA11/text())[1]', 'varchar(50)') AS 'MEA_CodeListQualifierCode_MEA11'
		,h.b.value('(MEA12/text())[1]', 'varchar(50)') AS 'MEA_IndustryCode_MEA12'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/MEA') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
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
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- AMT

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

		,h.b.value('(AMT01/text())[1]', 'varchar(50)') AS 'AMT_AmountQualifierCode_AMT01'
		,h.b.value('(AMT02/text())[1]', 'varchar(50)') AS 'AMT_MonetaryAmount_AMT02'
		,h.b.value('(AMT03/text())[1]', 'varchar(50)') AS 'AMT_CreditDebitFlagCode_AMT03'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/AMT') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
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
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- NTE

	INSERT INTO x12.SegNTE (
		NTE_RowID
		,NTE_RowIDParent
		,NTE_CentauriClientID
		,NTE_FileLogID
		,NTE_TransactionImplementationConventionReference
		,NTE_TransactionControlNumber
		,NTE_LoopID

		,NTE_NoteReferenceCode_NTE01
		,NTE_Description_NTE02
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(NTE01/text())[1]', 'varchar(50)') AS 'NTE_NoteReferenceCode_NTE01'
		,h.b.value('(NTE02/text())[1]', 'varchar(50)') AS 'NTE_Description_NTE02'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/NTE') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2400'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
