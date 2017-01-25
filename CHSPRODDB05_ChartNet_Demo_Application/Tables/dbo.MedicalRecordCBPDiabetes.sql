CREATE TABLE [dbo].[MedicalRecordCBPDiabetes]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NoDiabetesDiagnosisFlag] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__NoDia__25D17A5B] DEFAULT ((0)),
[DiabetesRefutedFlag] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Diabe__26C59E94] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCBPDiabetes_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCBPDiabetes_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCBPDiabetes] ADD CONSTRAINT [PK_MedicalRecordCBPDiabetes] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCBPDiabetes] ADD CONSTRAINT [FK_MedicalRecordCBPDiabetes_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCBPDiabetes] ADD CONSTRAINT [FK_MedicalRecordCBPDiabetes_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
