CREATE TABLE [dbo].[tmp_mpi_pre_load_prov]
(
[mpi_pre_load_prov_rowid] [bigint] NOT NULL,
[src_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[char_mpi_pre_load_prov_rowid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[tmp_mpi_pre_load_prov] ([mpi_pre_load_prov_rowid], [src_name], [char_mpi_pre_load_prov_rowid], [clientid], [src_table_name], [src_db_name], [src_schema_name]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [dbo].[tmp_mpi_pre_load_prov] ([mpi_pre_load_prov_rowid], [src_name], [char_mpi_pre_load_prov_rowid], [clientid], [src_table_name], [src_db_name], [src_schema_name])
GO
