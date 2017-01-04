CREATE TABLE [dbo].[ClientPlanMap]
(
[ClientPlanMapID] [int] NOT NULL,
[Process] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientID] [int] NOT NULL,
[PlanNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
