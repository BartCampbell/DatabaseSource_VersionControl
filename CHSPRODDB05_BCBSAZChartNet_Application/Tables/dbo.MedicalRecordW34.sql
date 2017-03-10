CREATE TABLE [dbo].[MedicalRecordW34]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[MR_NumeratorFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordW34_MR_NumeratorFlag] DEFAULT ((0)),
[PhysHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW34_PhysHlthDevFlag] DEFAULT ((0)),
[PhysExamFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW34_PhysExamFlag] DEFAULT ((0)),
[HlthEducFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW34_HlthEducFlag] DEFAULT ((0)),
[PursuitEventSequenceID] [int] NULL,
[ServiceDate] [datetime] NULL,
[MentalHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordW34_MentalHlthDevFlag] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordW34_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordw34_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HlthHistoryFlag] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__HlthH__1B53EBE8] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordW34] ADD CONSTRAINT [PK_MedicalRecordW34] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordW34_PursuitEventID] ON [dbo].[MedicalRecordW34] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordW34] ON [dbo].[MedicalRecordW34] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordW34] ADD CONSTRAINT [FK_MedicalRecordW34_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordW34] ADD CONSTRAINT [FK_MedicalRecordW34_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
