CREATE TABLE [Result].[MeasureDetail]
(
[Age] [tinyint] NULL,
[AgeMonths] [smallint] NULL,
[AgeBandID] [int] NULL,
[AgeBandSegID] [int] NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_BitProductLines] DEFAULT ((0)),
[ClinCondID] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL CONSTRAINT [DF_MeasureDetail_DataSourceID] DEFAULT ((-1)),
[Days] [smallint] NULL,
[DSEntityID] [bigint] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EnrollGroupID] [int] NULL,
[EntityID] [int] NULL,
[ExclusionTypeID] [tinyint] NULL,
[Gender] [tinyint] NULL,
[IsDenominator] [bit] NULL,
[IsExclusion] [bit] NULL,
[IsIndicator] [bit] NULL,
[IsNumerator] [bit] NULL,
[IsNumeratorAdmin] [bit] NULL,
[IsNumeratorMedRcd] [bit] NULL,
[IsSupplementalDenominator] [bit] NULL,
[IsSupplementalExclusion] [bit] NULL,
[IsSupplementalIndicator] [bit] NULL,
[IsSupplementalNumerator] [bit] NULL,
[KeyDate] [datetime] NOT NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL CONSTRAINT [DF_MeasureDetail_ProductLineID] DEFAULT ((0)),
[Qty] [int] NULL,
[Qty2] [int] NULL,
[Qty3] [int] NULL,
[Qty4] [int] NULL,
[ResultInfo] [xml] NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[ResultTypeID] [tinyint] NOT NULL,
[SourceDenominator] [bigint] NULL,
[SourceDenominatorSrc] [int] NULL,
[SourceExclusion] [bigint] NULL,
[SourceExclusionSrc] [int] NULL,
[SourceIndicator] [bigint] NULL,
[SourceIndicatorSrc] [int] NULL,
[SourceNumerator] [bigint] NULL,
[SourceNumeratorSrc] [int] NULL,
[SysSampleRefID] [bigint] NULL,
[Weight] [decimal] (18, 10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail] ADD CONSTRAINT [PK_MeasureDetail] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MeasureDetail_BatchID] ON [Result].[MeasureDetail] ([BatchID], [DataRunID], [DataSetID]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MeasureDetail_AgeBands] ON [Result].[MeasureDetail] ([DataRunID], [Age], [Gender]) INCLUDE ([DataSetID], [DSMemberID], [MeasureID], [MetricID], [PopulationID], [ProductLineID]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MeasureDetail] ON [Result].[MeasureDetail] ([DataRunID], [DSMemberID], [PopulationID], [BitProductLines], [ResultTypeID], [MetricID], [MeasureID]) INCLUDE ([DataSetID], [Days], [IsDenominator], [Qty]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureDetail_ResultRowGuid] ON [Result].[MeasureDetail] ([ResultRowGuid]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
