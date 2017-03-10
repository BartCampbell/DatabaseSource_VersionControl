CREATE TABLE [dbo].[MedicalRecordPPC]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NumeratorType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrenatalServicingProviderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBGYNVisitFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_OBGYNVisitFlag] DEFAULT ((0)),
[OBGYNVisitSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPVisitFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_PCPVisitFlag] DEFAULT ((0)),
[PCPVisitSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostpartumVisitFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_PostpartumVisitFlag] DEFAULT ((0)),
[PostpartumVisitSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPDiagnosisOfPregnancy] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_PCPDiagnosisOfPregnancy] DEFAULT ((0)),
[PCAPVisitFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_PCAPVisitFlag] DEFAULT ((0)),
[PCAPVisitSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPPC_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordppc_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPPC] ADD CONSTRAINT [PK_MedicalRecordPPC] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordPPC_PursuitEventID] ON [dbo].[MedicalRecordPPC] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordPPC] ON [dbo].[MedicalRecordPPC] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPPC] ADD CONSTRAINT [FK_MedicalRecordPPC_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordPPC] ADD CONSTRAINT [FK_MedicalRecordPPC_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
