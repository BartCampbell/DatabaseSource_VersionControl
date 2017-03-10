CREATE TABLE [dbo].[MedicalRecordHIV4]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[EvidenceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PapTestFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordHIV4_PapTestFlag] DEFAULT ((0)),
[PapTestResult] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HystNoResidualCervixFlg] [bit] NULL CONSTRAINT [DF_MedicalRecordHIV4_HystNoResidualCervixFlg] DEFAULT ((0)),
[VaginalPapWithHystFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordHIV4_VaginalPapWithHystFlag] DEFAULT ((0)),
[SexualReassignmentSurgery] [bit] NULL CONSTRAINT [DF_MedicalRecordHIV4_SexualReassignmentSurgeryFlag] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordHIV4_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordhiv4_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordHIV4] ADD CONSTRAINT [PK_MedicalRecordHIV4] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordHIV4_PursuitEventID] ON [dbo].[MedicalRecordHIV4] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordHIV4] ON [dbo].[MedicalRecordHIV4] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordHIV4] ADD CONSTRAINT [FK_MedicalRecordHIV4_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordHIV4] ADD CONSTRAINT [FK_MedicalRecordHIV4_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
