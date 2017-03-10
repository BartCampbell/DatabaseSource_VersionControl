CREATE TABLE [dbo].[MedicalRecordPADOD]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NumeratorType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPADOD_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPADOD_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPADOD] ADD CONSTRAINT [PK_MedicalRecordPADOD] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPADOD] ADD CONSTRAINT [FK_MedicalRecordPADOD_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordPADOD] ADD CONSTRAINT [FK_MedicalRecordPADOD_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
