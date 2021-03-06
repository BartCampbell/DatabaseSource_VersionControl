CREATE TABLE [dbo].[ClientPlanMap]
(
[ClientPlanMapID] [int] NOT NULL IDENTITY(1, 1),
[Process] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientID] [int] NOT NULL,
[PlanNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_ClientPlanMap_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_ClientPlanMap_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientPlanMap] ADD CONSTRAINT [PK_ClientPlanMap] PRIMARY KEY CLUSTERED  ([ClientPlanMapID]) ON [PRIMARY]
GO
