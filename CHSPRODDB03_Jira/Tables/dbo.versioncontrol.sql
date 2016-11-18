CREATE TABLE [dbo].[versioncontrol]
(
[ID] [numeric] (18, 0) NOT NULL,
[vcsname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[vcsdescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[vcstype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[versioncontrol] ADD CONSTRAINT [PK_versioncontrol] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
