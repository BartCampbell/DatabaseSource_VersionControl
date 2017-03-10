CREATE TABLE [dbo].[SupplementalMedicalRecordSpecialty]
(
[SupplementalMedicalRecordSpecialtyID] [int] NOT NULL IDENTITY(1, 1),
[SpecialtyName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordSpecialty] ADD CONSTRAINT [PK_SupplementalMedicalRecordSpecialty] PRIMARY KEY CLUSTERED  ([SupplementalMedicalRecordSpecialtyID]) ON [PRIMARY]
GO
