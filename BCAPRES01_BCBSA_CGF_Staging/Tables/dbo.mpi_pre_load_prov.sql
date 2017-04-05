CREATE TABLE [dbo].[mpi_pre_load_prov]
(
[mpi_pre_load_prov_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_prov_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dea_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_name] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middle_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_tax_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_spec_1_cd] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_spec_2_cd] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_state_lic] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_addr1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_addr2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_addr3] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_city] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_zip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashvalue] [binary] (16) NULL,
[LoadDate] [datetime] NOT NULL,
[upin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_prov_id] [int] NULL,
[medical_provider_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rank_address] [tinyint] NULL,
[rank_dea_id] [tinyint] NULL,
[rank_med_prov_id] [tinyint] NULL,
[rank_medical_provider_id] [tinyint] NULL,
[rank_name] [tinyint] NULL,
[rank_npi_id] [tinyint] NULL,
[rank_other] [tinyint] NULL,
[rank_prov_tax_id] [int] NULL,
[rank_upin] [tinyint] NULL,
[pharmacy_provider_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
