CREATE TABLE [dbo].[MedicalRecordAWC]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NULL,
[PursuitEventID] [int] NULL,
[MR_NumeratorFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordAWC_MR_NumeratorFlag] DEFAULT ((0)),
[PhysHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordAWC_PhysHlthDevFlag] DEFAULT ((0)),
[PhysExamFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordAWC_PhysExamFlag] DEFAULT ((0)),
[HlthEducFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordAWC_HlthEducFlag] DEFAULT ((0)),
[PursuitEventSequenceID] [int] NULL,
[ServiceDate] [datetime] NULL,
[MentalHlthDevFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordAWC_MentalHlthDevFlag] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordAWC_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordawc_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HlthHistoryFlag] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__HlthH__1A5FC7AF] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordAWC] ADD CONSTRAINT [PK_MedicalRecordAWC] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordAWC_PursuitEventID] ON [dbo].[MedicalRecordAWC] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordAWC] ON [dbo].[MedicalRecordAWC] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordAWC] ADD CONSTRAINT [FK_MedicalRecordAWC_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordAWC] ADD CONSTRAINT [FK_MedicalRecordAWC_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
