CREATE TABLE [dbo].[CentauriClient]
(
[CentauriClientID] [int] NOT NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientDesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagingTargetServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagingTargetDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DVTagetServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DVTargetDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DWTagetServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DWTagetDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NOT NULL,
[ClientHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__CentauriC__IsAct__090A5324] DEFAULT ((1)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__CentauriC__Creat__09FE775D] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__CentauriC__LastU__0AF29B96] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CentauriClient] ADD CONSTRAINT [PK_R_Client] PRIMARY KEY CLUSTERED  ([CentauriClientID]) ON [PRIMARY]
GO
