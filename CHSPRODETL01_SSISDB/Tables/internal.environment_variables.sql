CREATE TABLE [internal].[environment_variables]
(
[variable_id] [bigint] NOT NULL IDENTITY(1, 1),
[environment_id] [bigint] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sensitive] [bit] NOT NULL,
[value] [sql_variant] NULL,
[sensitive_value] [varbinary] (max) NULL,
[base_data_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[environment_variables] ADD CONSTRAINT [PK_Environment_Variables] PRIMARY KEY CLUSTERED  ([variable_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[environment_variables] ADD CONSTRAINT [Unique_Environment_Variable] UNIQUE NONCLUSTERED  ([environment_id], [name]) ON [PRIMARY]
GO
ALTER TABLE [internal].[environment_variables] ADD CONSTRAINT [FK_EnvironmentVariables_EnvironmentId_Environments] FOREIGN KEY ([environment_id]) REFERENCES [internal].[environments] ([environment_id]) ON DELETE CASCADE
GO
