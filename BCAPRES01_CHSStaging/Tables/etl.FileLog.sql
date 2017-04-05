CREATE TABLE [etl].[FileLog]
(
[FileLogID] [int] NOT NULL IDENTITY(2000000, 1),
[FileConfigID] [int] NULL,
[CentauriClientID] [int] NULL,
[FilePathIntake] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileNameIntake] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathArchive] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileNameArchive] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileLogDate] [datetime] NOT NULL CONSTRAINT [DF_FileLog_LogDate] DEFAULT (getdate()),
[RowCntExp] [int] NULL,
[RowCntFile] [int] NULL,
[RowCntImport] [int] NULL,
[RowCntRDSM] [int] NULL,
[RowCntDV] [int] NULL,
[DateFile] [datetime] NULL,
[FileLogSessionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLog] ADD CONSTRAINT [PK_FileLog_FileLogID] PRIMARY KEY CLUSTERED  ([FileLogID]) ON [PRIMARY]
GO
