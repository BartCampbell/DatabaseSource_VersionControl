CREATE TABLE [dbo].[FTPOutboundAuditLog]
(
[FTPOutboundAuditID] [int] NOT NULL IDENTITY(1, 1),
[FTPOutboundConfigID] [int] NULL,
[SourceDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTPDirectory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL CONSTRAINT [DF_FTPOutboundAuditLog_LogDate] DEFAULT (getdate()),
[IsDeletedFromFTP] [bit] NULL CONSTRAINT [DF_FTPOutboundAuditLog_DeletedFromFTP] DEFAULT ((0)),
[DeletedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPOutboundAuditLog] ADD CONSTRAINT [PK_FTPOutboundAuditLog] PRIMARY KEY CLUSTERED  ([FTPOutboundAuditID]) ON [PRIMARY]
GO
