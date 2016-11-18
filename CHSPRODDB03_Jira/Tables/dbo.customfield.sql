CREATE TABLE [dbo].[customfield]
(
[ID] [numeric] (18, 0) NOT NULL,
[CUSTOMFIELDTYPEKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CUSTOMFIELDSEARCHERKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[cfname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[defaultvalue] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDTYPE] [numeric] (18, 0) NULL,
[PROJECT] [numeric] (18, 0) NULL,
[ISSUETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[cfkey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[customfield] ADD CONSTRAINT [PK_customfield] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
