CREATE TABLE [dbo].[FTPConfig]
(
[FTPConfigID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTPPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchivePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncomingPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreqID] [int] NULL,
[EmailNotification] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL CONSTRAINT [DF_FTPConfig_IsActive] DEFAULT ((0)),
[CreateDirectory] [int] NULL CONSTRAINT [DF_FTPConfig_CreateDirectory] DEFAULT ((1)),
[ACKFile] [int] NULL CONSTRAINT [DF_FTPConfig_CreateACKFile] DEFAULT ((0)),
[AdvanceIntakeFile] [int] NULL CONSTRAINT [DF_FTPConfig_AdvanceIntakeFile] DEFAULT ((0)),
[AdvanceIntakeDumpDir] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExternal] [int] NOT NULL,
[UseSubFolder] [int] NOT NULL CONSTRAINT [DF__FTPConfig__SubFo__004002F9] DEFAULT ((0)),
[AppendName] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPConfig] ADD CONSTRAINT [PK_FTPConfig] PRIMARY KEY CLUSTERED  ([FTPConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPConfig] ADD CONSTRAINT [FK_FTPConfig_Frequency] FOREIGN KEY ([FreqID]) REFERENCES [dbo].[Frequency] ([FreqID])
GO
