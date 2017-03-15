CREATE TABLE [internal].[event_messages]
(
[event_message_id] [bigint] NOT NULL,
[operation_id] [bigint] NOT NULL,
[execution_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_location_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path_full] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_name] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_source_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_source_id] [nvarchar] (38) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subcomponent_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[threadID] [int] NOT NULL,
[message_code] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[event_messages] ADD CONSTRAINT [PK_Event_Messages] PRIMARY KEY CLUSTERED  ([event_message_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventMessages_Operation_id] ON [internal].[event_messages] ([operation_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[event_messages] ADD CONSTRAINT [FK_EventMessage_Operations] FOREIGN KEY ([operation_id]) REFERENCES [internal].[operations] ([operation_id])
GO
ALTER TABLE [internal].[event_messages] ADD CONSTRAINT [FK_EventMessages_OperationMessageId_OperationMessage] FOREIGN KEY ([event_message_id]) REFERENCES [internal].[operation_messages] ([operation_message_id]) ON DELETE CASCADE
GO
