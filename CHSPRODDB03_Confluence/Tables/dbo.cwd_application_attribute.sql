CREATE TABLE [dbo].[cwd_application_attribute]
(
[application_id] [numeric] (19, 0) NOT NULL,
[attribute_value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[attribute_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application_attribute] ADD CONSTRAINT [PK__cwd_appl__CF87786C3656CD90] PRIMARY KEY CLUSTERED  ([application_id], [attribute_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application_attribute] ADD CONSTRAINT [fk_application_attribute] FOREIGN KEY ([application_id]) REFERENCES [dbo].[cwd_application] ([id])
GO
