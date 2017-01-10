CREATE TABLE [dbo].[tmpExportChases]
(
[Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member_PK] [int] NULL,
[Suspect_PK] [bigint] NOT NULL,
[CHART NAME] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ChaseID] [bigint] NULL,
[InDummy] [int] NULL,
[InNormal] [int] NULL,
[QuickRAPSDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
