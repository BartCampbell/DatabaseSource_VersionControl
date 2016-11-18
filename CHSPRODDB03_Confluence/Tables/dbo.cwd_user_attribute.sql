CREATE TABLE [dbo].[cwd_user_attribute]
(
[id] [numeric] (19, 0) NOT NULL,
[user_id] [numeric] (19, 0) NOT NULL,
[directory_id] [numeric] (19, 0) NOT NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[attribute_lower_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_attribute] ADD CONSTRAINT [PK__cwd_user__3213E83F53EA6350] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_attr_dir_name_lval] ON [dbo].[cwd_user_attribute] ([directory_id], [attribute_name], [attribute_lower_value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_attribute] ADD CONSTRAINT [cwd_unique_usr_attr] UNIQUE NONCLUSTERED  ([directory_id], [user_id], [attribute_name], [attribute_lower_value]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_attr_user_id] ON [dbo].[cwd_user_attribute] ([user_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_attribute] ADD CONSTRAINT [fk_user_attr_dir_id] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
ALTER TABLE [dbo].[cwd_user_attribute] ADD CONSTRAINT [fk_user_attribute_id_user_id] FOREIGN KEY ([user_id]) REFERENCES [dbo].[cwd_user] ([id])
GO
