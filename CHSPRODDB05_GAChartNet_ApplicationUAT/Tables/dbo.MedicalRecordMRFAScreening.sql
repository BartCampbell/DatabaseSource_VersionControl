CREATE TABLE [dbo].[MedicalRecordMRFAScreening]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[AlcoholUse] [bit] NULL,
[IllicitDrugUse] [bit] NULL,
[PrescriptionUse] [bit] NULL,
[PartnerViolence] [bit] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordMRFAScreening_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordMRFAScreening_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordMRFAScreening] ADD CONSTRAINT [PK_MedicalRecordMRFAScreening] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordMRFAScreening] ADD CONSTRAINT [FK_MedicalRecordMRFAScreening_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordMRFAScreening] ADD CONSTRAINT [FK_MedicalRecordMRFAScreening_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
