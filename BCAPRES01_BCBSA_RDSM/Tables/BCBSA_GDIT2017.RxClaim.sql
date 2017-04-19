CREATE TABLE [BCBSA_GDIT2017].[RxClaim]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowFileID] [int] NULL,
[JobRunTaskFileID] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[SourceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimLineNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Denied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EpisodeOfIllness] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispensingProv] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispenseDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrescribingProv] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrescribedDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefillCount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricQuantity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuantityDispensed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplyDays] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RxClaimCount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowedAmt] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassCategoryCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSourceType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuditorApprovedInd] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [BCBSA_GDIT2017_RxClaim]
GO
CREATE NONCLUSTERED INDEX [idxRxClaim] ON [BCBSA_GDIT2017].[RxClaim] ([ClaimNumber], [ClaimLineNumber], [MemberID]) ON [BCBSA_GDIT2017_RxClaim_IDX]
GO
CREATE CLUSTERED INDEX [clidxRxClaim] ON [BCBSA_GDIT2017].[RxClaim] ([RowID]) ON [BCBSA_GDIT2017_RxClaim]
GO
CREATE STATISTICS [spidxRxClaim] ON [BCBSA_GDIT2017].[RxClaim] ([ClaimNumber], [ClaimLineNumber], [MemberID])
GO
CREATE STATISTICS [spclidxRxClaim] ON [BCBSA_GDIT2017].[RxClaim] ([RowID])
GO
