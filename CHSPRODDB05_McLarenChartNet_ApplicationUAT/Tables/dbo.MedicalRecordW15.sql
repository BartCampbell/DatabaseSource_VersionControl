CREATE TABLE [dbo].[MedicalRecordW15]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[MR_NumeratorFlag] [bit] NULL,
[PhysHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW15_PhysHlthDevFlag] DEFAULT ((0)),
[PhysExamFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW15_PhysExamFlag] DEFAULT ((0)),
[HlthEducFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW15_HlthEducFlag] DEFAULT ((0)),
[PursuitEventSequenceID] [int] NULL,
[ServiceDate] [datetime] NULL,
[MentalHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW15_MentalHlthDevFlag] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordW15_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordw15_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HlthHistoryFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW15_HlthHistoryFlag] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordW15] ADD CONSTRAINT [PK_MedicalRecordW15] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordW15_PursuitEventID] ON [dbo].[MedicalRecordW15] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordW15] ON [dbo].[MedicalRecordW15] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordW15] ADD CONSTRAINT [FK_MedicalRecordW15_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordW15] ADD CONSTRAINT [FK_MedicalRecordW15_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
