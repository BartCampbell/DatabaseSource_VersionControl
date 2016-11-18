CREATE TABLE [internal].[validations]
(
[validation_id] [bigint] NOT NULL,
[environment_scope] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[validate_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[folder_name] [sys].[sysname] NOT NULL,
[project_name] [sys].[sysname] NOT NULL,
[project_lsn] [bigint] NULL,
[use32bitruntime] [bit] NULL,
[reference_id] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[validations] ADD CONSTRAINT [PK_Validations] PRIMARY KEY CLUSTERED  ([validation_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[validations] ADD CONSTRAINT [FK_Validations_ValidationId_Operations] FOREIGN KEY ([validation_id]) REFERENCES [internal].[operations] ([operation_id]) ON DELETE CASCADE
GO
