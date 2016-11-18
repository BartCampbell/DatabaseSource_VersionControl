CREATE TABLE [dbo].[mailserver]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[mailfrom] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PREFIX] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[smtp_port] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[protocol] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[server_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SERVERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JNDILOCATION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[mailusername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[mailpassword] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISTLSREQUIRED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIMEOUT] [numeric] (18, 0) NULL,
[socks_port] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[socks_host] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[mailserver] ADD CONSTRAINT [PK_mailserver] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
