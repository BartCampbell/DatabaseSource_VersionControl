CREATE TABLE [dbo].[tmpExportChartStaging]
(
[Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_PK] [int] NULL,
[Suspect_PK] [bigint] NULL,
[CHART NAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InDummy] [int] NULL,
[InNormal] [int] NULL
) ON [PRIMARY]
GO
