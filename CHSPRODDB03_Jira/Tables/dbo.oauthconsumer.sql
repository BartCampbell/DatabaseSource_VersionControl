CREATE TABLE [dbo].[oauthconsumer]
(
[ID] [numeric] (18, 0) NOT NULL,
[CREATED] [datetime] NULL,
[consumername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CONSUMER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[consumerservice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PUBLIC_KEY] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PRIVATE_KEY] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CALLBACK] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SIGNATURE_METHOD] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SHARED_SECRET] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[oauthconsumer] ADD CONSTRAINT [PK_oauthconsumer] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [oauth_consumer_index] ON [dbo].[oauthconsumer] ([CONSUMER_KEY]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [oauth_consumer_service_index] ON [dbo].[oauthconsumer] ([consumerservice]) ON [PRIMARY]
GO
