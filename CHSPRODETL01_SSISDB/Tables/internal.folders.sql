CREATE TABLE [internal].[folders]
(
[folder_id] [bigint] NOT NULL IDENTITY(1, 1),
[name] [sys].[sysname] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_by_sid] [varbinary] (85) NOT NULL,
[created_by_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_time] [datetimeoffset] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[folders] ADD CONSTRAINT [PK_Folders] PRIMARY KEY CLUSTERED  ([folder_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Unique_folder_name] ON [internal].[folders] ([name]) ON [PRIMARY]
GO
