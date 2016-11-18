CREATE TABLE [dim].[OECProject]
(
[OECProjectID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NOT NULL,
[CentauriOECProjectID] [int] NOT NULL,
[ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Table_1_CreateDAte] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_OECProject_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[OECProject] ADD CONSTRAINT [PK_OECProject] PRIMARY KEY CLUSTERED  ([OECProjectID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[OECProject] ADD CONSTRAINT [FK_OECProject_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
