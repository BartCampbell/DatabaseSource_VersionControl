CREATE TABLE [dbo].[mpi_output_member]
(
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_rowid] [int] NOT NULL,
[ihds_member_id] [bigint] NOT NULL
) ON [PRIMARY]
GO
