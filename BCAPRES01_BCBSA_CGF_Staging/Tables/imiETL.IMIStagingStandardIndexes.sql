CREATE TABLE [imiETL].[IMIStagingStandardIndexes]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[TabSchema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TabName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClusteredIndexFlag] [bit] NULL,
[IndexFields] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeFields] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataFGPath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexFGPath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
