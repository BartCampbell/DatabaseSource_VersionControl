CREATE TABLE [dbo].[MeasureComponentMetrics]
(
[HEDISSubMetricID] [int] NOT NULL,
[MeasureComponentID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponentMetrics] ADD CONSTRAINT [PK_MeasureComponentMetrics] PRIMARY KEY CLUSTERED  ([HEDISSubMetricID], [MeasureComponentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponentMetrics] ADD CONSTRAINT [FK_MeasureComponentMetrics_HEDISSubMetric] FOREIGN KEY ([HEDISSubMetricID]) REFERENCES [dbo].[HEDISSubMetric] ([HEDISSubMetricID])
GO
ALTER TABLE [dbo].[MeasureComponentMetrics] WITH NOCHECK ADD CONSTRAINT [FK_MeasureComponentMetrics_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
