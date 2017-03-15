CREATE TABLE [dbo].[FTPInboundAuditLog]
(
[AuditLogID] [int] NOT NULL IDENTITY(1, 1),
[FTPConfigID] [int] NULL,
[FTPPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchivePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncomingPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL CONSTRAINT [DF_FTPAuditLog_LogDate] DEFAULT (getdate()),
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPInboundAuditLog] ADD CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED  ([AuditLogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FTPConfigIDFilename] ON [dbo].[FTPInboundAuditLog] ([FTPConfigID]) INCLUDE ([FileName]) ON [PRIMARY]
GO
