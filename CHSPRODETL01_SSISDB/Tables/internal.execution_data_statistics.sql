CREATE TABLE [internal].[execution_data_statistics]
(
[data_stats_id] [bigint] NOT NULL IDENTITY(1, 1),
[execution_id] [bigint] NOT NULL,
[package_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_location_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path_full] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataflow_path_id_string] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataflow_path_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_component_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_component_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rows_sent] [bigint] NULL,
[created_time] [datetimeoffset] NULL,
[execution_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_data_statistics] ADD CONSTRAINT [PK_Execution_data_statistics] PRIMARY KEY CLUSTERED  ([data_stats_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_data_statistics] ADD CONSTRAINT [FK_ExecDataStat_ExecutionId_Executions] FOREIGN KEY ([execution_id]) REFERENCES [internal].[executions] ([execution_id]) ON DELETE CASCADE
GO
