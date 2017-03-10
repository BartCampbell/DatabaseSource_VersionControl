CREATE TABLE [dbo].[SupplementalMedicalRecordPursuitType]
(
[SupplementalMedicalRecordPursuitTypeID] [int] NOT NULL IDENTITY(1, 1),
[PursuitTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupplementalMedicalRecordPursuitType] ADD CONSTRAINT [PK_SupplementalMedicalRecordPursuitType] PRIMARY KEY CLUSTERED  ([SupplementalMedicalRecordPursuitTypeID]) ON [PRIMARY]
GO
