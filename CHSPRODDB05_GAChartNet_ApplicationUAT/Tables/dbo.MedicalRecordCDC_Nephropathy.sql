CREATE TABLE [dbo].[MedicalRecordCDC_Nephropathy]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NumeratorType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScreeningSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreeningResult] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvidenceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalAttentionConditionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MacroalbuminTestType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MacroalbuminTestResult] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_Nephropathy_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_nephropathy_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreeningResultPresent] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Scree__75634D2A] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Nephropathy] ADD CONSTRAINT [PK_MedicalRecordCDC_Nephropathy] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Nephropathy_PursuitEventID] ON [dbo].[MedicalRecordCDC_Nephropathy] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_Nephropathy] ON [dbo].[MedicalRecordCDC_Nephropathy] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Nephropathy] ADD CONSTRAINT [FK_MedicalRecordCDC_Nephropathy_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_Nephropathy] ADD CONSTRAINT [FK_MedicalRecordCDC_Nephropathy_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
