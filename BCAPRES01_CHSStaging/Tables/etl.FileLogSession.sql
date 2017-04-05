CREATE TABLE [etl].[FileLogSession]
(
[FileLogSessionID] [int] NOT NULL IDENTITY(2000000, 1),
[FileProcessID] [int] NULL,
[FileLogSessionDate] [datetime] NOT NULL CONSTRAINT [DF_FileLogSession_FileLogSessionDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLogSession] ADD CONSTRAINT [PK_FileLogSession_FileLogSessionID] PRIMARY KEY CLUSTERED  ([FileLogSessionID]) ON [PRIMARY]
GO
