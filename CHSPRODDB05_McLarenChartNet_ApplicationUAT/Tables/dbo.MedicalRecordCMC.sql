CREATE TABLE [dbo].[MedicalRecordCMC]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[LDLCTestFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCMC_LDLCTestFlag] DEFAULT ((0)),
[LDLCResult] [decimal] (18, 2) NULL,
[FriedewaldEquationFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCMC_FriedewaldEquationFlag] DEFAULT ((0)),
[TotalCholesteralLevelResult] [decimal] (18, 2) NULL,
[HDLLevelResult] [decimal] (18, 2) NULL,
[TriglyceridesLevelResult] [decimal] (18, 2) NULL,
[LipoproteinLevelResult] [decimal] (18, 2) NULL,
[NumeratorTypeKey] [int] NULL,
[NumeratorType] AS ([dbo].[GetMeasureComponentEvidence]('CMC','NumeratorType',[NumeratorTypeKey])),
[FriedewaldLDLC] [decimal] (18, 2) NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCMC_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCMC_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCMC] ADD CONSTRAINT [PK_MedicalRecordCMC] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCMC_PursuitEventID] ON [dbo].[MedicalRecordCMC] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCMC] ON [dbo].[MedicalRecordCMC] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCMC] ADD CONSTRAINT [FK_MedicalRecordCMC_MedicalRecordCMC] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCMC] ADD CONSTRAINT [FK_MedicalRecordCMC_MedicalRecordCMC1] FOREIGN KEY ([NumeratorTypeKey]) REFERENCES [dbo].[MeasureComponentEvidence] ([MeasureEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordCMC] ADD CONSTRAINT [FK_MedicalRecordCMC_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
