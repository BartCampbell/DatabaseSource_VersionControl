CREATE TABLE [Report].[MeansAndPercentiles]
(
[AgeBandID] [int] NULL,
[AgeBandSegID] [int] NULL,
[FieldID] [int] NULL,
[IdssColumnID] [int] NULL,
[IdssMeanPercentID] [int] NOT NULL,
[IdssYear] [smallint] NOT NULL,
[Mean] [decimal] (18, 6) NULL,
[MeanPercentGuid] [uniqueidentifier] NULL CONSTRAINT [DF_MeansAndPercentiles_MeanPercentGuid] DEFAULT (newid()),
[MeanPercentID] [int] NOT NULL IDENTITY(1, 1),
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NOT NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NOT NULL,
[PayerID] [smallint] NOT NULL,
[Percent05] [decimal] (22, 10) NULL,
[Percent10] [decimal] (22, 10) NULL,
[Percent25] [decimal] (22, 10) NULL,
[Percent50] [decimal] (22, 10) NULL,
[Percent75] [decimal] (22, 10) NULL,
[Percent90] [decimal] (22, 10) NULL,
[Percent95] [decimal] (22, 10) NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Report].[MeansAndPercentiles] ADD CONSTRAINT [PK_Report_MeansAndPercentiles] PRIMARY KEY CLUSTERED  ([MeanPercentID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Report_MeansAndPercentiles] ON [Report].[MeansAndPercentiles] ([MeanPercentGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Report_MeansAndPercentiles_Metrics] ON [Report].[MeansAndPercentiles] ([MetricID], [PayerID], [ProductLineID], [AgeBandSegID], [IdssColumnID], [IdssYear], [IdssMeanPercentID]) ON [PRIMARY]
GO
