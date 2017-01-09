CREATE TABLE [dbo].[Wellcare_ChartsToCode_20170106]
(
[CHART_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartID] ON [dbo].[Wellcare_ChartsToCode_20170106] ([CHART_ID]) ON [PRIMARY]
GO
