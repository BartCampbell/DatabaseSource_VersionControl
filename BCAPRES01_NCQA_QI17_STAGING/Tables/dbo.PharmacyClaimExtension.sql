CREATE TABLE [dbo].[PharmacyClaimExtension]
(
[PharmacyClaimID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PharmacyClaimExtension] ADD CONSTRAINT [actPharmacyClaimExtension_PK] PRIMARY KEY CLUSTERED  ([PharmacyClaimID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PharmacyClaimExtension] ADD CONSTRAINT [actPharmacyClaim_PharmacyClaimExtension_FK1] FOREIGN KEY ([PharmacyClaimID]) REFERENCES [dbo].[PharmacyClaim] ([PharmacyClaimID])
GO
