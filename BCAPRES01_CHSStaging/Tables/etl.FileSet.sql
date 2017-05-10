CREATE TABLE [etl].[FileSet]
(
[FileSetID] [int] NOT NULL IDENTITY(100000, 1),
[FileSetDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[FilePathIntakeVolume] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathIntakePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreqID] [int] NOT NULL CONSTRAINT [df_FileSet_FreqID_01] DEFAULT ((0)),
[ThreadCnt] [int] NOT NULL CONSTRAINT [df_FileSet_ThreadCnt_01] DEFAULT ((10)),
[IsActive] [bit] NOT NULL CONSTRAINT [df_FileSet_IsActive_01] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [df_FileSet_CreateDate_01] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [df_FileSet_LastUpdated_01] DEFAULT (getdate()),
[FileConfigIDPrimary] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileSet] ADD CONSTRAINT [PK_FileSet_FileSetID_01] PRIMARY KEY CLUSTERED  ([FileSetID]) ON [PRIMARY]
GO
