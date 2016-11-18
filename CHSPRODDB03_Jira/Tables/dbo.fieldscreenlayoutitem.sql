CREATE TABLE [dbo].[fieldscreenlayoutitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[FIELDIDENTIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[FIELDSCREENTAB] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldscreenlayoutitem] ADD CONSTRAINT [PK_fieldscreenlayoutitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldscreen_field] ON [dbo].[fieldscreenlayoutitem] ([FIELDIDENTIFIER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldscitem_tab] ON [dbo].[fieldscreenlayoutitem] ([FIELDSCREENTAB]) ON [PRIMARY]
GO
