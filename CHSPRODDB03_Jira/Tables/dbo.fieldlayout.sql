CREATE TABLE [dbo].[fieldlayout]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[layout_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LAYOUTSCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldlayout] ADD CONSTRAINT [PK_fieldlayout] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
