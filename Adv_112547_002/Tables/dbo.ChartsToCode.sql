CREATE TABLE [dbo].[ChartsToCode]
(
[CHART_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBR_LAST_NAME] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBR_FIRST_NAME] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseList] [int] NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartID] ON [dbo].[ChartsToCode] ([CHART_ID]) ON [PRIMARY]
GO
