CREATE TABLE [etl].[ThreadLog]
(
[ThreadLogID] [int] NOT NULL IDENTITY(1000000, 1),
[FileLogSessionID] [int] NOT NULL,
[Thread] [int] NOT NULL,
[ExecutionId] [bigint] NULL,
[StatusCd] [int] NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_ThreadLog_CreateDate] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF_ThreadLog_LastUpdated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [etl].[ThreadLog] ADD CONSTRAINT [PK_ThreadLog_ThreadLogID] PRIMARY KEY CLUSTERED  ([ThreadLogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_ThreadLog] ON [etl].[ThreadLog] ([FileLogSessionID], [Thread]) ON [PRIMARY]
GO
