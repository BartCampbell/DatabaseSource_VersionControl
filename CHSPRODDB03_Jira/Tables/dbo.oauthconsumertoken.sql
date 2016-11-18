CREATE TABLE [dbo].[oauthconsumertoken]
(
[ID] [numeric] (18, 0) NOT NULL,
[CREATED] [datetime] NULL,
[TOKEN_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TOKEN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TOKEN_SECRET] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TOKEN_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CONSUMER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[oauthconsumertoken] ADD CONSTRAINT [PK_oauthconsumertoken] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [oauth_consumer_token_index] ON [dbo].[oauthconsumertoken] ([TOKEN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [oauth_consumer_token_key_index] ON [dbo].[oauthconsumertoken] ([TOKEN_KEY]) ON [PRIMARY]
GO
