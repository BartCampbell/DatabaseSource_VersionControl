CREATE TABLE [dbo].[pluginstate]
(
[pluginkey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[pluginenabled] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pluginstate] ADD CONSTRAINT [PK_pluginstate] PRIMARY KEY CLUSTERED  ([pluginkey]) ON [PRIMARY]
GO
