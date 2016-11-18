CREATE TABLE [internal].[execution_parameter_values]
(
[execution_parameter_id] [bigint] NOT NULL IDENTITY(1, 1),
[execution_id] [bigint] NOT NULL,
[object_type] [smallint] NOT NULL,
[parameter_data_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parameter_name] [sys].[sysname] NOT NULL,
[parameter_value] [sql_variant] NULL,
[sensitive_parameter_value] [varbinary] (max) NULL,
[base_data_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sensitive] [bit] NOT NULL,
[required] [bit] NOT NULL,
[value_set] [bit] NOT NULL,
[runtime_override] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_parameter_values] ADD CONSTRAINT [PK_Execution_Parameter_value] PRIMARY KEY CLUSTERED  ([execution_parameter_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExecutionParameterValue_ExecutionId] ON [internal].[execution_parameter_values] ([execution_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[execution_parameter_values] ADD CONSTRAINT [FK_ExecutionParameterValue_ExecutionId_Executions] FOREIGN KEY ([execution_id]) REFERENCES [internal].[executions] ([execution_id]) ON DELETE CASCADE
GO
