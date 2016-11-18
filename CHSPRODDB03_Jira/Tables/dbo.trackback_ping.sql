CREATE TABLE [dbo].[trackback_ping]
(
[ID] [numeric] (18, 0) NOT NULL,
[ISSUE] [numeric] (18, 0) NULL,
[URL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TITLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[BLOGNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EXCERPT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trackback_ping] ADD CONSTRAINT [PK_trackback_ping] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
