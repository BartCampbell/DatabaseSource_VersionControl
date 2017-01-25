CREATE TABLE [dbo].[HEDISSubMetric]
(
[HEDISSubMetricID] [int] NOT NULL IDENTITY(1, 1),
[HEDISSubMetricCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISSubMetricDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISMeasureInit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NULL,
[DisplayName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortOrder] [int] NOT NULL CONSTRAINT [DF_HEDISSubMetric_SortOrder] DEFAULT ((0)),
[DisplayInScoringPanel] [bit] NOT NULL CONSTRAINT [DF_HEDISSubMetric_DisplayInScoringPanel] DEFAULT ((1)),
[MeasureComponentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HEDISSubMetric] ADD CONSTRAINT [PK_HEDISSubMetric] PRIMARY KEY CLUSTERED  ([HEDISSubMetricID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HEDISSubMetric] ADD CONSTRAINT [FK_HEDISSubMetric_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureID])
GO
