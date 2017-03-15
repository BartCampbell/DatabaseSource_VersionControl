CREATE TABLE [dbo].[FTPProviderPortalConfig]
(
[FTPConfigID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTPPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchivePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncomingPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreqID] [int] NULL,
[EmailNotification] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL,
[CreateDirectory] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPProviderPortalConfig] ADD CONSTRAINT [PK_FTPProviderPortalConfig] PRIMARY KEY CLUSTERED  ([FTPConfigID]) ON [PRIMARY]
GO
