CREATE TABLE [dbo].[searchrequest]
(
[ID] [numeric] (18, 0) NOT NULL,
[filtername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[authorname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[groupname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[projectid] [numeric] (18, 0) NULL,
[reqcontent] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FAV_COUNT] [numeric] (18, 0) NULL,
[filtername_lower] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[searchrequest] ADD CONSTRAINT [PK_searchrequest] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sr_author] ON [dbo].[searchrequest] ([authorname]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [searchrequest_filternameLower] ON [dbo].[searchrequest] ([filtername_lower]) ON [PRIMARY]
GO
