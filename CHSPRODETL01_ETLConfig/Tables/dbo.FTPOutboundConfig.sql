CREATE TABLE [dbo].[FTPOutboundConfig]
(
[FTPOutboundID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropOffDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTPDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL CONSTRAINT [DF_FTPOutboundConfig_IsActive] DEFAULT ((1)),
[SuccessEmailTo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExternal] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPOutboundConfig] ADD CONSTRAINT [PK_FTPOutboundConfig] PRIMARY KEY CLUSTERED  ([FTPOutboundID]) ON [PRIMARY]
GO
