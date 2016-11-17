CREATE TABLE [dbo].[MediSpan_MCMCLASS_Stage]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentMedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RelationshipType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
