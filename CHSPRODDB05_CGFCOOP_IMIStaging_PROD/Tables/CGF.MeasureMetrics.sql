CREATE TABLE [CGF].[MeasureMetrics]
(
[MeasureXrefGuid] [uniqueidentifier] NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureDesc] [varchar] (145) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureMetricDesc] [varchar] (145) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
