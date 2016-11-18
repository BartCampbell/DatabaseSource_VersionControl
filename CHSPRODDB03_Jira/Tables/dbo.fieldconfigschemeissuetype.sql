CREATE TABLE [dbo].[fieldconfigschemeissuetype]
(
[ID] [numeric] (18, 0) NOT NULL,
[ISSUETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDCONFIGSCHEME] [numeric] (18, 0) NULL,
[FIELDCONFIGURATION] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldconfigschemeissuetype] ADD CONSTRAINT [PK_fieldconfigschemeissuetype] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fcs_scheme] ON [dbo].[fieldconfigschemeissuetype] ([FIELDCONFIGSCHEME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fcs_issuetype] ON [dbo].[fieldconfigschemeissuetype] ([ISSUETYPE]) ON [PRIMARY]
GO
