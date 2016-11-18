CREATE TABLE [dbo].[cwd_user_attributes]
(
[ID] [numeric] (18, 0) NOT NULL,
[user_id] [numeric] (18, 0) NULL,
[directory_id] [numeric] (18, 0) NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_attributes] ADD CONSTRAINT [PK_cwd_user_attributes] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_attr_dir_name_lval] ON [dbo].[cwd_user_attributes] ([directory_id], [attribute_name], [lower_attribute_value]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_user_attr_name_lval] ON [dbo].[cwd_user_attributes] ([user_id], [attribute_name]) ON [PRIMARY]
GO
