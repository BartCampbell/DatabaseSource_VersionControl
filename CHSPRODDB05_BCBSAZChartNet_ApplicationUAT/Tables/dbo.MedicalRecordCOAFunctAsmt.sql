CREATE TABLE [dbo].[MedicalRecordCOAFunctAsmt]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NotationType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardizedToolType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCOAFunctAsmt_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcoafunctasmt_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAFunctAsmt] ADD CONSTRAINT [PK_MedicalRecordCOAFunctAsmt] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAFunctAsmt_PursuitEventID] ON [dbo].[MedicalRecordCOAFunctAsmt] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAFunctAsmt] ON [dbo].[MedicalRecordCOAFunctAsmt] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAFunctAsmt] ADD CONSTRAINT [FK_MedicalRecordCOAFunctAsmt_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAFunctAsmt] ADD CONSTRAINT [FK_MedicalRecordCOAFunctAsmt_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
