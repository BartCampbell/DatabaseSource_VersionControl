CREATE TABLE [dbo].[cwd_app_dir_mapping]
(
[id] [numeric] (19, 0) NOT NULL,
[application_id] [numeric] (19, 0) NULL,
[directory_id] [numeric] (19, 0) NOT NULL,
[allow_all] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[list_index] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_mapping] ADD CONSTRAINT [PK__cwd_app___3213E83F65D0AA58] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_dir_app] ON [dbo].[cwd_app_dir_mapping] ([application_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_dir_dir] ON [dbo].[cwd_app_dir_mapping] ([directory_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_app_dir_mapping] ADD CONSTRAINT [fk_app_dir_dir] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
ALTER TABLE [dbo].[cwd_app_dir_mapping] ADD CONSTRAINT [FK52050E2FB347AA6A] FOREIGN KEY ([application_id]) REFERENCES [dbo].[cwd_application] ([id])
GO
