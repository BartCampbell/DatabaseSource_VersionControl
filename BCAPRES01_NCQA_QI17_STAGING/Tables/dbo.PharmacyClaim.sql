CREATE TABLE [dbo].[PharmacyClaim]
(
[PharmacyClaimID] [int] NOT NULL IDENTITY(1, 1),
[AdjudicationIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostAverageWholesale] [money] NULL,
[CostCopay] [money] NULL,
[CostDeductible] [money] NULL,
[CostDispensingFee] [money] NULL,
[CostIngredient] [money] NULL,
[CostPatientPay] [money] NULL,
[CostPlanPay] [money] NULL,
[CostSalesTax] [money] NULL,
[CostTotal] [money] NULL,
[CostUsualCustomary] [money] NULL,
[CostRebate] [money] NULL,
[CostAdministrationFee] [money] NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateDispensed] [smalldatetime] NULL,
[DateOrdered] [smalldatetime] NULL,
[DatePaid] [smalldatetime] NULL,
[DateValidBegin] [smalldatetime] NULL,
[DateValidEnd] [smalldatetime] NULL,
[DaysSupply] [smallint] NULL,
[DispenseAsWrittenCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPlanID] [int] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[ihds_prov_id_dispensing] [int] NULL,
[ihds_prov_id_ordering] [int] NULL,
[ihds_prov_id_prescribing] [int] NULL,
[IsMailOrder] [bit] NULL,
[MemberID] [int] NOT NULL,
[NDC] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCFormat] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyID] [int] NOT NULL,
[PrescribingProviderID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[QuantityDispensed] [decimal] (18, 6) NULL,
[RefillNumber] [smallint] NULL,
[RefillQuantity] [smallint] NULL,
[UnitOfMeasure] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplyFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsZeroedOut] [bit] NULL,
[InstanceID] [int] NULL,
[SupplementalDataFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PharmacyC__Suppl__49515770] DEFAULT ('N'),
[SupplementalDataCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVX] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PharmacyClaim] ADD CONSTRAINT [actPharmacyClaim_PK] PRIMARY KEY CLUSTERED  ([PharmacyClaimID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_actPharmacyClaim_PK] ON [dbo].[PharmacyClaim] ([PharmacyClaimID])
GO
ALTER TABLE [dbo].[PharmacyClaim] ADD CONSTRAINT [actMember_PharmacyClaim_FK1] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[PharmacyClaim] ADD CONSTRAINT [actPharmacy_PharmacyClaim_FK1] FOREIGN KEY ([PharmacyID]) REFERENCES [dbo].[Pharmacy] ([PharmacyID])
GO
ALTER TABLE [dbo].[PharmacyClaim] ADD CONSTRAINT [actProvider_PharmacyClaim_FK1] FOREIGN KEY ([PrescribingProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[PharmacyClaim] ADD CONSTRAINT [FK__PharmacyC__Healt__15702A09] FOREIGN KEY ([HealthPlanID]) REFERENCES [dbo].[HealthPlan] ([HealthPlanID])
GO
