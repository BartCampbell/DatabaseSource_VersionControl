CREATE TABLE [dbo].[tblPage]
(
[page_pk] [smallint] NOT NULL IDENTITY(1, 1),
[page_name] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[page_caption] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[url] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[isPage] [bit] NULL,
[isPageElement] [bit] NULL,
[parent_pk] [smallint] NOT NULL CONSTRAINT [DF_tblPage_parent_id] DEFAULT ((0)),
[sortOrder] [smallint] NOT NULL CONSTRAINT [DF_tblPage_sortOrder] DEFAULT ((0)),
[isActive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPage] ADD CONSTRAINT [PK_tblPage] PRIMARY KEY CLUSTERED  ([page_pk]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
