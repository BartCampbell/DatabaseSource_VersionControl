CREATE TABLE [dbo].[userbase]
(
[ID] [numeric] (18, 0) NOT NULL,
[username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PASSWORD_HASH] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userbase] ADD CONSTRAINT [PK_userbase] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [osuser_name] ON [dbo].[userbase] ([username]) ON [PRIMARY]
GO
