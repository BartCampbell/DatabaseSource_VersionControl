CREATE TABLE [dbo].[MedicalRecordFPCPre]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[PrenatalServicingProviderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OBGYNVisitFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordFPCPre_OBGYNVisitFlag] DEFAULT ((0)),
[OBGYNSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPVisitFlag] [bit] NOT NULL,
[PCPSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisOfPregancy] [bit] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordFPCPre_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordfpcpre_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordFPCPre] ADD CONSTRAINT [PK_MedicalRecordFPCPre] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordFPCPre_PursuitEventID] ON [dbo].[MedicalRecordFPCPre] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordFPCPre] ON [dbo].[MedicalRecordFPCPre] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordFPCPre] ADD CONSTRAINT [FK_MedicalRecordFPCPre_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordFPCPre] ADD CONSTRAINT [FK_MedicalRecordFPCPre_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
