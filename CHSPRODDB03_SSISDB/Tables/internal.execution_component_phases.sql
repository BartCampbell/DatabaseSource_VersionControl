CREATE TABLE [internal].[execution_component_phases]
(
[phase_stats_id] [bigint] NOT NULL IDENTITY(1, 1),
[execution_id] [bigint] NOT NULL,
[package_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_location_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path_full] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[subcomponent_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phase] [sys].[sysname] NOT NULL,
[is_start] [bit] NULL,
[phase_time] [datetimeoffset] NULL,
[execution_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence_id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_component_phases] ADD CONSTRAINT [PK_Execution_component_phases] PRIMARY KEY CLUSTERED  ([phase_stats_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Unique_sequence_id] ON [internal].[execution_component_phases] ([execution_id], [sequence_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_component_phases] ADD CONSTRAINT [FK_ExecCompPhases_ExecutionId_Executions] FOREIGN KEY ([execution_id]) REFERENCES [internal].[executions] ([execution_id]) ON DELETE CASCADE
GO
