CREATE TABLE [dbo].[cwd_directory_attribute]
(
[directory_id] [numeric] (19, 0) NOT NULL,
[attribute_value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_attribute] ADD CONSTRAINT [PK__cwd_dire__B8384A5DD01BBB9B] PRIMARY KEY CLUSTERED  ([directory_id], [attribute_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_attribute] ADD CONSTRAINT [fk_directory_attribute] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
