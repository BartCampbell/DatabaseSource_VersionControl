CREATE TABLE [dbo].[issuestatus]
(
[ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[pname] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICONURL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[STATUSCATEGORY] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[issuestatus] ADD CONSTRAINT [PK_issuestatus] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
