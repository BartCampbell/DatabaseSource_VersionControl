CREATE TABLE [dbo].[app_user]
(
[ID] [numeric] (18, 0) NOT NULL,
[user_key] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_user_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[app_user] ADD CONSTRAINT [PK_app_user] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_lower_user_name] ON [dbo].[app_user] ([lower_user_name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_user_key] ON [dbo].[app_user] ([user_key]) ON [PRIMARY]
GO
