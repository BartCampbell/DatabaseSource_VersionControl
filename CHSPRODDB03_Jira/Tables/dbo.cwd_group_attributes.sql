CREATE TABLE [dbo].[cwd_group_attributes]
(
[ID] [numeric] (18, 0) NOT NULL,
[group_id] [numeric] (18, 0) NULL,
[directory_id] [numeric] (18, 0) NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group_attributes] ADD CONSTRAINT [PK_cwd_group_attributes] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_attr_dir_name_lval] ON [dbo].[cwd_group_attributes] ([directory_id], [attribute_name], [lower_attribute_value]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_group_attr_name_lval] ON [dbo].[cwd_group_attributes] ([group_id], [attribute_name], [lower_attribute_value]) ON [PRIMARY]
GO
