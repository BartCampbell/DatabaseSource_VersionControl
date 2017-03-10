CREATE TABLE [dbo].[MedicalRecordIMA]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[IMAEvidenceID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordIMA_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordIMA_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordIMA] ADD CONSTRAINT [PK_MedicalRecordIMA] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordIMA_PursuitEventID] ON [dbo].[MedicalRecordIMA] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordIMA] ON [dbo].[MedicalRecordIMA] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordIMA] ADD CONSTRAINT [FK_MedicalRecordIMA_DropDownValues_IMAEvidence] FOREIGN KEY ([IMAEvidenceID]) REFERENCES [dbo].[DropDownValues_IMAEvidence] ([IMAEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordIMA] ADD CONSTRAINT [FK_MedicalRecordIMA_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordIMA] ADD CONSTRAINT [FK_MedicalRecordIMA_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
