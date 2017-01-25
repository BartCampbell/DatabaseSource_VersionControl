CREATE TABLE [Result].[DataSetMetricAgeBandKey]
(
[AgeBandSegDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBandSegID] [int] NULL,
[BenefitDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BenefitID] [smallint] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[Gender] [tinyint] NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricAgeBandKeyID] [int] NOT NULL IDENTITY(1, 1),
[MetricDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMetricAgeBandKey] ADD CONSTRAINT [PK_DataSetMetricAgeBandKey] PRIMARY KEY CLUSTERED  ([MetricAgeBandKeyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataSetMetricAgeBandKey] ON [Result].[DataSetMetricAgeBandKey] ([DataRunID], [MetricID], [ProductLineID], [PopulationID], [AgeBandSegID], [Gender]) ON [PRIMARY]
GO
