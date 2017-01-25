CREATE TABLE [dbo].[MedicalRecordPSSScreening]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[ScreenedForSmoking] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenedForExposure] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvidenceOfSmokingCounseling] [bit] NULL,
[EvidenceOfSmokingExposure] [bit] NULL,
[EvidenceStoppedSmoking] [bit] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPSSScreening_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordPSSScreening_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPSSScreening] ADD CONSTRAINT [PK_MedicalRecordPSSScreening] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordPSSScreening] ADD CONSTRAINT [FK_MedicalRecordPSSScreening_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordPSSScreening] ADD CONSTRAINT [FK_MedicalRecordPSSScreening_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
