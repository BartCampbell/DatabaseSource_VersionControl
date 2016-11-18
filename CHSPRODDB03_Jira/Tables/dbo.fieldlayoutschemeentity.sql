CREATE TABLE [dbo].[fieldlayoutschemeentity]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[issuetype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDLAYOUT] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldlayoutschemeentity] ADD CONSTRAINT [PK_fieldlayoutschemeentity] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldlayout_layout] ON [dbo].[fieldlayoutschemeentity] ([FIELDLAYOUT]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldlayout_scheme] ON [dbo].[fieldlayoutschemeentity] ([SCHEME]) ON [PRIMARY]
GO
