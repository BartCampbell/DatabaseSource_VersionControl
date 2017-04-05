CREATE TABLE [dbo].[dw_xref_ihds_provider_id]
(
[ihds_provider_id] [int] NOT NULL IDENTITY(1, 1),
[ihds_mpi_id] [uniqueidentifier] NOT NULL,
[create_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dw_xref_ihds_provider_id] ADD CONSTRAINT [PK_dw_xref_ihds_provider_id] PRIMARY KEY CLUSTERED  ([ihds_mpi_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_xref_ihds_provider_id] ON [dbo].[dw_xref_ihds_provider_id] ([ihds_provider_id]) ON [PRIMARY]
GO
