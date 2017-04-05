CREATE TABLE [dbo].[mpi_pre_load_dtl_prov]
(
[mpi_pre_load_dtl_prov_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[mpi_pre_load_prov_rowid] [bigint] NULL,
[src_rowid] [int] NULL,
[loaddate] [datetime] NULL,
[clientid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_mpi_pre_load_dtl_prov]
GO
CREATE CLUSTERED INDEX [fk_dtl_prov] ON [dbo].[mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [src_rowid]) ON [dbo_mpi_pre_load_dtl_prov]
GO
CREATE STATISTICS [spfk_dtl_prov] ON [dbo].[mpi_pre_load_dtl_prov] ([mpi_pre_load_prov_rowid], [src_rowid])
GO
