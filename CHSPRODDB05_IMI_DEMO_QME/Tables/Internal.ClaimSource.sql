CREATE TABLE [Internal].[ClaimSource]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BitClaimAttribs] [bigint] NOT NULL,
[BitClaimSrcTypes] [bigint] NOT NULL,
[BitSpecialties] [bigint] NOT NULL,
[ClaimBeginDate] [datetime] NULL,
[ClaimCompareDate] [datetime] NULL,
[ClaimEndDate] [datetime] NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NOT NULL,
[CodeTypeID] [tinyint] NOT NULL,
[CompareDate] [datetime] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[Days] [int] NULL,
[DaysPaid] [int] NULL,
[DOB] [datetime] NULL,
[DSClaimCodeID] [bigint] NOT NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[Gender] [tinyint] NOT NULL,
[IsEnrolled] [bit] NOT NULL,
[IsLab] [bit] NOT NULL,
[IsOnly] [bit] NOT NULL,
[IsPaid] [bit] NOT NULL,
[IsPositive] [bit] NULL,
[IsPrimary] [bit] NOT NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_ClaimSource_IsSupplemental] DEFAULT ((0)),
[LabValue] [decimal] (18, 6) NULL,
[Qty] [int] NULL,
[QtyDispensed] [decimal] (18, 6) NULL,
[ServDate] [datetime] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_ClaimSource_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[ClaimSource] ADD CONSTRAINT [PK_Internal_ClaimSource] PRIMARY KEY CLUSTERED  ([SpId], [DSClaimCodeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_ClaimSource_CodeID] ON [Internal].[ClaimSource] ([SpId], [CodeID], [BitSpecialties]) INCLUDE ([BitClaimAttribs], [BitClaimSrcTypes], [ClaimCompareDate], [CompareDate], [DSClaimID], [DSClaimLineID], [DSMemberID], [DSProviderID]) ON [PRIMARY]
GO
