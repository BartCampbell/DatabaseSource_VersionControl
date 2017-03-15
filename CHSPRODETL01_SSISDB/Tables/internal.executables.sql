CREATE TABLE [internal].[executables]
(
[executable_id] [bigint] NOT NULL IDENTITY(1, 1),
[project_id] [bigint] NOT NULL,
[project_version_lsn] [bigint] NOT NULL,
[package_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_location_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path_full] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[executable_name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[executable_guid] [nvarchar] (38) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[executables] ADD CONSTRAINT [PK_Executables] PRIMARY KEY CLUSTERED  ([executable_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[executables] ADD CONSTRAINT [FK_Executables] FOREIGN KEY ([project_id]) REFERENCES [internal].[projects] ([project_id]) ON DELETE CASCADE
GO
