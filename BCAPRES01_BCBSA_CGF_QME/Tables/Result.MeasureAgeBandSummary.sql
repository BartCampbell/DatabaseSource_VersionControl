CREATE TABLE [Result].[MeasureAgeBandSummary]
(
[AgeBandID] [int] NOT NULL,
[AgeBandSegID] [int] NOT NULL,
[BenefitID] [int] NOT NULL,
[CountEvents] [int] NOT NULL,
[CountMembers] [int] NOT NULL,
[CountMonths] [int] NOT NULL,
[CountRecords] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[Days] [bigint] NOT NULL,
[Gender] [tinyint] NULL,
[IsDenominator] [bigint] NOT NULL,
[IsExclusion] [bigint] NOT NULL,
[IsIndicator] [bigint] NOT NULL,
[IsNegative] [bigint] NOT NULL,
[IsNumerator] [bigint] NOT NULL,
[IsNumeratorAdmin] [bigint] NOT NULL,
[IsNumeratorMedRcd] [bigint] NOT NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[Qty] [int] NOT NULL,
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[ResultTypeID] [tinyint] NOT NULL,
[Weight] [decimal] (38, 10) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureAgeBandSummary] ADD CONSTRAINT [PK_MeasureAgeBandSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureAgeBandSummary] ON [Result].[MeasureAgeBandSummary] ([DataRunID], [ProductLineID], [PopulationID], [ResultTypeID], [MeasureID], [MetricID], [BenefitID], [AgeBandID], [AgeBandSegID]) ON [PRIMARY]
GO
