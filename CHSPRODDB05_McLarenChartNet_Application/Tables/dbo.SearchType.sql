CREATE TABLE [dbo].[SearchType]
(
[SearchTypeID] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WhereClause] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultSort] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SearchType] ADD CONSTRAINT [PK_SearchType] PRIMARY KEY CLUSTERED  ([SearchTypeID]) ON [PRIMARY]
GO
