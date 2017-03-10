CREATE TABLE [dbo].[MedicalRecordCDC_Influenza]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[ServiceDate] [datetime] NULL,
[ImmunizationStatusId] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_Influenza_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_influenza_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Influenza] ADD CONSTRAINT [PK_MedicalRecordCDC_Influenza] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Influenza_PursuitEventID] ON [dbo].[MedicalRecordCDC_Influenza] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Influenza] ON [dbo].[MedicalRecordCDC_Influenza] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Influenza] ADD CONSTRAINT [FK_MedicalRecordCDC_Influenza_DropDownValues_ImmunizationStatus] FOREIGN KEY ([ImmunizationStatusId]) REFERENCES [dbo].[DropDownValues_ImmunizationStatus] ([ImmunizationStatusId])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Influenza] ADD CONSTRAINT [FK_MedicalRecordCDC_Influenza_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Influenza] ADD CONSTRAINT [FK_MedicalRecordCDC_Influenza_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
