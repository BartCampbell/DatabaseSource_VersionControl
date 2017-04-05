CREATE TABLE [etl].[FileSet]
(
[FileSetID] [int] NOT NULL IDENTITY(200000, 1),
[FileSetDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[FilePathIntakeVolume] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathIntakePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreqID] [int] NOT NULL CONSTRAINT [DF__FileSet__FreqI__2B8A53B1] DEFAULT ((0)),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__FileSet__IsAct__2E66C05C] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileSet__Creat__2F5AE495] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileSet__LastU__304F08CE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileSet] ADD CONSTRAINT [PK_FileSet_FileSetID] PRIMARY KEY CLUSTERED  ([FileSetID]) ON [PRIMARY]
GO
