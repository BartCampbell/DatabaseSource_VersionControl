CREATE TABLE [Result].[DataSetRunKey]
(
[AllowAutoRefresh] [bit] NOT NULL CONSTRAINT [DF_DataSetRunKey_AllowAutoRefresh] DEFAULT ((0)),
[AuditRand] [decimal] (18, 6) NOT NULL CONSTRAINT [DF_DataSetRunKey_AuditRand] DEFAULT (round(rand(checksum(newid())),(2))),
[BeginInitSeedDate] [datetime] NULL,
[CreatedDate] [datetime] NULL,
[DataRunDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EndInitSeedDate] [datetime] NULL,
[IsLockedDenominator] [bit] NOT NULL CONSTRAINT [DF_DataSetRunKey_IsLockedDenominator] DEFAULT ((0)),
[IsShown] [bit] NOT NULL CONSTRAINT [DF_DataSetRunKey_IsShown] DEFAULT ((0)),
[IsVerified] [bit] NOT NULL CONSTRAINT [DF_DataSetRunKey_IsVerified] DEFAULT ((0)),
[LastChartNetExportDate] [datetime] NULL,
[LastChartNetImportDate] [datetime] NULL,
[LockSrcDataRunID] [int] NULL,
[MeasureSetDefaultSeedDate] [datetime] NULL,
[MeasureSetDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NULL,
[OwnerID] [int] NOT NULL,
[OwnerDescr] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeedDate] [datetime] NULL,
[SourceGuid] [uniqueidentifier] NULL,
[VerifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetRunKey] ADD CONSTRAINT [PK_DataSetRunKey] PRIMARY KEY CLUSTERED  ([DataRunID]) ON [PRIMARY]
GO
