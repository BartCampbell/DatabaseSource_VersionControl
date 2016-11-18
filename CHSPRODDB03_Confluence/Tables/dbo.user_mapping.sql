CREATE TABLE [dbo].[user_mapping]
(
[user_key] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_mapping] ADD CONSTRAINT [PK__user_map__E1CC8CC0ACAAB9F6] PRIMARY KEY CLUSTERED  ([user_key]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [user_mapping_unq_lwr_username] ON [dbo].[user_mapping] ([lower_username]) WHERE ([lower_username] IS NOT NULL) ON [PRIMARY]
GO
