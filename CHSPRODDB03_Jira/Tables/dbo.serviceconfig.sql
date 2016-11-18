CREATE TABLE [dbo].[serviceconfig]
(
[ID] [numeric] (18, 0) NOT NULL,
[delaytime] [numeric] (18, 0) NULL,
[CLAZZ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[servicename] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CRON_EXPRESSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[serviceconfig] ADD CONSTRAINT [PK_serviceconfig] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
