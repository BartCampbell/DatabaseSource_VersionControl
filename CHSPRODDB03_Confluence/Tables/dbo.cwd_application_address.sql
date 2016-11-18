CREATE TABLE [dbo].[cwd_application_address]
(
[application_id] [numeric] (19, 0) NOT NULL,
[remote_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application_address] ADD CONSTRAINT [PK__cwd_appl__5239323908F99C59] PRIMARY KEY CLUSTERED  ([application_id], [remote_address]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application_address] ADD CONSTRAINT [fk_application_address] FOREIGN KEY ([application_id]) REFERENCES [dbo].[cwd_application] ([id])
GO
