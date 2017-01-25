CREATE TABLE [Measure].[Metrics]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBandID] [int] NULL,
[BenefitID] [smallint] NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_Metrics_IsEnabled] DEFAULT ((1)),
[IsInverse] [bit] NOT NULL CONSTRAINT [DF_Metrics_IsInverse] DEFAULT ((0)),
[IsParent] AS ([Measure].[IsParentMetric]([MetricID])),
[IsShown] [bit] NOT NULL CONSTRAINT [DF_Metrics_IsShown] DEFAULT ((1)),
[MeasureID] [int] NOT NULL,
[MetricGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Metrics_MetricGuid] DEFAULT (newid()),
[MetricID] [int] NOT NULL IDENTITY(1, 1),
[MetricXrefID] [int] NULL,
[ParentID] [int] NULL,
[ScoreTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[Metrics] ADD CONSTRAINT [PK_Metrics] PRIMARY KEY CLUSTERED  ([MetricID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Metrics_Abbrev] ON [Measure].[Metrics] ([Abbrev], [MeasureID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics_MeasureID] ON [Measure].[Metrics] ([MeasureID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics_MetricGuid] ON [Measure].[Metrics] ([MetricGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics_ParentID] ON [Measure].[Metrics] ([ParentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Metrics_ScoreTypeID] ON [Measure].[Metrics] ([ScoreTypeID]) ON [PRIMARY]
GO
