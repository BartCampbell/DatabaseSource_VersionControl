CREATE TABLE [dbo].[PursuitEventNoteCategoryOriginal]
(
[PursuitEventNoteCategoryID] [int] NOT NULL,
[ParentID] [int] NULL,
[SortOrder] [tinyint] NOT NULL,
[Title] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
