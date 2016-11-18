CREATE TABLE [dbo].[pluginversion]
(
[ID] [numeric] (18, 0) NOT NULL,
[pluginname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[pluginkey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[pluginversion] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pluginversion] ADD CONSTRAINT [PK_pluginversion] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
