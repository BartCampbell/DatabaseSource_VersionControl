CREATE TABLE [dbo].[ChartsToCode_withImages]
(
[CHART_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartID] ON [dbo].[ChartsToCode_withImages] ([CHART_ID]) ON [PRIMARY]
GO
