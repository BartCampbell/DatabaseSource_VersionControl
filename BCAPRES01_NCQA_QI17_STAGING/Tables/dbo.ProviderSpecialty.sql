CREATE TABLE [dbo].[ProviderSpecialty]
(
[ProviderID] [int] NOT NULL,
[SpecialtyID] [int] NOT NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderSpecialty] ADD CONSTRAINT [actProviderSpecialty_PK] PRIMARY KEY CLUSTERED  ([SpecialtyID], [ProviderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderSpecialty] ADD CONSTRAINT [actProvider_ProviderSpecialty_FK1] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[ProviderSpecialty] ADD CONSTRAINT [FK_ProviderSpecialty_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]) ON DELETE CASCADE
GO
