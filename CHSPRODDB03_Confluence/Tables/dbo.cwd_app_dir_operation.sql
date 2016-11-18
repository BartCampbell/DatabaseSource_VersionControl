CREATE TABLE [dbo].[cwd_app_dir_operation]
(
[app_dir_mapping_id] [numeric] (19, 0) NOT NULL,
[operation_type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_operation] ADD CONSTRAINT [PK__cwd_app___B96C2888D0F308C4] PRIMARY KEY CLUSTERED  ([app_dir_mapping_id], [operation_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_operation] ADD CONSTRAINT [fk_app_dir_mapping] FOREIGN KEY ([app_dir_mapping_id]) REFERENCES [dbo].[cwd_app_dir_mapping] ([id])
GO
