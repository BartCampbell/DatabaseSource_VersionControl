CREATE TABLE [dbo].[mpi_output_provider]
(
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_rowid] [int] NULL,
[ihds_prov_id_attending] [bigint] NULL,
[ihds_prov_id_billing] [bigint] NOT NULL,
[ihds_prov_id_pcp] [bigint] NULL,
[ihds_prov_id_referring] [bigint] NULL,
[ihds_prov_id_servicing] [bigint] NULL,
[ihds_prov_id_admitting] [int] NULL
) ON [dbo_mpi_output_provider]
GO
CREATE CLUSTERED INDEX [idxMPI_output_provider] ON [dbo].[mpi_output_provider] ([clientid], [src_table_name], [src_db_name], [src_schema_name], [src_rowid]) ON [dbo_mpi_output_provider]
GO
CREATE NONCLUSTERED INDEX [idxclient_src_tab_rowid] ON [dbo].[mpi_output_provider] ([clientid], [src_table_name], [src_rowid]) ON [dbo_mpi_output_provider_IDX]
GO
CREATE STATISTICS [spidxMPI_output_provider] ON [dbo].[mpi_output_provider] ([clientid], [src_table_name], [src_db_name], [src_schema_name], [src_rowid])
GO
CREATE STATISTICS [spidxclient_src_tab_rowid] ON [dbo].[mpi_output_provider] ([clientid], [src_table_name], [src_rowid])
GO
