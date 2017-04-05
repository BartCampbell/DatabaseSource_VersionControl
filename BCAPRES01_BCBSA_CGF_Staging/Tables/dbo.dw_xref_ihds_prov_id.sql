CREATE TABLE [dbo].[dw_xref_ihds_prov_id]
(
[ihds_prov_id] [int] NOT NULL IDENTITY(1000, 1),
[ihds_mpi_id] [uniqueidentifier] NULL,
[create_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixMain] ON [dbo].[dw_xref_ihds_prov_id] ([ihds_mpi_id], [ihds_prov_id]) ON [PRIMARY]
GO
