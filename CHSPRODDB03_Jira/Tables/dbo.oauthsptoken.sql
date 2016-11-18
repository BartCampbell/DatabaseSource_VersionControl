CREATE TABLE [dbo].[oauthsptoken]
(
[ID] [numeric] (18, 0) NOT NULL,
[CREATED] [datetime] NULL,
[TOKEN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TOKEN_SECRET] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TOKEN_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CONSUMER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TTL] [numeric] (18, 0) NULL,
[spauth] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CALLBACK] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[spverifier] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[spversion] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SESSION_HANDLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SESSION_CREATION_TIME] [datetime] NULL,
[SESSION_LAST_RENEWAL_TIME] [datetime] NULL,
[SESSION_TIME_TO_LIVE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[oauthsptoken] ADD CONSTRAINT [PK_oauthsptoken] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [oauth_sp_consumer_key_index] ON [dbo].[oauthsptoken] ([CONSUMER_KEY]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [oauth_sp_token_index] ON [dbo].[oauthsptoken] ([TOKEN]) ON [PRIMARY]
GO
