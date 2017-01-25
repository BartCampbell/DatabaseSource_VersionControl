CREATE TABLE [dbo].[MedicalRecordCIS]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[CIS_ImmunizationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordEvidenceKey] [int] NULL,
[CIS_MR_NumeratorEventFlag] [int] NULL,
[CIS_MR_NumeratorEvidenceFlag] [int] NULL,
[CIS_MR_ExclusionFlag] [int] NULL,
[CIS_IMMEventFlag] [int] NULL,
[CIS_HistIllnessFlag] [int] NULL,
[CIS_SeroposResultFlag] [int] NULL,
[CIS_ExclContrFlag] [int] NULL,
[PursuitEventSequenceID] [int] NULL,
[ServiceDate] [datetime] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCIS_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcis_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCIS] ADD CONSTRAINT [PK_MedicalRecordCIS] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCIS_PursuitEventID] ON [dbo].[MedicalRecordCIS] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCIS] ON [dbo].[MedicalRecordCIS] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCIS] ADD CONSTRAINT [FK_MedicalRecordCIS_MedicalRecordEvidence] FOREIGN KEY ([MedicalRecordEvidenceKey]) REFERENCES [dbo].[MedicalRecordEvidence] ([EvidenceKey])
GO
ALTER TABLE [dbo].[MedicalRecordCIS] ADD CONSTRAINT [FK_MedicalRecordCIS_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCIS] ADD CONSTRAINT [FK_MedicalRecordCIS_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
