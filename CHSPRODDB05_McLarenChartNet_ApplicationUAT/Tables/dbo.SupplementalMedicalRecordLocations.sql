CREATE TABLE [dbo].[SupplementalMedicalRecordLocations]
(
[SupplementalMedicalRecordLocationsID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[ProviderSiteID] [int] NOT NULL,
[SupplementalMedicalRecordPursuitTypeID] [int] NOT NULL,
[SupplementalMedicalRecordSpecialtyID] [int] NOT NULL,
[LocationPriority] [int] NOT NULL,
[VisitCount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [PK_SupplementalMedicalRecordLocations] PRIMARY KEY CLUSTERED  ([SupplementalMedicalRecordLocationsID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [FK_SupplementalMedicalRecordLocations_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [FK_SupplementalMedicalRecordLocations_Providers] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Providers] ([ProviderID])
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [FK_SupplementalMedicalRecordLocations_ProviderSite] FOREIGN KEY ([ProviderSiteID]) REFERENCES [dbo].[ProviderSite] ([ProviderSiteID])
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [FK_SupplementalMedicalRecordLocations_SupplementalMedicalRecordPursuitType] FOREIGN KEY ([SupplementalMedicalRecordPursuitTypeID]) REFERENCES [dbo].[SupplementalMedicalRecordPursuitType] ([SupplementalMedicalRecordPursuitTypeID])
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordLocations] ADD CONSTRAINT [FK_SupplementalMedicalRecordLocations_SupplementalMedicalRecordSpecialty] FOREIGN KEY ([SupplementalMedicalRecordSpecialtyID]) REFERENCES [dbo].[SupplementalMedicalRecordSpecialty] ([SupplementalMedicalRecordSpecialtyID])
GO
