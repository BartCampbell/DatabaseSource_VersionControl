CREATE TABLE [dbo].[PharmacyExtension]
(
[PharmacyID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PharmacyExtension] ADD CONSTRAINT [actPharmacyExtension_PK] PRIMARY KEY CLUSTERED  ([PharmacyID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PharmacyExtension] ADD CONSTRAINT [actPharmacy_PharmacyExtension_FK1] FOREIGN KEY ([PharmacyID]) REFERENCES [dbo].[Pharmacy] ([PharmacyID])
GO
