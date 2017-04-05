CREATE TABLE [dbo].[tmp_mpi_pre_load_dtl_prov]
(
[Src_rowID] [bigint] NULL,
[mpi_pre_load_prov_rowid] [bigint] NOT NULL,
[src_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[char_mpi_pre_load_prov_rowid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpi_srcname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk2] ON [dbo].[tmp_mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [char_mpi_pre_load_prov_rowid], [Src_rowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[tmp_mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [Src_rowID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp2] ON [dbo].[tmp_mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [char_mpi_pre_load_prov_rowid], [Src_rowID])
GO
CREATE STATISTICS [sp] ON [dbo].[tmp_mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [Src_rowID])
GO
