CREATE TABLE [dbo].[MedicalRecordCBPReading]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[SystolicLevel] [int] NOT NULL,
[DiastolicLevel] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCBPReading_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcbpreading_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCBPReading] ADD CONSTRAINT [PK_MedicalRecordCBPReading] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCBPReading_PursuitEventID] ON [dbo].[MedicalRecordCBPReading] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCBPReading] ON [dbo].[MedicalRecordCBPReading] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCBPReading] ADD CONSTRAINT [FK_MedicalRecordCBPReading_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCBPReading] ADD CONSTRAINT [FK_MedicalRecordCBPReading_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
