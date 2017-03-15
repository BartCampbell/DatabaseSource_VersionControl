CREATE TABLE [dbo].[FileProcess]
(
[FileProcessID] [int] NOT NULL IDENTITY(100000, 1),
[FileProcessName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileProcessDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__FileProce__IsAct__314D4EA8] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileProce__Creat__324172E1] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileProce__LastU__3335971A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcess] ADD CONSTRAINT [PK_FileProcess_FileProcessID] PRIMARY KEY CLUSTERED  ([FileProcessID]) ON [PRIMARY]
GO
