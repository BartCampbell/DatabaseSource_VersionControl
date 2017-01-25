CREATE TABLE [dbo].[MedicalRecordCOL]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[EvidenceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NumeratorType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreeningInMedicalHistory] [bit] NULL CONSTRAINT [DF_MedicalRecordCOL_ScreeningInMedicalHistory] DEFAULT ((0)),
[PriorDiagnosisOfColorectalCancerFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCOL_PriorDiagnosisOfColorectalCancerFlag] DEFAULT ((0)),
[PriorTotalColorectomyFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCOL_PriorTotalColorectomyFlag] DEFAULT ((0)),
[FOBTTestType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MedicalRecordCOL_ProgressNotationFlag] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCOL_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcol_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FOBTSampleCount] [decimal] (18, 2) NULL,
[PathologyReportType] [varchar] (110) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOL] ADD CONSTRAINT [PK_MedicalRecordCOL] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOL_PursuitEventID] ON [dbo].[MedicalRecordCOL] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOL] ON [dbo].[MedicalRecordCOL] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOL] ADD CONSTRAINT [FK_MedicalRecordCOL_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCOL] ADD CONSTRAINT [FK_MedicalRecordCOL_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
