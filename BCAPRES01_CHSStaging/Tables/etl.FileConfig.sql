CREATE TABLE [etl].[FileConfig]
(
[FileConfigID] [int] NOT NULL IDENTITY(100000, 1),
[FileProcessID] [int] NOT NULL CONSTRAINT [df_FileConfig_FileProcessID_01] DEFAULT ((0)),
[FileSetID] [int] NULL,
[CentauriClientID] [int] NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [df_FileConfig_IsActive_01] DEFAULT ((0)),
[FilePriority] [int] NULL CONSTRAINT [df_FileConfig_FilePriority_01] DEFAULT ((0)),
[FileActionCd] [int] NOT NULL CONSTRAINT [df_FileConfig_FileActionCd_01] DEFAULT ((1)),
[FilePathIntakeVolume] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilePathIntakePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileNamePattern] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowDups] [int] NOT NULL CONSTRAINT [df_FileConfig_AllowDups_01] DEFAULT ((0)),
[FreqID] [int] NOT NULL CONSTRAINT [df_FileConfig_FreqID_01] DEFAULT ((0)),
[SQLDestServer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestDVLoadSP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestTrunc] [int] NOT NULL CONSTRAINT [df_FileConfig_SQLDestTrunc_01] DEFAULT ((0)),
[SQLDestTableColIgnoreListConfig] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmColCount] [int] NULL,
[BcpParmFieldTerminator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmRowTerminator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmIsTabDelimited] [int] NULL,
[BcpParmIsFixedWidth] [int] NULL,
[BcpParmRemoveTextQuotes] [int] NULL,
[HasHeader] [int] NOT NULL CONSTRAINT [df_FileConfig_HasHeader_01] DEFAULT ((0)),
[HasFooter] [int] NOT NULL CONSTRAINT [df_FileConfig_HasFooter_01] DEFAULT ((0)),
[RowsToSkip] [int] NULL,
[EmailNotification] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMIClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [df_FileConfig_CreateDate_01] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [df_FileConfig_LastUpdated_01] DEFAULT (getdate()),
[ValidationSkip] [int] NOT NULL CONSTRAINT [DF_FileConfig_ValidationSkip] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileConfig] ADD CONSTRAINT [PK_FileConfig_FileConfigID_01] PRIMARY KEY CLUSTERED  ([FileConfigID]) ON [PRIMARY]
GO
