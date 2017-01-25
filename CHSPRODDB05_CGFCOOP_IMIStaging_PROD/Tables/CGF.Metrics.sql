CREATE TABLE [CGF].[Metrics]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefID] [int] NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL,
[MetricXrefID] [int] NOT NULL,
[MeasureXrefGuid] [uniqueidentifier] NOT NULL,
[Metric] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsShown] [int] NOT NULL,
[ScoreTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics_Metric] ON [CGF].[Metrics] ([Metric]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics] ON [CGF].[Metrics] ([MetricXrefGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_Metrics_Metric] ON [CGF].[Metrics] ([Metric])
GO
CREATE STATISTICS [spIX_Metrics] ON [CGF].[Metrics] ([MetricXrefGuid])
GO
