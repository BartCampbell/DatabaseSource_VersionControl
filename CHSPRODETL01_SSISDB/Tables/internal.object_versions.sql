CREATE TABLE [internal].[object_versions]
(
[object_version_lsn] [bigint] NOT NULL IDENTITY(1, 1),
[object_id] [bigint] NOT NULL,
[object_type] [smallint] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_by] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_time] [datetimeoffset] NOT NULL,
[restored_by] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_restored_time] [datetimeoffset] NULL,
[object_data] [varbinary] (max) NOT NULL,
[object_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[object_versions] ADD CONSTRAINT [PK_Object_Versions] PRIMARY KEY CLUSTERED  ([object_version_lsn]) ON [PRIMARY]
GO
