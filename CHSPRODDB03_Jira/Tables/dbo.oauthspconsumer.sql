CREATE TABLE [dbo].[oauthspconsumer]
(
[ID] [numeric] (18, 0) NOT NULL,
[CREATED] [datetime] NULL,
[CONSUMER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[consumername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PUBLIC_KEY] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CALLBACK] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TWO_L_O_ALLOWED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EXECUTING_TWO_L_O_USER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TWO_L_O_IMPERSONATION_ALLOWED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[THREE_L_O_ALLOWED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[oauthspconsumer] ADD CONSTRAINT [PK_oauthspconsumer] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [oauth_sp_consumer_index] ON [dbo].[oauthspconsumer] ([CONSUMER_KEY]) ON [PRIMARY]
GO
