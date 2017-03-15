CREATE TABLE [internal].[projects]
(
[project_id] [bigint] NOT NULL IDENTITY(1, 1),
[folder_id] [bigint] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[project_format_version] [int] NULL,
[deployed_by_sid] [varbinary] (85) NOT NULL,
[deployed_by_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_deployed_time] [datetimeoffset] NOT NULL,
[created_time] [datetimeoffset] NOT NULL,
[object_version_lsn] [bigint] NOT NULL,
[validation_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_validation_time] [datetimeoffset] NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[projects] ADD CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED  ([project_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Projects_Name] ON [internal].[projects] ([name]) INCLUDE ([folder_id], [object_version_lsn], [project_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[projects] ADD CONSTRAINT [Unique_Project_FolderName] UNIQUE NONCLUSTERED  ([name], [folder_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[projects] ADD CONSTRAINT [FK_Projects_FolderId_Folders] FOREIGN KEY ([folder_id]) REFERENCES [internal].[folders] ([folder_id])
GO
