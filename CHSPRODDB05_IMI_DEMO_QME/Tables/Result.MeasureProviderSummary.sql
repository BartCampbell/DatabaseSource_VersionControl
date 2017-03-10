CREATE TABLE [Result].[MeasureProviderSummary]
(
[Age] [tinyint] NULL,
[AgeBandID] [int] NULL,
[AgeBandSegID] [int] NULL,
[BatchID] [int] NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_MeasureProviderSummary_BitProductLines] DEFAULT ((0)),
[ClinCondID] [int] NULL,
[CountEvents] [bigint] NULL,
[CountMembers] [bigint] NULL,
[CountRecords] [bigint] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[Days] [bigint] NULL,
[DSProviderID] [bigint] NULL,
[EnrollGroupID] [int] NULL,
[Gender] [tinyint] NULL,
[IsDenominator] [bigint] NULL,
[IsExclusion] [bigint] NULL,
[IsIndicator] [bigint] NULL,
[IsNegative] [bigint] NULL,
[IsNumerator] [bigint] NULL,
[IsNumeratorAdmin] [bigint] NULL,
[IsNumeratorMedRcd] [bigint] NULL,
[IsSupplementalDenominator] [bigint] NULL,
[IsSupplementalExclusion] [bigint] NULL,
[IsSupplementalIndicator] [bigint] NULL,
[IsSupplementalNumerator] [bigint] NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MedGrpID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[Qty] [bigint] NULL,
[Qty2] [bigint] NULL,
[Qty3] [bigint] NULL,
[Qty4] [bigint] NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureProviderSummary_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[ResultTypeID] [tinyint] NOT NULL,
[Weight] [decimal] (18, 10) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureProviderSummary] ADD CONSTRAINT [PK_MeasureProviderSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DataRunID] ON [Result].[MeasureProviderSummary] ([DataRunID]) INCLUDE ([CountEvents], [CountMembers], [CountRecords], [DataSetID], [Days], [IsDenominator], [IsExclusion], [IsNegative], [IsNumerator], [MeasureID], [MedGrpID], [MetricID], [PopulationID], [ProductLineID], [Qty], [ResultTypeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DataRunID_2] ON [Result].[MeasureProviderSummary] ([DataRunID], [DataSetID], [MeasureID], [MetricID], [PopulationID], [ProductLineID]) INCLUDE ([CountEvents], [CountMembers], [CountRecords], [Days], [IsDenominator], [IsExclusion], [IsNegative], [IsNumerator], [MedGrpID], [Qty], [ResultTypeID]) ON [PRIMARY]
GO
