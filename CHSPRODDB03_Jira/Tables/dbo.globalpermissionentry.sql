CREATE TABLE [dbo].[globalpermissionentry]
(
[ID] [numeric] (18, 0) NOT NULL,
[PERMISSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GROUP_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[globalpermissionentry] ADD CONSTRAINT [PK_globalpermissionentry] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
