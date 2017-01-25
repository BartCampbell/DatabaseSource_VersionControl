CREATE TABLE [dbo].[MedicalRecordLSC]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[Result] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PursuitEventSequenceID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordLSC_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordlsc_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResultPresent] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordLSC] ADD CONSTRAINT [PK_MedicalRecordLSC] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordLSC_PursuitEventID] ON [dbo].[MedicalRecordLSC] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordLSC] ON [dbo].[MedicalRecordLSC] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordLSC] ADD CONSTRAINT [FK_MedicalRecordLSC_MedicalRecordLSC] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordLSC] ADD CONSTRAINT [FK_MedicalRecordLSC_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
