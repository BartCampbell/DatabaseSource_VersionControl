CREATE TABLE [dbo].[FileConfig]
(
[FileConfigID] [int] NOT NULL IDENTITY(100000, 1),
[FileProcessID] [int] NOT NULL,
[CentauriClientID] [int] NOT NULL,
[FilePathInbound] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathStage] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathArchive] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreqID] [int] NULL,
[EmailNotification] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__FileConfi__IsAct__50C5FA01] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__Creat__51BA1E3A] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__LastU__52AE4273] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileConfig] ADD CONSTRAINT [PK_FileConfig_FileConfigID] PRIMARY KEY CLUSTERED  ([FileConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileConfig] ADD CONSTRAINT [FK_FileConfig_FileProcess] FOREIGN KEY ([FileProcessID]) REFERENCES [dbo].[FileProcess] ([FileProcessID])
GO
