CREATE TABLE [dbo].[fieldlayoutschemeassociation]
(
[ID] [numeric] (18, 0) NOT NULL,
[ISSUETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROJECT] [numeric] (18, 0) NULL,
[FIELDLAYOUTSCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldlayoutschemeassociation] ADD CONSTRAINT [PK_fieldlayoutschemeassociatio] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fl_scheme_assoc] ON [dbo].[fieldlayoutschemeassociation] ([PROJECT], [ISSUETYPE]) ON [PRIMARY]
GO
