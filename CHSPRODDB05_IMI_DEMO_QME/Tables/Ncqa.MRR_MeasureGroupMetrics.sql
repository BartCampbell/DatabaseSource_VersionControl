CREATE TABLE [Ncqa].[MRR_MeasureGroupMetrics]
(
[MeasureGroup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Metric] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MRR_MeasureGroupMetrics] ADD CONSTRAINT [PK_MRR_MeasureGroupMetrics] PRIMARY KEY CLUSTERED  ([MeasureGroup], [Metric]) ON [PRIMARY]
GO
