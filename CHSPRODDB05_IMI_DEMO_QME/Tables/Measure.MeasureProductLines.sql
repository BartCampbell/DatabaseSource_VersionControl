CREATE TABLE [Measure].[MeasureProductLines]
(
[MeasureID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MeasureProductLines] ADD CONSTRAINT [PK_MeasureProductLines] PRIMARY KEY CLUSTERED  ([MeasureID], [ProductLineID]) ON [PRIMARY]
GO
