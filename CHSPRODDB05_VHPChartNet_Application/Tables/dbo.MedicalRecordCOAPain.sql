CREATE TABLE [dbo].[MedicalRecordCOAPain]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[PainScreeningEvidenceFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordCOAPain_PainScreeningEvidenceFlag] DEFAULT ((0)),
[PainScreeningEvidenceTypeKey] [int] NULL,
[PainScreeningEvidenceType] AS ([dbo].[GetMeasureComponentEvidence]('COA','PainScreeningType',[PainScreeningEvidenceTypeKey])),
[StandardToolTypeKey] [int] NULL,
[StandardToolType] AS ([dbo].[GetMeasureComponentEvidence]('COA','StandardToolType',[StandardToolTypeKey])),
[PainManagementPlanFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordCOAPain_PainManagementPlanFlag] DEFAULT ((0)),
[PainManagementPlanTypeKey] [int] NULL,
[PainManagementPlanType] AS ([dbo].[GetMeasureComponentEvidence]('COA','PainManagementPlan',[PainManagementPlanTypeKey])),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCOAPain_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordcoapain_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [PK_MedicalRecordCOAPain] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAPain_PursuitEventID] ON [dbo].[MedicalRecordCOAPain] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCOAPain] ON [dbo].[MedicalRecordCOAPain] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [FK_MedicalRecordCOAPain_MeasureComponentEvidence] FOREIGN KEY ([PainManagementPlanTypeKey]) REFERENCES [dbo].[MeasureComponentEvidence] ([MeasureEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [FK_MedicalRecordCOAPain_MeasureComponentEvidence1] FOREIGN KEY ([PainScreeningEvidenceTypeKey]) REFERENCES [dbo].[MeasureComponentEvidence] ([MeasureEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [FK_MedicalRecordCOAPain_MeasureComponentEvidence2] FOREIGN KEY ([StandardToolTypeKey]) REFERENCES [dbo].[MeasureComponentEvidence] ([MeasureEvidenceID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [FK_MedicalRecordCOAPain_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCOAPain] ADD CONSTRAINT [FK_MedicalRecordCOAPain_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
