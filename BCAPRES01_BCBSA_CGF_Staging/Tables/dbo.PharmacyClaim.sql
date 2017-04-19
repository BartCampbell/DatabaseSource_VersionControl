CREATE TABLE [dbo].[PharmacyClaim]
(
[PharmacyClaimID] [int] NOT NULL IDENTITY(1, 1),
[ClaimNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimSequenceNumber] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateDispensed] [datetime] NULL,
[DateOrdered] [datetime] NULL,
[DateRowCreated] [datetime] NULL,
[DaysSupply] [smallint] NULL,
[DrugTherapeuticClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[RowFileID] [bigint] NULL,
[MemberAge] [numeric] (5, 1) NULL,
[MemberID] [int] NULL,
[NDC] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [int] NULL,
[QuantityDispensed_Submitted] [decimal] (11, 3) NULL,
[QuantityPaid] [decimal] (11, 3) NULL,
[RefillNumber] [smallint] NULL,
[RowID] [int] NULL,
[QuantityDispensed] [decimal] (18, 6) NULL,
[CustomerProviderID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerPrescribingID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
