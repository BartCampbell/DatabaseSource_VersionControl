CREATE TABLE [internal].[execution_data_taps]
(
[data_tap_id] [bigint] NOT NULL IDENTITY(1, 1),
[execution_id] [bigint] NOT NULL,
[package_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataflow_path_id_string] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataflow_task_guid] [uniqueidentifier] NULL,
[max_rows] [int] NULL,
[filename] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_data_taps] ADD CONSTRAINT [PK_Execution_data_taps] PRIMARY KEY CLUSTERED  ([data_tap_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_data_taps] ADD CONSTRAINT [FK_ExecDataTaps_ExecutionId_Executions] FOREIGN KEY ([execution_id]) REFERENCES [internal].[executions] ([execution_id]) ON DELETE CASCADE
GO
