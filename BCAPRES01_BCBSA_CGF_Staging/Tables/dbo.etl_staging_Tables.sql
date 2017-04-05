CREATE TABLE [dbo].[etl_staging_Tables]
(
[TableID] [int] NOT NULL IDENTITY(1, 1),
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveFLag] [bit] NULL,
[TableGranularity] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableBuildGranularity] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
