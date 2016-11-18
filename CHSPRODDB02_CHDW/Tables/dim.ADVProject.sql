CREATE TABLE [dim].[ADVProject]
(
[ProjectID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[CentauriProjectID] [int] NOT NULL,
[Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScan] [bit] NULL,
[IsCode] [bit] NULL,
[Client_PK] [smallint] NULL,
[dtInsert] [datetime] NULL,
[IsProspective] [bit] NULL,
[IsRetrospective] [bit] NULL,
[IsHEDIS] [bit] NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup_PK] [int] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_Project_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_Project_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ADVProject] ADD CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED  ([ProjectID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ADVProject] ADD CONSTRAINT [FK_Project_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
