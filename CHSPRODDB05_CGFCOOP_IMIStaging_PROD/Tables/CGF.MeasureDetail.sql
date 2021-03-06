CREATE TABLE [CGF].[MeasureDetail]
(
[Age] [tinyint] NULL,
[AgeMonths] [smallint] NULL,
[AgeBandID] [int] NULL,
[AgeBandSegID] [int] NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NULL,
[BitProductLines] [bigint] NOT NULL,
[ClinCondID] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
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
[KeyDate] [datetime] NOT NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[Qty] [int] NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL,
[ResultRowID] [bigint] NOT NULL,
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
[Weight] [numeric] (18, 10) NULL
) ON [PRIMARY]
GO
