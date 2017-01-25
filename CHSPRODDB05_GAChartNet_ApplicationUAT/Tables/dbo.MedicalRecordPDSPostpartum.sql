CREATE TABLE [dbo].[MedicalRecordPDSPostpartum]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[ScreenedForDepression] [bit] NULL,
[DepressionScreeningTool] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResultOfScreening] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvidenceOfFurtherEvaluation] [bit] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPDSPostpartum_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPDSPostpartum_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPDSPostpartum] ADD CONSTRAINT [PK_MedicalRecordPDSPostpartum] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPDSPostpartum] ADD CONSTRAINT [FK_MedicalRecordPDSPostpartum_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordPDSPostpartum] ADD CONSTRAINT [FK_MedicalRecordPDSPostpartum_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
