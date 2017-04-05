CREATE TABLE [dbo].[dw_xref_ihds_member_id]
(
[ihds_member_id] [int] NOT NULL IDENTITY(20000, 1),
[ihds_mpi_id] [uniqueidentifier] NOT NULL,
[create_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[legacy_ihds_member_id] [int] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dw_xref_ihds_member_id] ADD CONSTRAINT [PK_dw_xref_ihds_member_id] PRIMARY KEY CLUSTERED  ([ihds_mpi_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_xref_ihds_member_id] ON [dbo].[dw_xref_ihds_member_id] ([ihds_member_id]) ON [PRIMARY]
GO
