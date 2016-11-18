CREATE TABLE [internal].[operations]
(
[operation_id] [bigint] NOT NULL IDENTITY(1, 1),
[operation_type] [smallint] NOT NULL,
[created_time] [datetimeoffset] NULL,
[object_type] [smallint] NULL,
[object_id] [bigint] NULL,
[object_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [int] NOT NULL,
[start_time] [datetimeoffset] NULL,
[end_time] [datetimeoffset] NULL,
[caller_sid] [varbinary] (85) NOT NULL,
[caller_name] [sys].[sysname] NOT NULL,
[process_id] [int] NULL,
[stopped_by_sid] [varbinary] (85) NULL,
[stopped_by_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operation_guid] [uniqueidentifier] NULL,
[server_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[operations] ADD CONSTRAINT [PK_Operations] PRIMARY KEY CLUSTERED  ([operation_id]) ON [PRIMARY]
GO
GRANT SELECT ON  [internal].[operations] TO [ModuleSigner]
GO
GRANT UPDATE ON  [internal].[operations] TO [ModuleSigner]
GO
