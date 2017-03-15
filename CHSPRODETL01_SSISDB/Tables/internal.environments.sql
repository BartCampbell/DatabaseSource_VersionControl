CREATE TABLE [internal].[environments]
(
[environment_id] [bigint] NOT NULL IDENTITY(1, 1),
[environment_name] [sys].[sysname] NOT NULL,
[folder_id] [bigint] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_by_sid] [varbinary] (85) NOT NULL,
[created_by_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_time] [datetimeoffset] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[environments] ADD CONSTRAINT [PK_Environments] PRIMARY KEY CLUSTERED  ([environment_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[environments] ADD CONSTRAINT [Unique_Folder_Environment] UNIQUE NONCLUSTERED  ([environment_name], [folder_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[environments] ADD CONSTRAINT [FK_Environments_FolderId_Folders] FOREIGN KEY ([folder_id]) REFERENCES [internal].[folders] ([folder_id])
GO
