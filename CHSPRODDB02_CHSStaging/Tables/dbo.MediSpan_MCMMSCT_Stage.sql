CREATE TABLE [dbo].[MediSpan_MCMMSCT_Stage]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SNOMEDCT_CONCEPTID] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCMSNOMED_Relationship] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
