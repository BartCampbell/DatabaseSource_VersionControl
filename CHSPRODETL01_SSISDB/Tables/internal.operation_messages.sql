CREATE TABLE [internal].[operation_messages]
(
[operation_message_id] [bigint] NOT NULL IDENTITY(1, 1),
[operation_id] [bigint] NOT NULL,
[message_time] [datetimeoffset] NOT NULL,
[message_type] [smallint] NOT NULL,
[message_source_type] [smallint] NULL,
[message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extended_info_id] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[operation_messages] ADD CONSTRAINT [PK_Operation_Messages] PRIMARY KEY CLUSTERED  ([operation_message_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OperationMessages_Operation_id] ON [internal].[operation_messages] ([operation_id]) INCLUDE ([operation_message_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[operation_messages] ADD CONSTRAINT [FK_OperationMessages_OperationId_Operations] FOREIGN KEY ([operation_id]) REFERENCES [internal].[operations] ([operation_id]) ON DELETE CASCADE
GO
