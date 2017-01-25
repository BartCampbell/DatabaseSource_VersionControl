CREATE TABLE [Result].[MetricMonthSummary]
(
[AgeBandID] [int] NULL,
[AgeBandSegID] [int] NULL,
[BenefitID] [smallint] NOT NULL,
[CountMembers] [bigint] NULL,
[CountMonths] [bigint] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollGroupID] [int] NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PayerID] [smallint] NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MetricMonthSummary_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MetricMonthSummary] ADD CONSTRAINT [PK_Result_MetricMonthSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MetricMonthSummary] ON [Result].[MetricMonthSummary] ([DataRunID], [EnrollGroupID], [MetricID], [PayerID], [PopulationID], [ProductLineID], [AgeBandSegID]) ON [PRIMARY]
GO
