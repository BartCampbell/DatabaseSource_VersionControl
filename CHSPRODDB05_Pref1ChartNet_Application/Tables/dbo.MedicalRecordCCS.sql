CREATE TABLE [dbo].[MedicalRecordCCS]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[EvidenceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PapTestFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCCS_PapTestFlag] DEFAULT ((0)),
[PapTestResult] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HystNoResidualCervixFlg] [bit] NULL CONSTRAINT [DF_MedicalRecordCCS_HystNoResidualCervixFlg] DEFAULT ((0)),
[VaginalPapWithHystFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCCS_VaginalPapWithHystFlag] DEFAULT ((0)),
[HysterectomyType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCCS_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordccs_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentedResult] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Docum__7A280247] DEFAULT ((0)),
[HystNoTestingFlag] [bit] NULL,
[Complete_Total_Abdominal_HysterectomyFlag] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCCS] ADD CONSTRAINT [PK_MedicalRecordCCS] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCCS_PursuitEventID] ON [dbo].[MedicalRecordCCS] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCCS] ON [dbo].[MedicalRecordCCS] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCCS] ADD CONSTRAINT [FK_MedicalRecordCCS_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCCS] ADD CONSTRAINT [FK_MedicalRecordCCS_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
