CREATE TABLE [dbo].[fieldconfigscheme]
(
[ID] [numeric] (18, 0) NOT NULL,
[configname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CUSTOMFIELD] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldconfigscheme] ADD CONSTRAINT [PK_fieldconfigscheme] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fcs_fieldid] ON [dbo].[fieldconfigscheme] ([FIELDID]) ON [PRIMARY]
GO
