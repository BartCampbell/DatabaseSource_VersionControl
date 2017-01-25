CREATE TABLE [dbo].[MedicalRecordHPV]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[HPVEvidenceID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordHPV_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordHPV_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordHPV] ADD CONSTRAINT [PK_MedicalRecordHPV] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordHPV_PursuitEventID] ON [dbo].[MedicalRecordHPV] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordHPV] ON [dbo].[MedicalRecordHPV] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordHPV] ADD CONSTRAINT [FK_MedicalRecordHPV_DropDownValues_HPVEvidence] FOREIGN KEY ([HPVEvidenceID]) REFERENCES [dbo].[DropDownValues_HPVEvidence] ([HPVEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordHPV] ADD CONSTRAINT [FK_MedicalRecordHPV_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordHPV] ADD CONSTRAINT [FK_MedicalRecordHPV_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
