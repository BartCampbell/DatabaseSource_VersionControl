CREATE TABLE [dbo].[FileLog]
(
[FileLogID] [int] NOT NULL IDENTITY(1000000, 1),
[FileConfigID] [int] NULL,
[CentauriClientID] [int] NOT NULL,
[FilePathInbound] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathArchive] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileNameInbound] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileNameArchive] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileLogDate] [datetime] NOT NULL CONSTRAINT [DF_FileLog_LogDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileLog] ADD CONSTRAINT [PK_FileLog_FileLogID] PRIMARY KEY CLUSTERED  ([FileLogID]) ON [PRIMARY]
GO
