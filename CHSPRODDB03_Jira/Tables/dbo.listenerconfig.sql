CREATE TABLE [dbo].[listenerconfig]
(
[ID] [numeric] (18, 0) NOT NULL,
[CLAZZ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[listenername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listenerconfig] ADD CONSTRAINT [PK_listenerconfig] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
