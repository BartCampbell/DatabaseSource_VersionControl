CREATE TABLE [dbo].[MedicalRecordCDC_LDLC]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[NumeratorType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LDLCTestFlag] [bit] NULL CONSTRAINT [DF_MedicalRecordCDC_LDLCTestFlag] DEFAULT ((0)),
[LDLCResult] [decimal] (18, 2) NULL,
[FriedewaldEquationFlag] [bit] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_FriedewaldEquationFlag] DEFAULT ((0)),
[TotalCholesteralLevelResult] [decimal] (18, 2) NULL,
[HDLLevelResult] [decimal] (18, 2) NULL,
[TriglyceridesLevelResult] [decimal] (18, 2) NULL,
[LipoproteinLevelResult] [decimal] (18, 2) NULL,
[FriedewaldLDLC] [decimal] (18, 2) NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_LDLC_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordCDC_ldlc_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_LDLC] ADD CONSTRAINT [PK_MedicalRecordCDC_LDLC] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_LDLC_PursuitEventID] ON [dbo].[MedicalRecordCDC_LDLC] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordCDC_LDLC] ON [dbo].[MedicalRecordCDC_LDLC] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordCDC_LDLC] ADD CONSTRAINT [FK_MedicalRecordCDC_LDLC_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordCDC_LDLC] ADD CONSTRAINT [FK_MedicalRecordCDC_LDLC_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
