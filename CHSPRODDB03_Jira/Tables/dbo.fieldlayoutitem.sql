CREATE TABLE [dbo].[fieldlayoutitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[FIELDLAYOUT] [numeric] (18, 0) NULL,
[FIELDIDENTIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[VERTICALPOSITION] [numeric] (18, 0) NULL,
[ISHIDDEN] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISREQUIRED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[RENDERERTYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldlayoutitem] ADD CONSTRAINT [PK_fieldlayoutitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_fli_fieldidentifier] ON [dbo].[fieldlayoutitem] ([FIELDIDENTIFIER]) ON [PRIMARY]
GO
