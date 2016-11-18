CREATE TABLE [dbo].[schemeissuesecuritylevels]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[schemeissuesecuritylevels] ADD CONSTRAINT [PK_schemeissuesecuritylevels] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
