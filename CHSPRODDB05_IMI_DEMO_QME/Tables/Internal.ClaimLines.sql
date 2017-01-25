CREATE TABLE [Internal].[ClaimLines]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[ClaimID] [int] NULL,
[ClaimLineItemID] [int] NULL,
[ClaimNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimSrcTypeID] [tinyint] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[CPT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTMod3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[Days] [int] NULL,
[DaysPaid] [int] NULL,
[DischargeStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[HCPCS] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [bit] NOT NULL CONSTRAINT [DF_Temp_ClaimLines_IsPaid] DEFAULT ((0)),
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
[SpId] [int] NOT NULL CONSTRAINT [DF_ClaimLines_SpId] DEFAULT (@@spid),
[TOB] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[ClaimLines] ADD CONSTRAINT [PK_Internal_ClaimLines] PRIMARY KEY CLUSTERED  ([DSClaimLineID], [SpId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_ClaimLines_DSClaimID] ON [Internal].[ClaimLines] ([SpId], [DSClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_ClaimLines_MemberDates] ON [Internal].[ClaimLines] ([SpId], [DSMemberID], [EndDate], [BeginDate]) ON [PRIMARY]
GO
