CREATE TABLE [dbo].[MedicalRecordCDC_Smoking]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[ServiceDate] [datetime] NULL,
[SmokingStatusId] [int] NULL,
[DateOfCessationAdvice] [datetime] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_Smoking_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_smoking_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Smoking] ADD CONSTRAINT [PK_MedicalRecordCDC_Smoking] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Smoking_PursuitEventID] ON [dbo].[MedicalRecordCDC_Smoking] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Smoking] ON [dbo].[MedicalRecordCDC_Smoking] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Smoking] ADD CONSTRAINT [FK_MedicalRecordCDC_Smoking_DropDownValues_SmokingStatus] FOREIGN KEY ([SmokingStatusId]) REFERENCES [dbo].[DropDownValues_SmokingStatus] ([SmokingStatusId])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Smoking] ADD CONSTRAINT [FK_MedicalRecordCDC_Smoking_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Smoking] ADD CONSTRAINT [FK_MedicalRecordCDC_Smoking_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
