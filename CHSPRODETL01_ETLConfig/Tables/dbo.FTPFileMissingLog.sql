CREATE TABLE [dbo].[FTPFileMissingLog]
(
[FTPFileMissingLogID] [int] NOT NULL IDENTITY(1, 1),
[FTPFileMissingConfigID] [int] NULL,
[LastReceived_AuditLogID] [int] NULL,
[CurrentDate] [date] NULL,
[FreqID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPFileMissingLog] ADD CONSTRAINT [PK_FTPFileIntakeTrackerLogID] PRIMARY KEY CLUSTERED  ([FTPFileMissingLogID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPFileMissingLog] ADD CONSTRAINT [FK_FTPFileMissingLog_FTPFileMissingConfig] FOREIGN KEY ([FTPFileMissingConfigID]) REFERENCES [dbo].[FTPFileMissingConfig] ([FTPFileMissingConfigID])
GO
