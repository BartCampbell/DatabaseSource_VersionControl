CREATE TABLE [internal].[event_message_context]
(
[context_id] [bigint] NOT NULL IDENTITY(1, 1),
[operation_id] [bigint] NOT NULL,
[event_message_id] [bigint] NOT NULL,
[context_depth] [int] NULL,
[package_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[context_type] [smallint] NULL,
[context_source_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[context_source_id] [nvarchar] (38) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[property_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[property_value] [sql_variant] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[event_message_context] ADD CONSTRAINT [PK_Event_Message_Context] PRIMARY KEY CLUSTERED  ([context_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventMessageContext_Operation_id] ON [internal].[event_message_context] ([operation_id], [event_message_id]) INCLUDE ([context_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[event_message_context] ADD CONSTRAINT [FK_EventMessageContext_EventMessageId_EventMessages] FOREIGN KEY ([event_message_id]) REFERENCES [internal].[event_messages] ([event_message_id]) ON DELETE CASCADE
GO
ALTER TABLE [internal].[event_message_context] ADD CONSTRAINT [FK_EventMessagecontext_Operations] FOREIGN KEY ([operation_id]) REFERENCES [internal].[operations] ([operation_id])
GO
