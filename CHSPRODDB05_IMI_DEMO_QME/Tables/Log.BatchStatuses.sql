CREATE TABLE [Log].[BatchStatuses]
(
[BatchID] [int] NOT NULL,
[BatchStatusID] [smallint] NOT NULL,
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_BatchStatuses_LogDate] DEFAULT (getdate()),
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BatchStatuses_LogUser] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [Log].[BatchStatuses] ADD CONSTRAINT [PK_Log_BatchStatuses] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
