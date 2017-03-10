CREATE TABLE [dbo].[MetricSampleSizeOverride]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISSubMetricID] [int] NOT NULL,
[SampleSize] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricSampleSizeOverride] ADD CONSTRAINT [PK_MetricSampleSizeOverride] PRIMARY KEY CLUSTERED  ([HEDISSubMetricID], [ProductLine], [Product]) ON [PRIMARY]
GO
