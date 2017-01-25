CREATE TABLE [Batch].[DataRuns]
(
[BatchSize] [int] NOT NULL,
[BatchStatusID] [smallint] NOT NULL CONSTRAINT [DF_DataRuns_BatchStatusID] DEFAULT ((-1)),
[BeginInitSeedDate] [datetime] NOT NULL,
[BeginTime] [datetime] NOT NULL,
[CalculateMbrMonths] [bit] NOT NULL CONSTRAINT [DF_DataRuns_CalculateMbrMonths] DEFAULT ((1)),
[CalculateXml] [bit] NOT NULL CONSTRAINT [DF_DataRuns_CalculateXml] DEFAULT ((1)),
[ConfirmedDate] [datetime] NULL,
[CountBatches] [int] NULL,
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DataRuns_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DataRuns_CreatedTime] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_DataRuns_CreatedSpId] DEFAULT (@@spid),
[DataRunGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataRuns_DataRunGuid] DEFAULT (newid()),
[DataRunID] [int] NOT NULL IDENTITY(1, 1),
[DataSetID] [int] NOT NULL,
[DefaultBenefitID] [smallint] NULL,
[EndInitSeedDate] [datetime] NOT NULL,
[EndTime] [datetime] NULL,
[FileFormatID] [int] NULL,
[IsConfirmed] [bit] NOT NULL CONSTRAINT [DF_DataRuns_IsConfirmed] DEFAULT ((0)),
[IsLogged] [bit] NOT NULL CONSTRAINT [DF_DataRuns_IsLogged] DEFAULT ((1)),
[IsPurged] [bit] NOT NULL CONSTRAINT [DF_DataRuns_IsPurged] DEFAULT ((0)),
[IsReady] [bit] NULL CONSTRAINT [DF_DataRuns_IsReady] DEFAULT ((0)),
[IsSubmitted] [bit] NOT NULL CONSTRAINT [DF_DataRuns_IsSubmitted] DEFAULT ((0)),
[LastErrLogID] [int] NULL,
[LastErrLogTime] [datetime] NULL,
[LastProgLogID] [bigint] NULL,
[LastProgLogTime] [datetime] NULL,
[MeasureSetID] [int] NOT NULL,
[MbrMonthID] [smallint] NOT NULL CONSTRAINT [DF_DataRuns_MbrMonthID] DEFAULT ((1)),
[PurgedDate] [datetime] NULL,
[ReturnFileFormatID] [int] NULL,
[SeedDate] [datetime] NOT NULL,
[SourceGuid] [uniqueidentifier] NULL,
[SubmittedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataRuns] ADD CONSTRAINT [PK_DataRuns] PRIMARY KEY CLUSTERED  ([DataRunID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataRuns_DataRunGuid] ON [Batch].[DataRuns] ([DataRunGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataRuns_DataSetID] ON [Batch].[DataRuns] ([DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataRuns_SourceGuid] ON [Batch].[DataRuns] ([SourceGuid]) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataRuns] SET ( LOCK_ESCALATION = DISABLE )
GO
