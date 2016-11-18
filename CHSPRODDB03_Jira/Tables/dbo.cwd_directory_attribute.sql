CREATE TABLE [dbo].[cwd_directory_attribute]
(
[directory_id] [numeric] (18, 0) NOT NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[attribute_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_attribute] ADD CONSTRAINT [PK_cwd_directory_attribute] PRIMARY KEY CLUSTERED  ([directory_id], [attribute_name]) ON [PRIMARY]
GO
