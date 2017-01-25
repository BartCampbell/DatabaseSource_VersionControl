CREATE TABLE [Result].[DataSetMetricKey]
(
[AgeBandSegDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBandSegID] [int] NULL,
[BenefitDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BenefitID] [smallint] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[FromAgeTotMonths] [int] NULL,
[FromAgeYears] [smallint] NULL,
[Gender] [tinyint] NULL,
[IsHybrid] [bit] NULL CONSTRAINT [DF_DataSetMetricKey_HasHybrid] DEFAULT ((0)),
[IsParent] [bit] NOT NULL CONSTRAINT [DF_DataSetMetricKey_IsParent] DEFAULT ((0)),
[MeasClassDescr] [varchar] (130) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasClassID] [smallint] NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureGuid] [uniqueidentifier] NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricGuid] [uniqueidentifier] NULL,
[MetricID] [int] NOT NULL,
[MetricKeyID] [int] NOT NULL IDENTITY(1, 1),
[MetricXrefID] [int] NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[SubMeasClassDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubMeasClassID] [smallint] NULL,
[ToAgeTotMonths] [int] NULL,
[ToAgeYears] [smallint] NULL,
[TopMeasClassDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopMeasClassID] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMetricKey] ADD CONSTRAINT [PK_DataSetMetricKey] PRIMARY KEY CLUSTERED  ([MetricKeyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataSetMetricKey] ON [Result].[DataSetMetricKey] ([MetricID], [AgeBandSegID], [PopulationID], [DataRunID], [ProductLineID]) ON [PRIMARY]
GO
