CREATE TABLE [dbo].[portalpage]
(
[ID] [numeric] (18, 0) NOT NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PAGENAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[FAV_COUNT] [numeric] (18, 0) NULL,
[LAYOUT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ppversion] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portalpage] ADD CONSTRAINT [PK_portalpage] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ppage_username] ON [dbo].[portalpage] ([USERNAME]) ON [PRIMARY]
GO
