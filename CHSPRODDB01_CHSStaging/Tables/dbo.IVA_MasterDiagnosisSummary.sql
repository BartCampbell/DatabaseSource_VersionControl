CREATE TABLE [dbo].[IVA_MasterDiagnosisSummary]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSThru] [date] NULL,
[HCC] [int] NULL,
[Level1_CoderID] [int] NULL,
[Level1_CoderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level1_OutCome] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level1_CoderDiagnosisNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level1_CoderAdditionalNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_CoderID] [int] NULL,
[Level2_CoderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_OutCome] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_CoderDiagnosisNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_CoderAdditionalNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVA_MasterDiagnosisSummary] ADD CONSTRAINT [UQ__IVA_Mast__360414FEFE006364] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
