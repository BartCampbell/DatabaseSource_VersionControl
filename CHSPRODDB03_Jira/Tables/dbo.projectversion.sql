CREATE TABLE [dbo].[projectversion]
(
[ID] [numeric] (18, 0) NOT NULL,
[PROJECT] [numeric] (18, 0) NULL,
[vname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[RELEASED] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ARCHIVED] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[URL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[STARTDATE] [datetime] NULL,
[RELEASEDATE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[projectversion] ADD CONSTRAINT [PK_projectversion] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_version_project] ON [dbo].[projectversion] ([PROJECT]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_version_sequence] ON [dbo].[projectversion] ([SEQUENCE]) ON [PRIMARY]
GO
