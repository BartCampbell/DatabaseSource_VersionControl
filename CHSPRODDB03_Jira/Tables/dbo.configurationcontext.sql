CREATE TABLE [dbo].[configurationcontext]
(
[ID] [numeric] (18, 0) NOT NULL,
[PROJECTCATEGORY] [numeric] (18, 0) NULL,
[PROJECT] [numeric] (18, 0) NULL,
[customfield] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDCONFIGSCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[configurationcontext] ADD CONSTRAINT [PK_configurationcontext] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [confcontextfieldconfigscheme] ON [dbo].[configurationcontext] ([FIELDCONFIGSCHEME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [confcontextprojectkey] ON [dbo].[configurationcontext] ([PROJECT], [customfield]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [confcontext] ON [dbo].[configurationcontext] ([PROJECTCATEGORY], [PROJECT], [customfield]) ON [PRIMARY]
GO
