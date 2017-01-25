CREATE TABLE [Claim].[ClaimLines]
(
[BeginDate] [datetime] NOT NULL,
[ClaimID] [int] NULL,
[ClaimLineItemID] [int] NULL,
[ClaimNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimSrcTypeID] [tinyint] NOT NULL CONSTRAINT [DF_ClaimLines_ClaimSrcTypeID] DEFAULT ((0)),
[ClaimTypeID] [tinyint] NOT NULL,
[CPT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL CONSTRAINT [DF__ClaimLine__DataS__170207DC] DEFAULT ((-1)),
[Days] [int] NULL,
[DaysPaid] [int] NULL,
[DischargeStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NOT NULL IDENTITY(1, 1),
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[HasValidCodes] [bit] NOT NULL CONSTRAINT [DF_ClaimLines_HasValidCodes] DEFAULT ((1)),
[HCPCS] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [bit] NOT NULL CONSTRAINT [DF_ClaimLines_IsPaid] DEFAULT ((0)),
[IsPositive] [bit] NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_ClaimLines_IsSupplemental] DEFAULT ((0)),
[LabValue] [decimal] (18, 6) NULL,
[LOINC] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDC] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[QtyDispensed] [decimal] (18, 6) NULL,
[Rev] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServDate] [datetime] NOT NULL,
[TOB] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [CLM2]
GO
ALTER TABLE [Claim].[ClaimLines] ADD CONSTRAINT [PK_ClaimLines] PRIMARY KEY CLUSTERED  ([DSClaimLineID]) ON [CLM2]
GO
CREATE NONCLUSTERED INDEX [IX_ClaimLines_DSClaimID] ON [Claim].[ClaimLines] ([DSClaimID]) ON [IDX4]
GO
CREATE NONCLUSTERED INDEX [IX_ClaimLines_DSMemberID] ON [Claim].[ClaimLines] ([DSMemberID], [DataSetID]) INCLUDE ([BeginDate], [EndDate], [ServDate]) ON [IDX4]
GO
