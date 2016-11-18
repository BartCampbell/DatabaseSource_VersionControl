CREATE TABLE [dbo].[project]
(
[ID] [numeric] (18, 0) NOT NULL,
[pname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[URL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LEAD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[pkey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[pcounter] [numeric] (18, 0) NULL,
[ASSIGNEETYPE] [numeric] (18, 0) NULL,
[AVATAR] [numeric] (18, 0) NULL,
[ORIGINALKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROJECTTYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[project] ADD CONSTRAINT [PK_project] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_project_key] ON [dbo].[project] ([pkey]) ON [PRIMARY]
GO
