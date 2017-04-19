CREATE TABLE [dbo].[mpi_pre_load_member]
(
[mpi_pre_load_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashvalue] [binary] (16) NULL,
[LoadDate] [datetime] NOT NULL
) ON [dbo_mpi_pre_load_member]
GO
CREATE NONCLUSTERED INDEX [fk_hashvalue] ON [dbo].[mpi_pre_load_member] ([hashvalue], [mpi_pre_load_rowid]) ON [dbo_mpi_pre_load_member_IDX]
GO
CREATE CLUSTERED INDEX [pk_mpi_pre_load_member1] ON [dbo].[mpi_pre_load_member] ([mpi_pre_load_rowid], [clientid], [src_table_name], [src_db_name], [src_schema_name]) ON [dbo_mpi_pre_load_member]
GO
CREATE STATISTICS [spfk_hashvalue] ON [dbo].[mpi_pre_load_member] ([hashvalue], [mpi_pre_load_rowid])
GO
CREATE STATISTICS [sppk_mpi_pre_load_member1] ON [dbo].[mpi_pre_load_member] ([mpi_pre_load_rowid], [clientid], [src_table_name], [src_db_name], [src_schema_name])
GO
