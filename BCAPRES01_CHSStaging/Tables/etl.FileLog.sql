CREATE TABLE [etl].[FileLog]
(
[FileLogID] [int] NOT NULL IDENTITY(1000000, 1),
[FileConfigID] [int] NULL,
[CentauriClientID] [int] NULL,
[FTPLogID] [int] NULL,
[FTPReceivedDate] [datetime] NULL,
[FilePathIntake] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileNameIntake] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileLogDate] [datetime] NOT NULL CONSTRAINT [DF_FileLog_LogDate_02] DEFAULT (getdate()),
[FileSize] [bigint] NULL,
[FileThread] [int] NULL,
[FileThreadPriority] [int] NULL,
[RowCntExp] [int] NULL,
[RowCntFile] [int] NULL,
[RowCntImport] [int] NULL,
[RowCntRDSM] [int] NULL,
[RowCntDV] [int] NULL,
[DateFile] [datetime] NULL,
[FileLogSessionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLog] ADD CONSTRAINT [PK_FileLog_FileLogID_02] PRIMARY KEY CLUSTERED  ([FileLogID]) ON [PRIMARY]
GO
