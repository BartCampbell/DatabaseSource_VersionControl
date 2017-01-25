CREATE TABLE [CGF].[DataRuns]
(
[BeginSeedDate] [datetime] NOT NULL,
[BatchSize] [int] NOT NULL,
[BatchStatusID] [smallint] NOT NULL,
[BeginInitSeedDate] [datetime] NOT NULL,
[BeginTime] [datetime] NOT NULL,
[CalculateMbrMonths] [bit] NOT NULL,
[ConfirmedDate] [datetime] NULL,
[CountBatches] [int] NULL,
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedSpId] [int] NOT NULL,
[DataRunGuid] [uniqueidentifier] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DefaultBenefitID] [smallint] NULL,
[EndInitSeedDate] [datetime] NOT NULL,
[EndTime] [datetime] NULL,
[FileFormatID] [int] NULL,
[IsConfirmed] [bit] NOT NULL,
[IsLogged] [bit] NOT NULL,
[IsReady] [bit] NULL,
[IsSubmitted] [bit] NOT NULL,
[LastErrLogID] [int] NULL,
[LastErrLogTime] [datetime] NULL,
[LastProgLogID] [bigint] NULL,
[LastProgLogTime] [datetime] NULL,
[MeasureSetID] [int] NOT NULL,
[MbrMonthID] [smallint] NOT NULL,
[ReturnFileFormatID] [int] NULL,
[SeedDate] [datetime] NOT NULL,
[SourceGuid] [uniqueidentifier] NULL,
[SubmittedDate] [datetime] NULL,
[DataSetGuid] [uniqueidentifier] NOT NULL,
[EndSeedDate] [datetime] NOT NULL,
[MeasureSet] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberMonths] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataRuns] ON [CGF].[DataRuns] ([DataRunGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_DataRuns] ON [CGF].[DataRuns] ([DataRunGuid])
GO
