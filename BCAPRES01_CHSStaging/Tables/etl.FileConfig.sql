CREATE TABLE [etl].[FileConfig]
(
[FileConfigID] [int] NOT NULL IDENTITY(200000, 1),
[FileProcessID] [int] NOT NULL CONSTRAINT [DF__FileConfi__FileP__29A20B3F] DEFAULT ((0)),
[CentauriClientID] [int] NOT NULL,
[FilePathIntakeVolume] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePathIntakePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileNamePattern] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowDups] [int] NOT NULL CONSTRAINT [DF__FileConfi__Allow__2A962F78] DEFAULT ((0)),
[FreqID] [int] NOT NULL CONSTRAINT [DF__FileConfi__FreqI__2B8A53B1] DEFAULT ((0)),
[SQLDestServer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLDestTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailNotification] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmColCount] [int] NULL,
[BcpParmFieldTerminator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmRowTerminator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BcpParmIsTabDelimited] [int] NULL,
[BcpParmIsFixedWidth] [int] NULL,
[BcpParmRemoveTextQuotes] [int] NULL,
[HasHeader] [int] NOT NULL CONSTRAINT [DF__FileConfi__HasHe__2C7E77EA] DEFAULT ((0)),
[HasFooter] [int] NOT NULL CONSTRAINT [DF__FileConfi__HasFo__2D729C23] DEFAULT ((0)),
[RowsToSkip] [int] NULL,
[IMIClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__FileConfi__IsAct__2E66C05C] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__Creat__2F5AE495] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__LastU__304F08CE] DEFAULT (getdate()),
[RDSMTruncTarget] [int] NOT NULL CONSTRAINT [DF_FileConfig_RDSMTruncTarget] DEFAULT ((0)),
[FileActionCd] [int] NOT NULL CONSTRAINT [DF_FileConfig_FileActionCd] DEFAULT ((1)),
[SQLDestDVLoadSP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSetID] [int] NULL,
[SQLDestTableColIgnoreListConfig] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [etl].[FileConfig] ADD CONSTRAINT [PK_FileConfig_FileConfigID] PRIMARY KEY CLUSTERED  ([FileConfigID]) ON [PRIMARY]
GO
