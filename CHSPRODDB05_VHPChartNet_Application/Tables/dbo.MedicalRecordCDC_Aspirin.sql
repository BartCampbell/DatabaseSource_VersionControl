CREATE TABLE [dbo].[MedicalRecordCDC_Aspirin]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[ServiceDate] [datetime] NULL,
[AspirinUseStatusId] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_Aspirin_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_aspirin_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Aspirin] ADD CONSTRAINT [PK_MedicalRecordCDC_Aspirin] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Aspirin_PursuitEventID] ON [dbo].[MedicalRecordCDC_Aspirin] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Aspirin] ON [dbo].[MedicalRecordCDC_Aspirin] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Aspirin] ADD CONSTRAINT [FK_MedicalRecordCDC_Aspirin_DropDownValues_AspirinUseStatus] FOREIGN KEY ([AspirinUseStatusId]) REFERENCES [dbo].[DropDownValues_AspirinUseStatus] ([AspirinUseStatusId])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Aspirin] ADD CONSTRAINT [FK_MedicalRecordCDC_Aspirin_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Aspirin] ADD CONSTRAINT [FK_MedicalRecordCDC_Aspirin_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
