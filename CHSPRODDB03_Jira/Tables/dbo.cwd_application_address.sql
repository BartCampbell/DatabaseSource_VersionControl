CREATE TABLE [dbo].[cwd_application_address]
(
[application_id] [numeric] (18, 0) NOT NULL,
[remote_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[encoded_address_binary] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[remote_address_mask] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application_address] ADD CONSTRAINT [PK_cwd_application_address] PRIMARY KEY CLUSTERED  ([application_id], [remote_address]) ON [PRIMARY]
GO
