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
[ihds_prov_id_admitting] [bigint] NULL
) ON [PRIMARY]
GO
