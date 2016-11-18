CREATE TABLE [dbo].[columnlayoutitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[COLUMNLAYOUT] [numeric] (18, 0) NULL,
[FIELDIDENTIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HORIZONTALPOSITION] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[columnlayoutitem] ADD CONSTRAINT [PK_columnlayoutitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_cli_fieldidentifier] ON [dbo].[columnlayoutitem] ([FIELDIDENTIFIER]) ON [PRIMARY]
GO
