CREATE TABLE [dbo].[mpi_output_member]
(
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_rowid] [int] NOT NULL,
[ihds_member_id] [bigint] NOT NULL
) ON [dbo_mpi_output_member]
GO
CREATE NONCLUSTERED INDEX [fk_client_src_tab_rowid] ON [dbo].[mpi_output_member] ([clientid], [src_schema_name], [src_table_name], [src_rowid]) ON [dbo_mpi_output_member_IDX]
GO
CREATE CLUSTERED INDEX [pk_mpi_output_member] ON [dbo].[mpi_output_member] ([clientid], [src_table_name], [src_db_name], [src_schema_name], [src_rowid], [ihds_member_id]) ON [dbo_mpi_output_member]
GO
CREATE STATISTICS [spfk_client_src_tab_rowid] ON [dbo].[mpi_output_member] ([clientid], [src_schema_name], [src_table_name], [src_rowid])
GO
CREATE STATISTICS [sppk_mpi_output_member] ON [dbo].[mpi_output_member] ([clientid], [src_table_name], [src_db_name], [src_schema_name], [src_rowid], [ihds_member_id])
GO
