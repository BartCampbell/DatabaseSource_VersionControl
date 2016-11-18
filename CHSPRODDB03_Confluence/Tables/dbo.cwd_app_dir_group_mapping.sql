CREATE TABLE [dbo].[cwd_app_dir_group_mapping]
(
[id] [numeric] (19, 0) NOT NULL,
[app_dir_mapping_id] [numeric] (19, 0) NOT NULL,
[application_id] [numeric] (19, 0) NOT NULL,
[directory_id] [numeric] (19, 0) NOT NULL,
[group_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_group_mapping] ADD CONSTRAINT [PK__cwd_app___3213E83FB541D743] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_dir_group_mapping] ON [dbo].[cwd_app_dir_group_mapping] ([app_dir_mapping_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_dir_group_app] ON [dbo].[cwd_app_dir_group_mapping] ([application_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_dir_group_group_dir] ON [dbo].[cwd_app_dir_group_mapping] ([directory_id], [group_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_group_mapping] ADD CONSTRAINT [fk_app_dir_group_app] FOREIGN KEY ([application_id]) REFERENCES [dbo].[cwd_application] ([id])
GO
ALTER TABLE [dbo].[cwd_app_dir_group_mapping] ADD CONSTRAINT [fk_app_dir_group_dir] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
ALTER TABLE [dbo].[cwd_app_dir_group_mapping] ADD CONSTRAINT [fk_app_dir_group_mapping] FOREIGN KEY ([app_dir_mapping_id]) REFERENCES [dbo].[cwd_app_dir_mapping] ([id])
GO
