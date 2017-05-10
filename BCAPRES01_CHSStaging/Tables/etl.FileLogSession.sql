CREATE TABLE [etl].[FileLogSession]
(
[FileLogSessionID] [int] NOT NULL IDENTITY(2000000, 1),
[FileProcessID] [int] NULL,
[FileLogSessionDate] [datetime] NOT NULL CONSTRAINT [DF_FileLogSessionNew_FileLogSessionDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLogSession] ADD CONSTRAINT [PK_FileLogSessionNew_FileLogSessionID] PRIMARY KEY CLUSTERED  ([FileLogSessionID]) ON [PRIMARY]
GO
