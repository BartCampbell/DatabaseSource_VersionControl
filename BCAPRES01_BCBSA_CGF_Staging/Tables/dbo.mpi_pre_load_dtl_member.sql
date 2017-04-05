CREATE TABLE [dbo].[mpi_pre_load_dtl_member]
(
[mpi_pre_load_dtl_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[mpi_pre_load_rowid] [bigint] NULL,
[src_rowid] [int] NULL,
[loaddate] [datetime] NULL,
[clientid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_mpi_pre_load_dtl_member]
GO
CREATE CLUSTERED INDEX [fk_pre_load_id_src_row_id] ON [dbo].[mpi_pre_load_dtl_member] ([mpi_pre_load_rowid], [src_rowid]) ON [dbo_mpi_pre_load_dtl_member]
GO
CREATE STATISTICS [spfk_pre_load_id_src_row_id] ON [dbo].[mpi_pre_load_dtl_member] ([mpi_pre_load_rowid], [src_rowid])
GO
