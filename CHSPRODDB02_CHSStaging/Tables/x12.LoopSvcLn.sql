CREATE TABLE [x12].[LoopSvcLn]
(
[SvcLn_RowID] [int] NULL,
[SvcLn_RowIDParent] [int] NULL,
[SvcLn_CentauriClientID] [int] NULL,
[SvcLn_FileLogID] [int] NULL,
[SvcLn_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_AssignedNumber_LX01] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceIDQualifier_SV10101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV10102] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV10103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV10104] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV10105] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV10106] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_SV10107] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV10108] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV102] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_SV103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_SV104] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_FacilityCodeValue_SV105] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ServiceTypeCode_SV106] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV10701] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV10702] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV10703] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV10704] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV108] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_YesNoConditionOrResponseCode_SV109] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MultipleProcedureCode_SV110] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_YesNoConditionOrResponseCode_SV111] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_YesNoConditionOrResponseCode_SV112] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReviewCode_SV113] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_NationalOrLocalAssignedReviewValue_SV114] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_CopayStatusCode_SV115] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_HealthCareProfessionalShortageAreaCode_SV116] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReferenceIdentification_SV117] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_PostalCode_SV118] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV119] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_LevelofCareCode_SV120] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProviderAgreementCode_SV121] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV201] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceIDQualifier_SV20201] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV20202] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV20203] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV20204] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV20205] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV20206] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_SV20207] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV20208] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV203] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitorBasisforMeasurementCode_SV204] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_SV205] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitRate_SV206] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV207] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_YesNoConditionOrResponseCode_SV208] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_NursingHomeResidentialStatusCode_SV209] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_LevelOfCareCode_SV210] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceIDQualifier_SV30101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV30102] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV30103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV30104] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV30105] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV30106] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_SV30107] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV30108] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV302] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_FacilityCodeValue_SV303] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_OralCavityDesignationCode_SV30401] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_OralCavityDesignationCode_SV30402] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_OralCavityDesignationCode_SV30403] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_OralCavityDesignationCode_SV30404] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_OralCavityDesignationCode_SV30405] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProsthesisCrownOrInlayCode_SV305] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_SV306] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_SV307] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_CopayStatusCode_SV308] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProviderAgreementCode_SV309] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_YesNoConditionOrResponseCode_SV310] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV31101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV31102] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV31103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_DiagnosisCodePointer_SV31104] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceIDQualifier_SV50101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV50102] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV50103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV50104] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV50105] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProcedureModifier_SV50106] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_SV50107] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_SV50108] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_SV502] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_SV503] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV504] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_SV505] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_FrequencyCode_SV506] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_PrognosisCode_SV507] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_CR101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Weight_CR102] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_AmbulanceTransportCode_CR103] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_AmbulanceTransportReasonCode_CR104] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_CR105] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_CR106] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_AddressInformation_CR107] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_AddressInformation_CR108] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_CR109] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_CR110] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_CertificationTypeCode_CR301] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_CR302] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_CR303] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_InsulinDependentCode_CR304] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Description_CR305] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ContractTypeCode_CN101] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_CN102] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_PercentDecimalFormat_CN103] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReferenceIdentification_CN104] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_TermsDiscountPercent_CN105] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_VersionIdentifier_CN106] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReferenceIdentification_PS101] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_PS102] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_StateOrProvinceCode_PS103] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_PricingMethodology_HCP01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_HCP02] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_HCP03] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReferenceIdentification_HCP04] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Rate_HCP05] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ReferenceIdentification_HCP06] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_MonetaryAmount_HCP07] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_HCP08] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceIDQualifier_HCP09] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ProductServiceID_HCP10] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_UnitOrBasisForMeasurementCode_HCP11] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_Quantity_HCP12] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_RejectReasonCode_HCP13] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_PolicyComplianceCode_HCP14] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLn_ExceptionCode_HCP15] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO