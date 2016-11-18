CREATE TABLE [dbo].[cwd_group]
(
[id] [numeric] (19, 0) NOT NULL,
[group_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_group_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[local] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[updated_date] [datetime] NOT NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[group_type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[directory_id] [numeric] (19, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group] ADD CONSTRAINT [PK__cwd_grou__3213E83F57012962] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_active] ON [dbo].[cwd_group] ([active], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_dir_id] ON [dbo].[cwd_group] ([directory_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group] ADD CONSTRAINT [cwd_group_name_dir_id] UNIQUE NONCLUSTERED  ([lower_group_name], [directory_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group] ADD CONSTRAINT [fk_directory_id] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
