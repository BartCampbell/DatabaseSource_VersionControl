CREATE TABLE [dbo].[mpi_pre_load_member]
(
[mpi_pre_load_rowid] [bigint] NOT NULL IDENTITY(1, 1),
[clientid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_db_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_schema_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[src_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_ssn] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_ssn] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_dep_suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medical_subscriber_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medical_member_suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medical_member_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pharmacy_subscriber_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pharmacy_member_suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pharmacy_member_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[full_name] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mid_init] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_dob] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_dob] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr_line1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr_line2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[relation_to_subscriber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashvalue] [binary] (16) NULL,
[LoadDate] [datetime] NOT NULL,
[ihds_member_id] [int] NULL,
[mei_rank_address] [tinyint] NULL,
[mei_rank_name] [tinyint] NULL,
[mei_rank_other] [tinyint] NULL,
[medicare_no] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medicaid_no] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
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
