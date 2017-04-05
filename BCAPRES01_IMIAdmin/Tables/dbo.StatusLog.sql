CREATE TABLE [dbo].[StatusLog]
(
[StatusLogID] [int] NOT NULL IDENTITY(1, 1),
[LoadInstanceID] [int] NULL,
[ProcedureName] [sys].[sysname] NOT NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusTime] [datetime] NULL,
[StatusType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StatusLog] ADD CONSTRAINT [PK_StatusLog] PRIMARY KEY CLUSTERED  ([StatusLogID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StatusLog] WITH NOCHECK ADD CONSTRAINT [FK_StatusLog_ClientProcessInstance] FOREIGN KEY ([LoadInstanceID]) REFERENCES [dbo].[ClientProcessInstance] ([LoadInstanceID])
GO
