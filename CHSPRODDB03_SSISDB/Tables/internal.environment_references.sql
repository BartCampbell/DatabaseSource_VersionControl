CREATE TABLE [internal].[environment_references]
(
[reference_id] [bigint] NOT NULL IDENTITY(1, 1),
[project_id] [bigint] NOT NULL,
[reference_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[environment_folder_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[environment_name] [sys].[sysname] NOT NULL,
[validation_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_validation_time] [datetimeoffset] NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[environment_references] ADD CONSTRAINT [PK_environment_references] PRIMARY KEY CLUSTERED  ([reference_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[environment_references] ADD CONSTRAINT [FK_ProjectEnvironment_ProjectId_Projects] FOREIGN KEY ([project_id]) REFERENCES [internal].[projects] ([project_id]) ON DELETE CASCADE
GO
