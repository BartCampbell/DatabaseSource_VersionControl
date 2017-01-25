CREATE TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[ExclusionTypeID] [int] NULL,
[ExclusionType] AS ([dbo].[GetCDCHbA1cExclusionType]([ExclusionTypeID])),
[IVDDiagnosisID] [int] NULL,
[IVDDiagnosis] AS ([dbo].[GetCDCCDCHbA1cIVDDiagnosis]([IVDDiagnosisID])),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_HbA1cExclusion_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_hba1cExclusion_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion] ADD CONSTRAINT [PK_MedicalRecordCDC_HbA1cExclusion] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_HbA1cExclusion_PursuitEventID] ON [dbo].[MedicalRecordCDC_HbA1cExclusion] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_HbA1cExclusion] ON [dbo].[MedicalRecordCDC_HbA1cExclusion] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion] ADD CONSTRAINT [FK_MedicalRecordCDC_HbA1cExclusion_DropDownValues_CDCHbA1cExclusionType] FOREIGN KEY ([ExclusionTypeID]) REFERENCES [dbo].[DropDownValues_CDCHbA1cExclusionType] ([ExclusionTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion] ADD CONSTRAINT [FK_MedicalRecordCDC_HbA1cExclusion_DropDownValues_CDCHbA1cIVDDiagnosis] FOREIGN KEY ([IVDDiagnosisID]) REFERENCES [dbo].[DropDownValues_CDCHbA1cIVDDiagnosis] ([IVDDiagnosisID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion] ADD CONSTRAINT [FK_MedicalRecordCDC_HbA1cExclusion_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion] ADD CONSTRAINT [FK_MedicalRecordCDC_HbA1cExclusion_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
