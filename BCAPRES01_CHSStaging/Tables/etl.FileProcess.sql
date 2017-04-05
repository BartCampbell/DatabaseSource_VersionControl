CREATE TABLE [etl].[FileProcess]
(
[FileProcessID] [int] NOT NULL,
[SQLDestTableColIgnoreListProcess] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_FileProcess_IsActive] DEFAULT ((1)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_FileProcess_CreateDate] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF_FileProcess_LastUpdated] DEFAULT (getdate()),
[FileProcessDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileProcess] ADD CONSTRAINT [PK_FileProcess_FileProcessID] PRIMARY KEY CLUSTERED  ([FileProcessID]) ON [PRIMARY]
GO
