CREATE TABLE [dbo].[PharmacyClaim]
(
[PharmacyClaimID] [int] NOT NULL IDENTITY(1, 1),
[AdjudicationIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AHFSClassCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AHFSClassDescription] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BasisDays] [smallint] NULL,
[BasisOfCostDeterminationCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrandTradeNameCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimSequenceNumber] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompoundCode_Submitted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostAdjustmentAmount] [money] NULL,
[CostAverageWholesale] [money] NULL,
[CostCopay] [money] NULL,
[CostCopayFlatRate] [money] NULL,
[CostCopayPercentage] [money] NULL,
[CostDeductible] [money] NULL,
[CostDispensingFee] [money] NULL,
[CostDispensingFee_Submitted] [money] NULL,
[CostIngredient] [money] NULL,
[CostIngredient_Submitted] [money] NULL,
[CostOtherPayerPaid] [money] NULL,
[CostPatientPay] [money] NULL,
[CostPlanPay] [money] NULL,
[CostPostage] [money] NULL,
[CostSalesTax] [money] NULL,
[CostTotal] [money] NULL,
[CostTotal_Submitted] [money] NULL,
[CostUsualCustomary] [money] NULL,
[CostWholesaleAcquisition] [money] NULL,
[CostGrossDrugBelowOutOfPocketThreshold] [money] NULL,
[CostGrossDrugAboveOutOfPocketThreshold] [money] NULL,
[CostTrueOutOfPocket] [money] NULL,
[CostLowIncomeSubsidy] [money] NULL,
[CostCoveredPlanAmountTotalPaid] [money] NULL,
[CostNonCoveredPlanAmountTotalPaid] [money] NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateDispensed] [datetime] NULL,
[DateOrdered] [datetime] NULL,
[DatePaid] [datetime] NULL,
[DateRowCreated] [datetime] NULL,
[DateValidBegin] [datetime] NULL,
[DateValidEnd] [datetime] NULL,
[DaysSupply] [smallint] NULL,
[DispenseAsWrittenCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugDEACode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugDosageForm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugGenericCounter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugGenericName] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrugTherapeuticClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployerGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployerDivision] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GPINumber] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashValue] [binary] (16) NULL,
[HealthPlanID] [int] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[ihds_prov_id_dispensing] [int] NULL,
[ihds_prov_id_ordering] [int] NULL,
[ihds_prov_id_pcp] [int] NULL,
[ihds_prov_id_prescribing] [int] NULL,
[InstanceID] [int] NULL,
[IsDuplicate] [bit] NULL,
[IsFormulary] [bit] NULL,
[IsGeneric] [bit] NULL,
[IsMailOrder] [bit] NULL,
[IsMaintenanceDrug] [bit] NULL,
[IsSpecialtyDrug] [bit] NULL,
[IsUpdated] [bit] NULL,
[IsZeroedOut] [bit] NULL,
[LoadInstanceFileID] [int] NULL,
[RowFileID] [bigint] NULL,
[MemberAge] [numeric] (5, 1) NULL,
[MemberID] [int] NULL,
[NDC] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCFormat] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyID] [int] NULL,
[PRDMultiSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrescribingProviderID] [int] NULL,
[PrescriptionNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductSelection_Submitted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [decimal] (11, 3) NULL,
[QuantityDispensed_Submitted] [decimal] (11, 3) NULL,
[QuantityPaid] [decimal] (11, 3) NULL,
[RefillNumber] [smallint] NULL,
[RefillQuantity] [smallint] NULL,
[RefillsRemaining] [smallint] NULL,
[RouteOfAdministration] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[SupplyFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitOfMeasure] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostRebate] [money] NULL,
[CostAdministrationFee] [money] NULL,
[QuantityDispensed] [int] NULL,
[CustomerProviderID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerPrescribingID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVX] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_PharmacyClaim]
GO
CREATE CLUSTERED INDEX [idxmemberID] ON [dbo].[PharmacyClaim] ([MemberID], [PharmacyClaimID]) ON [dbo_PharmacyClaim]
GO
CREATE NONCLUSTERED INDEX [idxPharmacyClaimID] ON [dbo].[PharmacyClaim] ([PharmacyClaimID]) INCLUDE ([DateDispensed], [MemberID]) ON [dbo_PharmacyClaim_IDX]
GO
CREATE STATISTICS [spidxmemberID] ON [dbo].[PharmacyClaim] ([MemberID], [PharmacyClaimID])
GO
CREATE STATISTICS [spidxPharmacyClaimID] ON [dbo].[PharmacyClaim] ([PharmacyClaimID])
GO
