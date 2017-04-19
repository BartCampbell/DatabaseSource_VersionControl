CREATE TABLE [dbo].[mpi_pre_load_prov]
(
[mpi_pre_load_prov_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_prov_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashvalue] [binary] (16) NULL,
[LoadDate] [datetime] NOT NULL,
[medical_provider_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpi_prov_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_hashvalue] ON [dbo].[mpi_pre_load_prov] ([hashvalue], [mpi_pre_load_prov_rowid]) ON [dbo_mpi_pre_load_prov_IDX]
GO
CREATE CLUSTERED INDEX [fk_dtllink] ON [dbo].[mpi_pre_load_prov] ([mpi_pre_load_prov_rowid], [clientid], [src_table_name], [src_db_name], [src_schema_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_rowid_srcname] ON [dbo].[mpi_pre_load_prov] ([mpi_pre_load_prov_rowid], [src_name]) ON [dbo_mpi_pre_load_prov_IDX]
GO
CREATE STATISTICS [spfk_hashvalue] ON [dbo].[mpi_pre_load_prov] ([hashvalue], [mpi_pre_load_prov_rowid])
GO
CREATE STATISTICS [spfk_rowid_srcname] ON [dbo].[mpi_pre_load_prov] ([mpi_pre_load_prov_rowid], [src_name])
GO
