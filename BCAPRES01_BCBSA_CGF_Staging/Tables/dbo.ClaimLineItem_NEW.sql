CREATE TABLE [dbo].[ClaimLineItem_NEW]
(
[ClaimLineItemID] [int] NOT NULL IDENTITY(1, 1),
[LoadInstanceFileID] [int] NULL,
[RowFileID] [bigint] NULL,
[AccountingFund] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountAllowedProvider] [money] NULL,
[AmountAllowedBenefit] [money] NULL,
[AmountCOB] [money] NULL,
[AmountCOBSavings] [money] NULL,
[AmountCoinsurance] [money] NULL,
[AmountCopay] [money] NULL,
[AmountDeductible] [money] NULL,
[AmountDeniedProvider] [money] NULL,
[AmountDeniedBenefit] [money] NULL,
[AmountDisallowed] [money] NULL,
[AmountDiscount] [money] NULL,
[AmountFeeForService] [money] NULL,
[AmountGrossPayment] [money] NULL,
[AmountMedicarePaid] [money] NULL,
[AmountNetPayment] [money] NULL,
[AmountTotalCharge] [money] NULL,
[AmountWithold] [money] NULL,
[ClaimDisallowReason] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [int] NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdjusted] [datetime] NULL,
[DatePaid] [datetime] NULL,
[DateRowCreated] [datetime] NULL,
[DateServiceBegin] [datetime] NULL,
[DateServiceEnd] [datetime] NULL,
[DateValidBegin] [datetime] NULL,
[DateValidEnd] [datetime] NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FeeSchedule] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashValue] [binary] (16) NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemNumber] [smallint] NULL,
[PayerClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerClaimLineID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceCodeIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureCodeModifier] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueCode] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeOfService] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [numeric] (10, 2) NULL,
[IsUpdated] [bit] NULL,
[RowID] [int] NULL,
[CoveredDays] [numeric] (10, 2) NULL,
[CPT_II] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier1] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier2] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPCSProcedureCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsHighTechImage] [bit] NULL,
[ClaimStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountBilled] [numeric] (11, 2) NULL,
[CPTCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePosted] [datetime] NULL,
[DateCheckProcessed] [datetime] NULL,
[ClaimLineCreateDate] [datetime] NULL,
[ClaimLineCreateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimLineUpdateDate] [datetime] NULL,
[ClaimLineUpdateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessingStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjudicationMethod] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCategory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerClaimLineID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerProcedureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerAlternateProcedureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountWithhold] [numeric] (11, 2) NULL,
[AdjustmentReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountAllowed] [numeric] (11, 2) NULL,
[NotCoveredReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountInterest] [money] NULL,
[AmountOtherCarrier] [money] NULL,
[AmountPaidNet] [money] NULL,
[AmountPenalty] [money] NULL,
[AmountPatientResp] [money] NULL,
[ClaimAllowReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimCopayReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimCoinsuranceReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimWithholdReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDeductibleReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNotCoveredReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimOtherCarrierReasonCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimAllowReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimCopayReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimCoinsuranceReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimWithholdReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDeductibleReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNotCoveredReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimOtherCarrierReasonDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CapitatedFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerLineNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSubLineCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XcelysMedicalDefinition] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XcelysMedicalDefinitionDesc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPCSApc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier5] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier6] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
