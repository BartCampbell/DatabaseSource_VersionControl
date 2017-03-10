CREATE TABLE [dbo].[MedicalRecordCOACarePlan]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[DocumentationType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentationDetail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCOACarePlan_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcoacareplan_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceDate] [datetime] NOT NULL CONSTRAINT [DF__MedicalRe__Servi__6CC31A31] DEFAULT (((1900)-(1))-(1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOACarePlan] ADD CONSTRAINT [PK_MedicalRecordCOACarePlan] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOACarePlan_PursuitEventID] ON [dbo].[MedicalRecordCOACarePlan] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOACarePlan] ON [dbo].[MedicalRecordCOACarePlan] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOACarePlan] ADD CONSTRAINT [FK_MedicalRecordCOACarePlan_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCOACarePlan] ADD CONSTRAINT [FK_MedicalRecordCOACarePlan_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
