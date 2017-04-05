CREATE TABLE [dbo].[dw_xref_ihds_member_id]
(
[ihds_member_id] [int] NOT NULL IDENTITY(200000, 1),
[ihds_mpi_id] [uniqueidentifier] NULL,
[create_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[legacy_ihds_member_id] [int] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_ihds_mpi_id] ON [dbo].[dw_xref_ihds_member_id] ([ihds_mpi_id], [ihds_member_id]) ON [PRIMARY]
GO
