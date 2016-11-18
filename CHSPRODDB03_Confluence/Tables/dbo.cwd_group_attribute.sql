CREATE TABLE [dbo].[cwd_group_attribute]
(
[id] [numeric] (19, 0) NOT NULL,
[group_id] [numeric] (19, 0) NOT NULL,
[directory_id] [numeric] (19, 0) NOT NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[attribute_lower_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group_attribute] ADD CONSTRAINT [PK__cwd_grou__3213E83FCC4EFB58] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_attr_dir_name_lval] ON [dbo].[cwd_group_attribute] ([directory_id], [attribute_name], [attribute_lower_value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group_attribute] ADD CONSTRAINT [cwd_unique_grp_attr] UNIQUE NONCLUSTERED  ([directory_id], [group_id], [attribute_name], [attribute_lower_value]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_attr_group_id] ON [dbo].[cwd_group_attribute] ([group_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group_attribute] ADD CONSTRAINT [fk_group_attr_dir_id] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
ALTER TABLE [dbo].[cwd_group_attribute] ADD CONSTRAINT [fk_group_attr_id_group_id] FOREIGN KEY ([group_id]) REFERENCES [dbo].[cwd_group] ([id])
GO
