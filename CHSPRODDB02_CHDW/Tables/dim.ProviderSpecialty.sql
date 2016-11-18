CREATE TABLE [dim].[ProviderSpecialty]
(
[ProviderSpecialtyID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[SpecialtyID] [int] NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderSpecialty_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderSpecialty_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderSpecialty] ADD CONSTRAINT [PK_ProviderSpecialty] PRIMARY KEY CLUSTERED  ([ProviderSpecialtyID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderSpecialty] ADD CONSTRAINT [FK_ProviderSpecialty_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
ALTER TABLE [dim].[ProviderSpecialty] ADD CONSTRAINT [FK_ProviderSpecialty_Specialty] FOREIGN KEY ([SpecialtyID]) REFERENCES [dim].[Specialty] ([SpecialtyID])
GO
