CREATE TABLE [dbo].[issuetypescreenschemeentity]
(
[ID] [numeric] (18, 0) NOT NULL,
[ISSUETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SCHEME] [numeric] (18, 0) NULL,
[FIELDSCREENSCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issuetypescreenschemeentity] ADD CONSTRAINT [PK_issuetypescreenschemeentity] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldscreen_scheme] ON [dbo].[issuetypescreenschemeentity] ([FIELDSCREENSCHEME]) ON [PRIMARY]
GO
