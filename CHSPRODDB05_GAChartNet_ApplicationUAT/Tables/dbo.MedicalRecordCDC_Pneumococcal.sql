CREATE TABLE [dbo].[MedicalRecordCDC_Pneumococcal]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[ServiceDate] [datetime] NULL,
[ImmunizationStatusId] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_Pneumococcal_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_pneumococcal_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Pneumococcal] ADD CONSTRAINT [PK_MedicalRecordCDC_Pneumococcal] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Pneumococcal_PursuitEventID] ON [dbo].[MedicalRecordCDC_Pneumococcal] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Pneumococcal] ON [dbo].[MedicalRecordCDC_Pneumococcal] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Pneumococcal] ADD CONSTRAINT [FK_MedicalRecordCDC_Pneumococcal_DropDownValues_ImmunizationStatus] FOREIGN KEY ([ImmunizationStatusId]) REFERENCES [dbo].[DropDownValues_ImmunizationStatus] ([ImmunizationStatusId])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Pneumococcal] ADD CONSTRAINT [FK_MedicalRecordCDC_Pneumococcal_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Pneumococcal] ADD CONSTRAINT [FK_MedicalRecordCDC_Pneumococcal_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
