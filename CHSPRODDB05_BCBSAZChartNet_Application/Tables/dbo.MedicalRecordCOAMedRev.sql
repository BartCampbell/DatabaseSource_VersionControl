CREATE TABLE [dbo].[MedicalRecordCOAMedRev]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[EvidenceOfMedicationList] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordCOAMedRev_EvidenceOfMedicationList] DEFAULT ((0)),
[EvidenceOfMedicationReview] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordCOAMedRev_EvidenceOfMedicationReview] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCOAMedRev_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcoamedrev_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotationOfNoMedicationTaken] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Notat__7928F116] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAMedRev] ADD CONSTRAINT [PK_MedicalRecordCOAMedRev] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAMedRev_PursuitEventID] ON [dbo].[MedicalRecordCOAMedRev] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAMedRev] ON [dbo].[MedicalRecordCOAMedRev] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAMedRev] ADD CONSTRAINT [FK_MedicalRecordCOAMedRev_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAMedRev] ADD CONSTRAINT [FK_MedicalRecordCOAMedRev_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
